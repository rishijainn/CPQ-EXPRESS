public with sharing class QuoteLineItemDAO {

    public static List<Quote_Line_Item__c> getLineItems(Id quoteId) {
        return [
            SELECT Id, Name, Item_Type__c, Quote__r.Time_Period__c,
                   Resource_Role__c, Resource_Role__r.Name, Resource_Role__r.Name__c,
                   Product__c, Product__r.Name, Product__r.Name__c,
                   Add_On__c, Add_On__r.Name, Add_On__r.Name__c,
                   Phase__c, Task__c,
                   Start_Date__c, End_Date__c,
                   Quantity__c, Base_Rate__c,
                   Unit_Price__c, Discount_Percent__c,
                   Total_Price__c, Cost__c, Margin__c
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
            ORDER BY CreatedDate ASC
        ];
    }

    public static Quote getPhaseList(Id quoteId) {
        return [SELECT Phase_List__c FROM Quote WHERE Id = :quoteId LIMIT 1];
    }

    public static void savePhaseList(Id quoteId, String phaseList) {
        update new Quote(Id = quoteId, Phase_List__c = phaseList);
    }

    public static Quote getParentQuote(Id quoteId) {
        return [
            SELECT Start_Date__c, End_Date__c, Time_Period__c
            FROM Quote
            WHERE Id = :quoteId LIMIT 1
        ];
    }

    public static List<Resource_Role__c> getResourceRolesByIds(List<Id> ids) {
        return [
            SELECT Id, Name, Name__c, Price__c, Cost__c, Billing_Unit__c
            FROM Resource_Role__c
            WHERE Id IN :ids
        ];
    }

    public static List<Product__c> getProductsByIds(List<Id> ids) {
        return [
            SELECT Id, Name, Name__c, Price__c, Cost__c
            FROM Product__c
            WHERE Id IN :ids
        ];
    }

    public static List<Add_On__c> getAddonsByIds(List<Id> ids) {
        return [
            SELECT Id, Name, Name__c, Price__c, Cost__c
            FROM Add_On__c
            WHERE Id IN :ids
        ];
    }

    public static void insertLineItems(List<Quote_Line_Item__c> items) {
        insert items;
    }

    public static void updateLineItem(Quote_Line_Item__c item) {
        update item;
    }

    public static void updateLineItems(List<Quote_Line_Item__c> items) {
        update items;
    }

    public static Quote_Line_Item__c getLineItemById(Id itemId) {
        return [
            SELECT Quote__c
            FROM Quote_Line_Item__c
            WHERE Id = :itemId
            LIMIT 1
        ];
    }

    public static Quote_Line_Item__c getFirstLineItemFromSet(List<Id> itemIds) {
        return [
            SELECT Quote__c
            FROM Quote_Line_Item__c
            WHERE Id IN :itemIds
            LIMIT 1
        ];
    }

    public static List<Quote_Line_Item__c> getLineItemsByIds(List<Id> itemIds) {
        return [
            SELECT Id FROM Quote_Line_Item__c WHERE Id IN :itemIds
        ];
    }

    public static List<Quote_Line_Item__c> getLineItemsByPhaseAndQuote(Id quoteId, String phaseName) {
        return [
            SELECT Id FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId AND Phase__c = :phaseName
        ];
    }

    public static void deleteLineItem(Quote_Line_Item__c item) {
        delete item;
    }

    public static void deleteLineItems(List<Quote_Line_Item__c> items) {
        delete items;
    }

    public static AggregateResult[] getLineItemSummaryAgg(Id quoteId) {
        return [
            SELECT Item_Type__c type,
                   SUM(Total_Price__c) totalRevenue,
                   SUM(Margin__c) totalMargin,
                   COUNT(Id) itemCount
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
            GROUP BY Item_Type__c
        ];
    }

    public static List<Quote_Line_Item__c> getLineItemsForSubtotal(Id quoteId) {
        return [
            SELECT Unit_Price__c, Quantity__c, Item_Type__c,
                   Start_Date__c, End_Date__c
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
        ];
    }

    public static AggregateResult[] getLineItemsByPhaseAgg(Id quoteId) {
        return [
            SELECT Phase__c phase,
                   Item_Type__c type,
                   SUM(Total_Price__c) totalPrice,
                   COUNT(Id) itemCount
            FROM Quote_Line_Item__c
            WHERE Quote__c = :quoteId
            GROUP BY Phase__c, Item_Type__c
            ORDER BY Phase__c
        ];
    }
}
