@isTest
private class AddonModuleTest {
    @isTest
    static void testAddonModule() {
        // Test create
        Id addonId = AddonController.createAddon(null, 'Test Addon', 'Each', 20, 10, 'Test');
        System.assertNotEquals(null, addonId, 'Addon should be created');
        
        // Test update
        AddonController.createAddon(addonId, 'Updated Addon', 'Each', 25, 15, 'Test');
        
        // Test get
        List<Add_On__c> addons = AddonController.getAddons('Updated');
        System.assertEquals(1, addons.size(), 'Should find updated addon');
        
        List<Add_On__c> allAddons = AddonController.getAddons('');
        System.assertEquals(1, allAddons.size(), 'Should find 1 addon');
        
        // Test toggle active
        AddonController.toggleActiveStatus(addonId, false);
        System.assertEquals(false, AddonController.getAddons('')[0].Is_Active__c, 'Addon should be inactive');
        
        // Test delete
        AddonController.deleteAddon(addonId);
        System.assertEquals(0, AddonController.getAddons('').size(), 'Addon should be deleted');
    }
}
