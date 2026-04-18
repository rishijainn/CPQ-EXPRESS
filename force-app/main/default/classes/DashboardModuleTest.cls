@isTest
private class DashboardModuleTest {
    @isTest
    static void testDashboardModule() {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Quote q1 = TestDataFactory.createQuote(opp.Id, true);
        
        Quote q2 = TestDataFactory.createQuote(opp.Id, false);
        q2.Status = 'Approved';
        q2.Total_Amount__c = 1000;
        q2.Margin_Percent__c = 40;
        insert q2;
        
        // Test getDraftPipeline
        Map<String, Object> draftPipe = DashboardController.getDraftPipeline();
        System.assertNotEquals(null, draftPipe, 'Draft pipeline map should not be null');
        
        // Test high margin deals
        Map<String, Object> marginDeals = DashboardController.getHighMarginDeals();
        System.assertNotEquals(null, marginDeals, 'Margin deals map should not be null');
        
        // Test won this month
        Map<String, Object> wonMonth = DashboardController.getWonThisMonth();
        System.assertNotEquals(null, wonMonth, 'Won this month map should not be null');
        
        // Test recent quotes
        List<Quote> recentQuotes = DashboardController.getRecentQuotes();
        System.assertNotEquals(null, recentQuotes, 'Recent quotes list should not be null');
        
        // Test total quote count
        Integer totalCount = DashboardController.getTotalQuoteCount();
        System.assert(totalCount >= 2, 'Total quote count should be at least 2');
    }
}
