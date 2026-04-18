public with sharing class OrganizationSettingsDAO {

    public static List<Organization_Settings__c> getSettings() {
        return [
            SELECT Id, Company_Name__c, Email__c,
                   Phone__c, Website__c, Address__c,
                   City__c, State__c, Zip_Code__c,
                   Country__c, Logo_URL__c
            FROM Organization_Settings__c
            LIMIT 1
        ];
    }

    public static List<Organization_Settings__c> getExisting() {
        return [
            SELECT Id FROM Organization_Settings__c
            LIMIT 1
        ];
    }

    public static void upsertSettings(Organization_Settings__c settings) {
        upsert settings;
    }
}
