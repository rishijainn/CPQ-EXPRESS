public with sharing class QuoteLineItemController {

    // ── Get all line items for a quote ────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Quote_Line_Item__c> getLineItems(Id quoteId) {
        return QuoteLineItemService.getLineItems(quoteId);
    }

    // ── Get empty phases stored on the Quote ──────────────────────────────
    @AuraEnabled(cacheable=true)
    public static String getPhaseList(Id quoteId) {
        return QuoteLineItemService.getPhaseList(quoteId);
    }

    // ── Save empty phases back to the Quote ───────────────────────────────
    @AuraEnabled
    public static void savePhaseList(Id quoteId, String phaseList) {
        QuoteLineItemService.savePhaseList(quoteId, phaseList);
    }

    // ── Delete a phase and move items to Default ──────────────────────────
    @AuraEnabled
    public static void deletePhase(Id quoteId, String phaseName) {
        QuoteLineItemService.deletePhase(quoteId, phaseName);
    }

    // ── Add line items from modal selection ───────────────────────────────
    @AuraEnabled
    public static void addLineItems(
            Id quoteId,
            List<Id> resourceRoleIds,
            List<Id> productIds,
            List<Id> addonIds,
            String phase) {
        QuoteLineItemService.addLineItems(
            quoteId, resourceRoleIds, productIds, addonIds, phase);
    }

    // ── Update a single line item ─────────────────────────────────────────
    @AuraEnabled
    public static void updateLineItem(Quote_Line_Item__c item) {
        QuoteLineItemService.updateLineItem(item);
    }

    // ── Delete a single line item ─────────────────────────────────────────
    @AuraEnabled
    public static void deleteLineItem(Id itemId) {
        QuoteLineItemService.deleteLineItem(itemId);
    }

    // ── Delete multiple line items ────────────────────────────────────────
    @AuraEnabled
    public static void deleteLineItems(List<Id> itemIds) {
        QuoteLineItemService.deleteLineItems(itemIds);
    }

    // ── Get line items grouped by type for summary cards ──────────────────
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLineItemSummary(Id quoteId) {
        return QuoteLineItemService.getLineItemSummary(quoteId);
    }

    // ── Get line items grouped by phase for phase table ───────────────────
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getLineItemsByPhase(Id quoteId) {
        return QuoteLineItemService.getLineItemsByPhase(quoteId);
    }

    // ── Helper: Get hour multiplier for a given Time Period ─────────────────
    // Kept public so QuoteController/QuoteService can reference if needed
    public static Decimal getPeriodMultiplier(String period) {
        return QuoteLineItemService.getPeriodMultiplier(period);
    }
}