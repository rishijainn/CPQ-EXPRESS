public with sharing class AddonDAO {

    public static List<Add_On__c> getAddons(String query) {
        return Database.query(query);
    }

    public static Id upsertAddon(Add_On__c a) {
        upsert a;
        return a.Id;
    }

    public static void toggleActiveStatus(Id addonId, Boolean isActive) {
        update new Add_On__c(Id = addonId, Is_Active__c = isActive);
    }

    public static void deleteAddon(Id addonId) {
        delete new Add_On__c(Id = addonId);
    }
}
