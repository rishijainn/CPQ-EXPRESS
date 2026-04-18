@isTest
private class OrganizationSettingsModuleTest {
    @isTest
    static void testOrganizationSettingsModule() {
        // Test get when no settings exist
        Organization_Settings__c defaultSettings = OrganizationSettingsController.getSettings();
        System.assertNotEquals(null, defaultSettings, 'Should return default settings object');
        
        // Test save new settings
        OrganizationSettingsController.saveSettings('Acme Corp', 'test@acme.com', '1234567890', 'www.acme.com', '123 St', 'City', 'State', '12345', 'Country');
        
        Organization_Settings__c savedSettings = OrganizationSettingsController.getSettings();
        System.assertEquals('Acme Corp', savedSettings.Company_Name__c, 'Company name should be saved');
        
        // Test update existing
        OrganizationSettingsController.saveSettings('Acme Corp Updated', 'test@acme.com', '1234567890', 'www.acme.com', '123 St', 'City', 'State', '12345', 'Country');
        
        Organization_Settings__c updatedSettings = OrganizationSettingsController.getSettings();
        System.assertEquals('Acme Corp Updated', updatedSettings.Company_Name__c, 'Company name should be updated');
    }
}
