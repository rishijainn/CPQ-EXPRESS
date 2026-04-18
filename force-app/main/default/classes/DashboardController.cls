public with sharing class DashboardController {

    // ── Draft Pipeline card ───────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDraftPipeline() {
        return DashboardService.getDraftPipeline();
    }

    // ── High Margin Deals card ────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getHighMarginDeals() {
        return DashboardService.getHighMarginDeals();
    }

    // ── Won This Month card ───────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWonThisMonth() {
        return DashboardService.getWonThisMonth();
    }

    // ── Recent quotes for right panel ─────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Quote> getRecentQuotes() {
        return DashboardService.getRecentQuotes();
    }

    // ── Total quote count for "X quotes total" label ──────────────────────
    @AuraEnabled(cacheable=true)
    public static Integer getTotalQuoteCount() {
        return DashboardService.getTotalQuoteCount();
    }
}