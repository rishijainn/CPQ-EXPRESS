@isTest
private class QuoteModuleTest {
    @isTest
    static void testQuoteModule() {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        
        Test.startTest();
        // Test create
        Id quoteId = QuoteController.createQuote(opp.Id, acc.Id, 'Test Desc', Date.today(), Date.today().addDays(30), 'Months');
        System.assertNotEquals(null, quoteId, 'Quote should be created');
        
        // Test get filters
        List<Quote> allQuotes = QuoteController.getQuotes('All', 'All');
        System.assert(allQuotes.size() > 0, 'Should return quotes');
        
        List<Account> accountsFilter = QuoteController.getAccountsForFilter();
        System.assertNotEquals(null, accountsFilter, 'Should return accounts config filter');
        
        // Test update
        Quote qUpdate = QuoteController.getQuoteById(quoteId);
        qUpdate.Description = 'Updated';
        QuoteController.updateQuote(qUpdate);
        
        // Test Clone
        Id clonedId = QuoteController.cloneQuote(quoteId, acc.Id);
        System.assertNotEquals(null, clonedId, 'Should clone quote successfully');
        
        // Test Approval process statuses
        QuoteController.submitForApproval(quoteId, 'Submitting');
        System.assertEquals('Pending Approval', QuoteController.getQuoteById(quoteId).Status);
        
        QuoteController.approveQuote(quoteId);
        System.assertEquals('Approved', QuoteController.getQuoteById(quoteId).Status);
        
        QuoteController.rejectQuote(clonedId, 'Rejecting');
        System.assertEquals('Rejected', QuoteController.getQuoteById(clonedId).Status);
        
        QuoteController.recallQuote(quoteId);
        System.assertEquals('Draft', QuoteController.getQuoteById(quoteId).Status);
        
        // Test Re-calc
        QuoteController.recalculateQuoteTotals(quoteId);
        
        // Count BD
        Integer bd = QuoteController.countBusinessDays(Date.newInstance(2023, 10, 1), Date.newInstance(2023, 10, 10));
        System.assertNotEquals(null, bd, 'BD returns value');
        
        // Test delete
        QuoteController.deleteQuote(clonedId);
        Test.stopTest();
    }
}
