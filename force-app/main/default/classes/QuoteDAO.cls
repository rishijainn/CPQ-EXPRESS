public with sharing class QuoteDAO {

    public static List<Quote> getQuotes(String query) {
        return Database.query(query);
    }

    public static Quote getQuoteById(Id quoteId) {
        return [
            SELECT Id, QuoteNumber, Name, Status,
                   OpportunityId, Opportunity.Name,
                   AccountId, Account.Name,
                   CreatedById, CreatedBy.Name,
                   LastModifiedById, LastModifiedBy.Name,
                   CreatedDate, LastModifiedDate,
                   Total_Amount__c, GrandTotal, Calculated_Discount__c,
                   Subtotal, ExpirationDate,
                   Start_Date__c, End_Date__c,
                   Time_Period__c,
                   Margin_Amount__c, Margin_Percent__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];
    }

    public static Quote getQuoteForUpdate(Id quoteId) {
        return [SELECT Time_Period__c FROM Quote WHERE Id = :quoteId LIMIT 1];
    }

    public static Quote getQuoteForClone(Id quoteId) {
        return [
            SELECT Id, OpportunityId, AccountId, Name, Description,
                   Status, Start_Date__c, End_Date__c,
                   Time_Period__c, Calculated_Discount__c, Phase_List__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];
    }

    public static Quote getQuoteForRecalc(Id quoteId) {
        return [SELECT End_Date__c, Time_Period__c FROM Quote WHERE Id = :quoteId LIMIT 1];
    }

    public static List<Account> getAccountsForFilter() {
        return [SELECT Id, Name FROM Account ORDER BY Name ASC];
    }

    public static List<Quote_Line_Item__c> getLineItemsForRecalc(Id quoteId) {
        return [
            SELECT Total_Price__c, Cost__c, Quantity__c,
                   End_Date__c, Start_Date__c, Item_Type__c, Unit_Price__c
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
        ];
    }

    public static List<Quote_Line_Item__c> getResourceRoleLineItems(Id quoteId) {
        return [
            SELECT Id, Item_Type__c, Base_Rate__c, Unit_Price__c
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
            AND Item_Type__c = 'Resource Role'
        ];
    }

    public static List<Quote_Line_Item__c> getLineItemsForClone(Id quoteId) {
        return [
            SELECT Name, Item_Type__c, Resource_Role__c, Product__c,
                   Add_On__c, Phase__c, Task__c,
                   Start_Date__c, End_Date__c, Quantity__c,
                   Base_Rate__c, Unit_Price__c,
                   Discount_Percent__c, Cost__c
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
        ];
    }

    public static List<Opportunity> getStandaloneOpportunity(Id accountId) {
        return [
            SELECT Id FROM Opportunity
            WHERE AccountId = :accountId
            AND Name LIKE 'Standalone Quotes - %'
            LIMIT 1
        ];
    }

    public static Account getAccountById(Id accountId) {
        return [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
    }

    public static User getCurrentUserWithRole() {
        return [
            SELECT Id, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }

    public static Id insertQuote(Quote q) {
        insert q;
        return q.Id;
    }

    public static void updateQuote(Quote q) {
        update q;
    }

    public static void deleteQuote(Id quoteId) {
        delete new Quote(Id = quoteId);
    }

    public static Id insertOpportunity(Opportunity opp) {
        insert opp;
        return opp.Id;
    }

    public static void insertLineItems(List<Quote_Line_Item__c> items) {
        insert items;
    }

    public static void updateLineItems(List<Quote_Line_Item__c> items) {
        update items;
    }
}
