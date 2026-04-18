public with sharing class OrganizationSettingsController {

    // ── Get org settings (always returns one record) ──────────────────────
    @AuraEnabled(cacheable=true)
    public static Organization_Settings__c getSettings() {
        try {
            return OrganizationSettingsService.getSettings();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Save org settings (upsert — create or update) ─────────────────────
    @AuraEnabled
    public static void saveSettings(
            String companyName,
            String email,
            String phone,
            String website,
            String address,
            String city,
            String state,
            String zipCode,
            String country) {
        try {
            OrganizationSettingsService.saveSettings(
                companyName, email, phone, website,
                address, city, state, zipCode, country);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}