@isTest
private class QuotePdfModuleTest {
    @isTest
    static void testQuotePdfModule() {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Quote q = TestDataFactory.createQuote(opp.Id, true);
        Organization_Settings__c org = TestDataFactory.createOrgSettings(true);
        
        Product__c prod = TestDataFactory.createProduct(true);
        Quote_Line_Item__c qli = TestDataFactory.createQuoteLineItem(q.Id, 'Product', prod.Id, true);
        
        Test.startTest();
        // Test LWC PDF controller
        Map<String, Object> pdfData = QuotePdfController.getQuotePdfData(q.Id);
        System.assertNotEquals(null, pdfData, 'Should return PDF map data');
        System.assert(pdfData.containsKey('phases'), 'Should contain phases data');
        System.assert(pdfData.containsKey('orgInfo'), 'Should contain orgInfo data');
        
        // Test VF Page PDF Controller
        PageReference pdfPage = Page.QuoteDownloadPdf;
        pdfPage.getParameters().put('id', String.valueOf(q.Id));
        Test.setCurrentPage(pdfPage);
        
        QuoteDownloadPdfController pdfController = new QuoteDownloadPdfController();
        System.assertNotEquals(null, pdfController.quote, 'VF page should load quote data');
        System.assertNotEquals(null, pdfController.phases, 'VF page should load phases');
        System.assertNotEquals(null, pdfController.orgInfo, 'VF page should load orgInfo');
        Test.stopTest();
    }
}
