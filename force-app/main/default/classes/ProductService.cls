public with sharing class ProductService {

    public static List<Product__c> getProducts(String searchTerm) {
        String query = 'SELECT Id, Name, Name__c, Billing_Unit__c, ' +
                       'Price__c, Cost__c, Tags__c, Is_Active__c ' +
                       'FROM Product__c WHERE Id != null';

        if (String.isNotBlank(searchTerm)) {
            query += ' AND Name__c LIKE \'%' +
                     String.escapeSingleQuotes(searchTerm) + '%\'';
        }

        query += ' ORDER BY Name__c ASC';
        return ProductDAO.getProducts(query);
    }

    public static Id createProduct(Id id, String name, String billingUnit,
                                   Decimal price, Decimal cost, String tags) {
        Product__c p = new Product__c();
        if (id != null) p.Id = id;

        p.Name__c         = name;
        p.Billing_Unit__c = billingUnit;
        p.Price__c        = price;
        p.Cost__c         = cost;
        p.Tags__c         = tags;
        if (id == null) p.Is_Active__c = true;

        return ProductDAO.upsertProduct(p);
    }

    public static void toggleActiveStatus(Id productId, Boolean isActive) {
        ProductDAO.toggleActiveStatus(productId, isActive);
    }

    public static void deleteProduct(Id productId) {
        ProductDAO.deleteProduct(productId);
    }
}
