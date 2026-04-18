public with sharing class QuoteDownloadPdfController {

    public Quote quote { get; private set; }
    public List<PhaseWrapper> phases { get; private set; }
    public Organization_Settings__c orgInfo { get; private set; }
    public Decimal grandTotal { get; private set; }
    public String quoteDate { get; private set; }
    public String validUntil { get; private set; }

    public QuoteDownloadPdfController() {
        Id quoteId = ApexPages.currentPage().getParameters().get('id');
        if (quoteId != null) {
            init(quoteId);

            // Add header to force direct download with a meaningful filename
            String filename = 'Quote_' + this.quote.QuoteNumber + '.pdf';
            ApexPages.currentPage().getHeaders().put(
                'content-disposition', 'attachment; filename=' + filename);
        }
    }

    private void init(Id quoteId) {
        // 1. Get Quote Header via DAO
        this.quote = QuotePdfDAO.getQuoteHeaderForPdf(quoteId);

        this.quoteDate  = quote.CreatedDate.format('MMM dd, yyyy');
        this.validUntil = quote.ExpirationDate != null
            ? quote.ExpirationDate.format() : 'N/A';

        // 2. Get Org Branding via DAO
        List<Organization_Settings__c> orgs =
            QuotePdfDAO.getOrgSettingsForDownload();
        this.orgInfo = !orgs.isEmpty()
            ? orgs[0]
            : new Organization_Settings__c(Company_Name__c = 'My Company');

        // 3. Get Line Items via DAO & group by Phase
        List<Quote_Line_Item__c> items =
            QuotePdfDAO.getLineItemsForDownloadPdf(quoteId);

        Map<String, PhaseWrapper> phaseMap =
            new Map<String, PhaseWrapper>();
        this.grandTotal = 0;

        for (Quote_Line_Item__c item : items) {
            String phaseTitle = String.isNotBlank(item.Phase__c)
                ? item.Phase__c : 'General';
            if (!phaseMap.containsKey(phaseTitle)) {
                phaseMap.put(phaseTitle, new PhaseWrapper(phaseTitle));
            }

            PhaseWrapper pw = phaseMap.get(phaseTitle);
            ItemWrapper iw  = new ItemWrapper(item);
            pw.items.add(iw);
            pw.total        += iw.totalPrice;
            this.grandTotal += iw.totalPrice;
        }

        this.phases = phaseMap.values();
    }

    // ── Phase wrapper ─────────────────────────────────────────────────────
    public class PhaseWrapper {
        public String title { get; set; }
        public List<ItemWrapper> items { get; set; }
        public Decimal total { get; set; }

        public PhaseWrapper(String t) {
            this.title = t;
            this.items = new List<ItemWrapper>();
            this.total = 0;
        }
    }

    // ── Line item wrapper ─────────────────────────────────────────────────
    public class ItemWrapper {
        public String name { get; set; }
        public String type { get; set; }
        public Decimal quantity { get; set; }
        public String billingUnit { get; set; }
        public Decimal unitPrice { get; set; }
        public Decimal discount { get; set; }
        public Decimal totalPrice { get; set; }
        public String startDate { get; set; }
        public String endDate { get; set; }

        public ItemWrapper(Quote_Line_Item__c i) {
            if (i.Resource_Role__r != null) {
                this.name = i.Resource_Role__r.Name__c;
                String period = i.Quote__r.Time_Period__c != null
                    ? i.Quote__r.Time_Period__c : 'Months';
                this.billingUnit = period.toLowerCase().removeEnd('s') + '(s)';
            } else if (i.Product__r != null) {
                this.name = i.Product__r.Name__c;
                this.billingUnit = 'unit(s)';
            } else if (i.Add_On__r != null) {
                this.name = i.Add_On__r.Name__c;
                this.billingUnit = 'unit(s)';
            } else {
                this.name = 'Miscellaneous';
                this.billingUnit = 'unit(s)';
            }

            this.type       = i.Item_Type__c;
            this.quantity   = i.Quantity__c != null ? i.Quantity__c : 0;
            this.unitPrice  = i.Unit_Price__c != null ? i.Unit_Price__c : 0;
            this.discount   = i.Discount_Percent__c != null
                ? i.Discount_Percent__c : 0;
            this.totalPrice = i.Total_Price__c != null ? i.Total_Price__c : 0;
            this.startDate  = i.Start_Date__c != null
                ? i.Start_Date__c.format() : '';
            this.endDate    = i.End_Date__c != null
                ? i.End_Date__c.format() : '';
        }
    }
}