public with sharing class OrganizationSettingsService {

    public static Organization_Settings__c getSettings() {
        List<Organization_Settings__c> settings = OrganizationSettingsDAO.getSettings();

        if (!settings.isEmpty()) {
            return settings[0];
        }

        // Return empty record if none exists yet
        return new Organization_Settings__c(
            Company_Name__c = '',
            Email__c        = '',
            Phone__c        = '',
            Website__c      = '',
            Address__c      = '',
            City__c         = '',
            State__c        = '',
            Zip_Code__c     = '',
            Country__c      = ''
        );
    }

    public static void saveSettings(String companyName, String email,
                                    String phone, String website,
                                    String address, String city,
                                    String state, String zipCode,
                                    String country) {
        List<Organization_Settings__c> existing = OrganizationSettingsDAO.getExisting();
        Organization_Settings__c settings;

        if (!existing.isEmpty()) {
            settings = existing[0];
        } else {
            settings = new Organization_Settings__c();
        }

        settings.Company_Name__c = companyName;
        settings.Email__c        = email;
        settings.Phone__c        = phone;
        settings.Website__c      = website;
        settings.Address__c      = address;
        settings.City__c         = city;
        settings.State__c        = state;
        settings.Zip_Code__c     = zipCode;
        settings.Country__c      = country;

        OrganizationSettingsDAO.upsertSettings(settings);
    }
}
