public with sharing class OpportunityController {

    // ── Get all opportunities for dropdown ────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities() {
        return OpportunityService.getOpportunities();
    }

    // ── Get opportunities for a specific account ──────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunitiesByAccountId(Id accountId) {
        return OpportunityService.getOpportunitiesByAccountId(accountId);
    }

    // ── Get single opportunity (to auto-fill Account) ─────────────────────
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityById(Id oppId) {
        return OpportunityService.getOpportunityById(oppId);
    }

    // ── Create new opportunity ────────────────────────────────────────────
    @AuraEnabled
    public static Id createOpportunity(
            String name,
            Id accountId,
            String stageName,
            Date closeDate,
            Decimal amount) {
        return OpportunityService.createOpportunity(
            name, accountId, stageName, closeDate, amount);
    }

    @AuraEnabled
    public static void deleteOpportunity(Id oppId) {
        OpportunityService.deleteOpportunity(oppId);
    }
}