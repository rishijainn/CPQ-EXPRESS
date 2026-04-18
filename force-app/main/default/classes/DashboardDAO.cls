public with sharing class DashboardDAO {

    public static AggregateResult getDraftPipelineAgg() {
        return [
            SELECT COUNT(Id) quoteCount,
                   SUM(Total_Amount__c) totalAmount
            FROM Quote
            WHERE Status = 'Draft'
        ];
    }

    public static AggregateResult getHighMarginDealsAgg() {
        return [
            SELECT COUNT(Id) quoteCount,
                   SUM(Total_Amount__c) totalAmount
            FROM Quote
            WHERE Margin_Percent__c >= 35
        ];
    }

    public static AggregateResult getWonThisMonthAgg() {
        return [
            SELECT COUNT(Id) quoteCount,
                   SUM(Total_Amount__c) totalAmount
            FROM Quote
            WHERE Status = 'Approved'
            AND CreatedDate = THIS_MONTH
        ];
    }

    public static List<Quote> getRecentQuotes() {
        return [
            SELECT Id, QuoteNumber, Name, Status,
                   Account.Name, Total_Amount__c,
                   CreatedDate, Margin_Percent__c
            FROM Quote
            WHERE CreatedById = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
    }

    public static Integer getTotalQuoteCount() {
        return [
            SELECT COUNT()
            FROM Quote
            WHERE CreatedById = :UserInfo.getUserId()
        ];
    }
}
