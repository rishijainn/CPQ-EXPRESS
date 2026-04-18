@isTest
private class QuoteLineItemModuleTest {
    @isTest
    static void testQuoteLineItemModule() {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Quote q = TestDataFactory.createQuote(opp.Id, true);
        
        Product__c prod = TestDataFactory.createProduct(true);
        Add_On__c addon = TestDataFactory.createAddon(true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        
        Test.startTest();
        // Test add items
        QuoteLineItemController.addLineItems(q.Id, new List<Id>{role.Id}, new List<Id>{prod.Id}, new List<Id>{addon.Id}, 'Phase 1');
        
        // Test get items
        List<Quote_Line_Item__c> items = QuoteLineItemController.getLineItems(q.Id);
        System.assertEquals(3, items.size(), 'Should have added 3 line items');
        
        // Test update item
        Quote_Line_Item__c item = items[0];
        item.Quantity__c = 2;
        QuoteLineItemController.updateLineItem(item);
        
        // Test phases
        String phaseConfig = QuoteLineItemController.getPhaseList(q.Id);
        
        QuoteLineItemController.savePhaseList(q.Id, '["Phase 1", "Phase 2"]');
        
        List<Map<String, Object>> phList = QuoteLineItemController.getLineItemsByPhase(q.Id);
        System.assertNotEquals(null, phList, 'Should return phase item maps');
        
        Map<String, Object> summary = QuoteLineItemController.getLineItemSummary(q.Id);
        System.assertNotEquals(null, summary, 'Should return summary map');
        
        Decimal multi = QuoteLineItemController.getPeriodMultiplier('Months');
        System.assertEquals(160, multi, 'Multiplier for months should be 160');
        
        // Delete items
        QuoteLineItemController.deleteLineItem(items[0].Id);
        QuoteLineItemController.deleteLineItems(new List<Id>{items[1].Id});
        QuoteLineItemController.deletePhase(q.Id, 'Phase 1');
        Test.stopTest();
    }
}
