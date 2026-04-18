@isTest
private class OpportunityModuleTest {
    @isTest
    static void testOpportunityModule() {
        Account acc = TestDataFactory.createAccount(true);
        
        // Test create
        Id oppId = OpportunityController.createOpportunity('Test Opp', acc.Id, 'Prospecting', Date.today().addDays(30), 10000);
        System.assertNotEquals(null, oppId, 'Opportunity should be created');
        
        // Test get all
        List<Opportunity> allOpps = OpportunityController.getOpportunities();
        System.assertEquals(1, allOpps.size(), 'Should find 1 opportunity');
        
        // Test get by Account
        List<Opportunity> accOpps = OpportunityController.getOpportunitiesByAccountId(acc.Id);
        System.assertEquals(1, accOpps.size(), 'Should find opportunity for account');
        
        // Test get by Id
        Opportunity opp = OpportunityController.getOpportunityById(oppId);
        System.assertNotEquals(null, opp, 'Should find opportunity by Id');
        
        // Test delete
        OpportunityController.deleteOpportunity(oppId);
        List<Opportunity> remaining = OpportunityController.getOpportunities();
        System.assertEquals(0, remaining.size(), 'Opportunity should be deleted');
    }
}
