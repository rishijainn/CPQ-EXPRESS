public with sharing class ProductDAO {

    public static List<Product__c> getProducts(String query) {
        return Database.query(query);
    }

    public static Id upsertProduct(Product__c p) {
        upsert p;
        return p.Id;
    }

    public static void toggleActiveStatus(Id productId, Boolean isActive) {
        update new Product__c(Id = productId, Is_Active__c = isActive);
    }

    public static void deleteProduct(Id productId) {
        delete new Product__c(Id = productId);
    }
}
