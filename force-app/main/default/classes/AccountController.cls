public with sharing class AccountController {

    // ── Get all accounts for dropdowns ────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Account> getAllAccounts() {
        return AccountService.getAllAccounts();
    }

    // ── Get all accounts with optional filters ────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(
            String typeFilter,
            String industryFilter) {
        return AccountService.getAccounts(typeFilter, industryFilter);
    }

    // ── Create new account ────────────────────────────────────────────────
    @AuraEnabled
    public static Id createAccount(
            String name,
            String type,
            String industry,
            String website,
            String phone) {
        return AccountService.createAccount(name, type, industry, website, phone);
    }

    // ── Delete account ────────────────────────────────────────────────────
    @AuraEnabled
    public static void deleteAccount(Id accountId) {
        AccountService.deleteAccount(accountId);
    }

    // ── Get distinct types for filter dropdown ────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<String> getAccountTypes() {
        return AccountService.getAccountTypes();
    }

    // ── Get distinct industries for filter dropdown ────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<String> getAccountIndustries() {
        return AccountService.getAccountIndustries();
    }
}