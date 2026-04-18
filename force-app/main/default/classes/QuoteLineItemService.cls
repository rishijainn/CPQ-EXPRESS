public with sharing class QuoteLineItemService {

    // ── Get all line items for a quote ────────────────────────────────────
    public static List<Quote_Line_Item__c> getLineItems(Id quoteId) {
        return QuoteLineItemDAO.getLineItems(quoteId);
    }

    // ── Get empty phases stored on the Quote ──────────────────────────────
    public static String getPhaseList(Id quoteId) {
        return QuoteLineItemDAO.getPhaseList(quoteId).Phase_List__c;
    }

    // ── Save empty phases back to the Quote ───────────────────────────────
    public static void savePhaseList(Id quoteId, String phaseList) {
        QuoteLineItemDAO.savePhaseList(quoteId, phaseList);
    }

    // ── Delete a phase and move items to Default ──────────────────────────
    public static void deletePhase(Id quoteId, String phaseName) {
        if (quoteId == null || String.isBlank(phaseName)) return;

        // 1. Update Quote Phase List
        Quote q = QuoteLineItemDAO.getPhaseList(quoteId);
        if (String.isNotBlank(q.Phase_List__c)) {
            try {
                List<String> phases = (List<String>) JSON.deserialize(
                    q.Phase_List__c, List<String>.class);
                Integer index = -1;
                for (Integer i = 0; i < phases.size(); i++) {
                    if (phases[i] == phaseName) { index = i; break; }
                }
                if (index != -1) {
                    phases.remove(index);
                    QuoteLineItemDAO.savePhaseList(quoteId, JSON.serialize(phases));
                }
            } catch (Exception e) {
                // Fallback for non-JSON strings
                List<String> phases = q.Phase_List__c.split(',');
                List<String> newPhases = new List<String>();
                for (String p : phases) {
                    if (p.trim() != phaseName) newPhases.add(p.trim());
                }
                QuoteLineItemDAO.savePhaseList(quoteId, String.join(newPhases, ','));
            }
        }

        // 2. Clear Phase__c for orphaned line items
        List<Quote_Line_Item__c> orphans =
            QuoteLineItemDAO.getLineItemsByPhaseAndQuote(quoteId, phaseName);
        if (!orphans.isEmpty()) {
            for (Quote_Line_Item__c item : orphans) {
                item.Phase__c = null;
            }
            QuoteLineItemDAO.updateLineItems(orphans);
        }
    }

    // ── Add line items from modal selection ───────────────────────────────
    public static void addLineItems(Id quoteId, List<Id> resourceRoleIds,
                                    List<Id> productIds, List<Id> addonIds,
                                    String phase) {

        List<Quote_Line_Item__c> itemsToInsert = new List<Quote_Line_Item__c>();
        Quote parentQuote = QuoteLineItemDAO.getParentQuote(quoteId);

        // Add Resource Roles
        if (resourceRoleIds != null && !resourceRoleIds.isEmpty()) {
            List<Resource_Role__c> roles =
                QuoteLineItemDAO.getResourceRolesByIds(resourceRoleIds);

            for (Resource_Role__c role : roles) {
                Quote_Line_Item__c item = new Quote_Line_Item__c();
                item.Quote__c         = quoteId;
                item.Phase__c         = phase;
                item.Name             = role.Name__c;
                item.Item_Type__c     = 'Resource Role';
                item.Resource_Role__c = role.Id;
                item.Base_Rate__c     = role.Price__c;

                Decimal periodMultiplier = getPeriodMultiplier(parentQuote.Time_Period__c);
                item.Unit_Price__c    = (role.Price__c != null)
                    ? (role.Price__c * periodMultiplier) : 0;

                item.Cost__c             = role.Cost__c;
                item.Quantity__c         = 1;
                item.Start_Date__c       = parentQuote.Start_Date__c;
                item.End_Date__c         = parentQuote.End_Date__c;
                item.Discount_Percent__c = 0;
                itemsToInsert.add(item);
            }
        }

        // Add Products
        if (productIds != null && !productIds.isEmpty()) {
            List<Product__c> products =
                QuoteLineItemDAO.getProductsByIds(productIds);

            for (Product__c product : products) {
                Quote_Line_Item__c item = new Quote_Line_Item__c();
                item.Quote__c            = quoteId;
                item.Phase__c            = phase;
                item.Name                = product.Name__c;
                item.Item_Type__c        = 'Product';
                item.Product__c          = product.Id;
                item.Base_Rate__c        = product.Price__c;
                item.Unit_Price__c       = product.Price__c;
                item.Cost__c             = product.Cost__c;
                item.Quantity__c         = 1;
                item.Start_Date__c       = parentQuote.Start_Date__c;
                item.End_Date__c         = parentQuote.End_Date__c;
                item.Discount_Percent__c = 0;
                itemsToInsert.add(item);
            }
        }

        // Add Add-ons
        if (addonIds != null && !addonIds.isEmpty()) {
            List<Add_On__c> addons =
                QuoteLineItemDAO.getAddonsByIds(addonIds);

            for (Add_On__c addon : addons) {
                Quote_Line_Item__c item = new Quote_Line_Item__c();
                item.Quote__c            = quoteId;
                item.Phase__c            = phase;
                item.Name                = addon.Name__c;
                item.Item_Type__c        = 'Add-on';
                item.Add_On__c           = addon.Id;
                item.Base_Rate__c        = addon.Price__c;
                item.Unit_Price__c       = addon.Price__c;
                item.Cost__c             = addon.Cost__c;
                item.Quantity__c         = 1;
                item.Start_Date__c       = parentQuote.Start_Date__c;
                item.End_Date__c         = parentQuote.End_Date__c;
                item.Discount_Percent__c = 0;
                itemsToInsert.add(item);
            }
        }

        if (!itemsToInsert.isEmpty()) {
            QuoteLineItemDAO.insertLineItems(itemsToInsert);
            QuoteService.recalculateQuoteTotals(quoteId);
        }
    }

    // ── Update a single line item ─────────────────────────────────────────
    public static void updateLineItem(Quote_Line_Item__c item) {
        QuoteLineItemDAO.updateLineItem(item);
        Quote_Line_Item__c existing = QuoteLineItemDAO.getLineItemById(item.Id);
        QuoteService.recalculateQuoteTotals(existing.Quote__c);
    }

    // ── Delete a single line item ─────────────────────────────────────────
    public static void deleteLineItem(Id itemId) {
        Quote_Line_Item__c item = QuoteLineItemDAO.getLineItemById(itemId);
        Id quoteId = item.Quote__c;
        QuoteLineItemDAO.deleteLineItem(item);
        QuoteService.recalculateQuoteTotals(quoteId);
    }

    // ── Delete multiple line items ────────────────────────────────────────
    public static void deleteLineItems(List<Id> itemIds) {
        if (itemIds == null || itemIds.isEmpty()) return;

        Quote_Line_Item__c firstItem =
            QuoteLineItemDAO.getFirstLineItemFromSet(itemIds);
        Id quoteId = firstItem.Quote__c;

        List<Quote_Line_Item__c> itemsToDelete =
            QuoteLineItemDAO.getLineItemsByIds(itemIds);
        QuoteLineItemDAO.deleteLineItems(itemsToDelete);

        QuoteService.recalculateQuoteTotals(quoteId);
    }

    // ── Get line items grouped by type for summary cards ──────────────────
    public static Map<String, Object> getLineItemSummary(Id quoteId) {
        AggregateResult[] results = QuoteLineItemDAO.getLineItemSummaryAgg(quoteId);

        Map<String, Object> summary = new Map<String, Object>();
        Decimal grandTotal = 0;

        for (AggregateResult r : results) {
            Decimal rev = (Decimal) r.get('totalRevenue');
            if (rev != null) grandTotal += rev;
        }

        for (AggregateResult r : results) {
            String type    = (String)  r.get('type');
            Decimal revenue = (Decimal) r.get('totalRevenue') != null
                ? (Decimal) r.get('totalRevenue') : 0;
            Decimal margin  = (Decimal) r.get('totalMargin') != null
                ? (Decimal) r.get('totalMargin') : 0;
            Integer count   = (Integer) r.get('itemCount');

            Decimal cost = revenue - margin;
            Decimal percentage = grandTotal > 0
                ? (revenue / grandTotal * 100).setScale(1) : 0;

            summary.put(type, new Map<String, Object>{
                'revenue'    => revenue,
                'cost'       => cost,
                'margin'     => margin,
                'count'      => count,
                'percentage' => percentage
            });
        }

        // Calculate Subtotal (Unit Price * Quantity before discount)
        List<Quote_Line_Item__c> items =
            QuoteLineItemDAO.getLineItemsForSubtotal(quoteId);

        Decimal subtotal = 0;
        for (Quote_Line_Item__c item : items) {
            if (item.Unit_Price__c != null && item.Quantity__c != null) {
                subtotal += (item.Unit_Price__c * item.Quantity__c);
            }
        }

        summary.put('grandTotal', grandTotal);
        summary.put('subtotal', subtotal);
        return summary;
    }

    // ── Get line items grouped by phase for phase table ───────────────────
    public static List<Map<String, Object>> getLineItemsByPhase(Id quoteId) {
        AggregateResult[] results = QuoteLineItemDAO.getLineItemsByPhaseAgg(quoteId);

        Map<String, Map<String, Object>> phaseMap =
            new Map<String, Map<String, Object>>();

        for (AggregateResult r : results) {
            String  phase = (String)  r.get('phase');
            String  type  = (String)  r.get('type');
            Decimal price = (Decimal) r.get('totalPrice');
            Integer count = (Integer) r.get('itemCount');

            if (phase == null) phase = 'Default';
            if (price == null) price = 0;

            if (!phaseMap.containsKey(phase)) {
                phaseMap.put(phase, new Map<String, Object>{
                    'phase'    => phase,
                    'labor'    => 0,
                    'products' => 0,
                    'addons'   => 0,
                    'total'    => 0,
                    'items'    => 0
                });
            }

            Map<String, Object> phaseData = phaseMap.get(phase);
            Decimal currentTotal = (Decimal) phaseData.get('total');
            Integer currentItems = (Integer) phaseData.get('items');

            if (type == 'Resource Role') {
                phaseData.put('labor', price);
            } else if (type == 'Product') {
                phaseData.put('products', price);
            } else if (type == 'Add-on') {
                phaseData.put('addons', price);
            }

            phaseData.put('total', currentTotal + price);
            phaseData.put('items', currentItems + count);
        }

        return phaseMap.values();
    }

    // ── Helper: Get hour multiplier for a given Time Period ───────────────
    public static Decimal getPeriodMultiplier(String period) {
        if (period == 'Days')     return 8;
        if (period == 'Weeks')    return 40;
        if (period == 'Months')   return 160;
        if (period == 'Quarters') return 480;
        if (period == 'Years')    return 1920;
        return 160; // Default to months
    }
}
