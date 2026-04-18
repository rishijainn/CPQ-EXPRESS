public with sharing class AddonController {

    @AuraEnabled(cacheable=true)
    public static List<Add_On__c> getAddons(String searchTerm) {
        return AddonService.getAddons(searchTerm);
    }

    @AuraEnabled
    public static Id createAddon(Id id, String name, String billingUnit,
                                 Decimal price, Decimal cost, String tags) {
        return AddonService.createAddon(id, name, billingUnit, price, cost, tags);
    }

    @AuraEnabled
    public static void toggleActiveStatus(Id addonId, Boolean isActive) {
        AddonService.toggleActiveStatus(addonId, isActive);
    }

    @AuraEnabled
    public static void deleteAddon(Id addonId) {
        AddonService.deleteAddon(addonId);
    }
}