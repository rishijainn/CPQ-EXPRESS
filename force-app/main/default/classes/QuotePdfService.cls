public with sharing class QuotePdfService {

    // ── Build full PDF data payload for LWC (QuotePdfController) ─────────
    public static Map<String, Object> getQuotePdfData(Id quoteId) {
        // 1. Get Quote Header
        Quote quote = QuotePdfDAO.getQuoteHeader(quoteId);

        // 2. Get Line Items
        List<Quote_Line_Item__c> lineItems =
            QuotePdfDAO.getLineItemsForPdf(quoteId);

        // 3. Get Org Settings
        List<Organization_Settings__c> orgSettings =
            QuotePdfDAO.getOrgSettings();

        // 4. Group Line Items by Phase & resolve display names
        Map<String, List<Map<String, Object>>> phaseMap =
            new Map<String, List<Map<String, Object>>>();
        Decimal grandTotal = 0;

        for (Quote_Line_Item__c item : lineItems) {
            String displayName = item.Name;
            if (item.Resource_Role__r != null &&
                item.Resource_Role__r.Name__c != null) {
                displayName = item.Resource_Role__r.Name__c;
            } else if (item.Product__r != null &&
                       item.Product__r.Name__c != null) {
                displayName = item.Product__r.Name__c;
            } else if (item.Add_On__r != null &&
                       item.Add_On__r.Name__c != null) {
                displayName = item.Add_On__r.Name__c;
            }

            String phase = String.isNotBlank(item.Phase__c)
                ? item.Phase__c : 'Default Phase';

            if (!phaseMap.containsKey(phase)) {
                phaseMap.put(phase, new List<Map<String, Object>>());
            }

            Decimal total = item.Total_Price__c != null
                ? item.Total_Price__c : 0;
            grandTotal += total;

            String billingUnit = 'item(s)';
            if (item.Item_Type__c == 'Resource Role') {
                String period = quote.Time_Period__c != null
                    ? quote.Time_Period__c : 'Months';
                billingUnit = period.toLowerCase().removeEnd('s') + '(s)';
            }

            phaseMap.get(phase).add(new Map<String, Object>{
                'id'          => item.Id,
                'name'        => displayName,
                'type'        => item.Item_Type__c,
                'quantity'    => item.Quantity__c,
                'billingUnit' => billingUnit,
                'unitPrice'   => item.Unit_Price__c,
                'discount'    => item.Discount_Percent__c,
                'total'       => total,
                'startDate'   => item.Start_Date__c != null
                    ? item.Start_Date__c.format() : '',
                'endDate'     => item.End_Date__c != null
                    ? item.End_Date__c.format() : ''
            });
        }

        // 5. Build phases list
        List<Map<String, Object>> phases = new List<Map<String, Object>>();
        Integer phaseNum = 1;
        for (String phaseName : phaseMap.keySet()) {
            List<Map<String, Object>> items = phaseMap.get(phaseName);
            Decimal phaseTotal = 0;
            for (Map<String, Object> itm : items) {
                phaseTotal += (Decimal) itm.get('total');
            }
            phases.add(new Map<String, Object>{
                'phaseNumber' => phaseNum++,
                'phaseName'   => phaseName,
                'items'       => items,
                'phaseTotal'  => phaseTotal
            });
        }

        // 6. Build org info map
        Map<String, Object> orgInfo = new Map<String, Object>{
            'companyName' => 'My Company',
            'email' => '', 'phone' => '', 'website' => '',
            'address' => '', 'city' => '', 'state' => '',
            'zipCode' => '', 'country' => ''
        };

        if (!orgSettings.isEmpty()) {
            Organization_Settings__c org = orgSettings[0];
            orgInfo.put('companyName',
                org.Company_Name__c != null ? org.Company_Name__c : 'My Company');
            orgInfo.put('email',
                org.Email__c != null ? org.Email__c : '');
            orgInfo.put('phone',
                org.Phone__c != null ? org.Phone__c : '');
            orgInfo.put('website',
                org.Website__c != null ? org.Website__c : '');
            orgInfo.put('address',
                org.Address__c != null ? org.Address__c : '');
            orgInfo.put('city',
                org.City__c != null ? org.City__c : '');
            orgInfo.put('state',
                org.State__c != null ? org.State__c : '');
            orgInfo.put('zipCode',
                org.Zip_Code__c != null ? org.Zip_Code__c : '');
            orgInfo.put('country',
                org.Country__c != null ? org.Country__c : '');
        }

        // 7. Return full payload
        return new Map<String, Object>{
            'quote'       => quote,
            'phases'      => phases,
            'grandTotal'  => grandTotal,
            'orgInfo'     => orgInfo,
            'quoteNumber' => quote.QuoteNumber,
            'accountName' => quote.Account != null ? quote.Account.Name : '',
            'createdBy'   => quote.CreatedBy != null ? quote.CreatedBy.Name : '',
            'description' => quote.Description != null
                ? quote.Description : 'Professional Services Project',
            'validUntil'  => quote.ExpirationDate != null
                ? quote.ExpirationDate.format() : '',
            'quoteDate'   => quote.CreatedDate != null
                ? Date.valueOf(quote.CreatedDate).format() : ''
        };
    }
}
