public with sharing class AddonService {

    public static List<Add_On__c> getAddons(String searchTerm) {
        String query = 'SELECT Id, Name, Name__c, Billing_Unit__c, ' +
                       'Price__c, Cost__c, Tags__c, Is_Active__c ' +
                       'FROM Add_On__c WHERE Id != null';

        if (String.isNotBlank(searchTerm)) {
            query += ' AND Name__c LIKE \'%' +
                     String.escapeSingleQuotes(searchTerm) + '%\'';
        }

        query += ' ORDER BY Name__c ASC';
        return AddonDAO.getAddons(query);
    }

    public static Id createAddon(Id id, String name, String billingUnit,
                                 Decimal price, Decimal cost, String tags) {
        Add_On__c a = new Add_On__c();
        if (id != null) a.Id = id;

        a.Name__c         = name;
        a.Billing_Unit__c = billingUnit;
        a.Price__c        = price;
        a.Cost__c         = cost;
        a.Tags__c         = tags;
        if (id == null) a.Is_Active__c = true;

        return AddonDAO.upsertAddon(a);
    }

    public static void toggleActiveStatus(Id addonId, Boolean isActive) {
        AddonDAO.toggleActiveStatus(addonId, isActive);
    }

    public static void deleteAddon(Id addonId) {
        AddonDAO.deleteAddon(addonId);
    }
}
