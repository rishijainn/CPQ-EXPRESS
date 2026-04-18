@isTest
private class ProductModuleTest {
    @isTest
    static void testProductModule() {
        // Test create
        Id prodId = ProductController.createProduct(null, 'Test Prod', 'Each', 100, 50, 'Test');
        System.assertNotEquals(null, prodId, 'Product should be created');
        
        // Test update via create method
        ProductController.createProduct(prodId, 'Updated Prod', 'Each', 120, 60, 'Test');
        List<Product__c> prods = ProductController.getProducts('Updated');
        System.assertEquals(1, prods.size(), 'Should find updated product');
        
        // Test get products no search
        List<Product__c> allProds = ProductController.getProducts('');
        System.assertEquals(1, allProds.size(), 'Should find 1 product');
        
        // Test toggle active status
        ProductController.toggleActiveStatus(prodId, false);
        List<Product__c> inactiveProds = ProductController.getProducts('');
        System.assertEquals(false, inactiveProds[0].Is_Active__c, 'Product should be inactive');
        
        // Test delete
        ProductController.deleteProduct(prodId);
        List<Product__c> remaining = ProductController.getProducts('');
        System.assertEquals(0, remaining.size(), 'Product should be deleted');
    }
}
