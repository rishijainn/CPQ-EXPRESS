public with sharing class ProductController {

    @AuraEnabled(cacheable=true)
    public static List<Product__c> getProducts(String searchTerm) {
        return ProductService.getProducts(searchTerm);
    }

    @AuraEnabled
    public static Id createProduct(Id id, String name, String billingUnit,
                                   Decimal price, Decimal cost, String tags) {
        return ProductService.createProduct(id, name, billingUnit, price, cost, tags);
    }

    @AuraEnabled
    public static void toggleActiveStatus(Id productId, Boolean isActive) {
        ProductService.toggleActiveStatus(productId, isActive);
    }

    @AuraEnabled
    public static void deleteProduct(Id productId) {
        ProductService.deleteProduct(productId);
    }
}