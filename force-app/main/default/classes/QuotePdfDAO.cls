public with sharing class QuotePdfDAO {

    public static Quote getQuoteHeader(Id quoteId) {
        return [
            SELECT Id, QuoteNumber, Name, Status,
                   OpportunityId, Opportunity.Name,
                   AccountId, Account.Name,
                   CreatedById, CreatedBy.Name,
                   LastModifiedById, LastModifiedBy.Name,
                   CreatedDate, ExpirationDate,
                   Start_Date__c, End_Date__c,
                   Time_Period__c, TotalPrice,
                   GrandTotal, Discount, Subtotal,
                   Description,
                   Margin_Amount__c, Margin_Percent__c,
                   Subtotal_Amount__c, Calculated_Discount__c, Total_Amount__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];
    }

    public static Quote getQuoteHeaderForPdf(Id quoteId) {
        return [
            SELECT Id, QuoteNumber, Name, Status, Account.Name, CreatedBy.Name,
                   CreatedDate, ExpirationDate, Description,
                   Subtotal_Amount__c, Calculated_Discount__c, Total_Amount__c,
                   Time_Period__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];
    }

    public static List<Quote_Line_Item__c> getLineItemsForPdf(Id quoteId) {
        return [
            SELECT Id, Name, Item_Type__c, Phase__c, Task__c, Quantity__c,
                   Base_Rate__c, Unit_Price__c, Discount_Percent__c,
                   Total_Price__c, Cost__c, Margin__c,
                   Start_Date__c, End_Date__c,
                   Resource_Role__c, Resource_Role__r.Name__c,
                   Product__c, Product__r.Name__c,
                   Add_On__c, Add_On__r.Name__c
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
            ORDER BY Phase__c, CreatedDate ASC
        ];
    }

    public static List<Quote_Line_Item__c> getLineItemsForDownloadPdf(Id quoteId) {
        return [
            SELECT Id, Item_Type__c, Phase__c, Quantity__c, Unit_Price__c,
                   Discount_Percent__c, Total_Price__c, Start_Date__c, End_Date__c,
                   Resource_Role__r.Name__c, Product__r.Name__c, Add_On__r.Name__c,
                   Quote__r.Time_Period__c
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
            ORDER BY Phase__c, CreatedDate ASC
        ];
    }

    public static List<Organization_Settings__c> getOrgSettings() {
        return [
            SELECT Company_Name__c, Email__c,
                   Phone__c, Website__c, Address__c,
                   City__c, State__c, Zip_Code__c,
                   Country__c, Logo_URL__c
            FROM Organization_Settings__c
            LIMIT 1
        ];
    }

    public static List<Organization_Settings__c> getOrgSettingsForDownload() {
        return [
            SELECT Company_Name__c, Email__c, Phone__c, Website__c,
                   Address__c, City__c, State__c, Zip_Code__c, Country__c
            FROM Organization_Settings__c
            LIMIT 1
        ];
    }
}
