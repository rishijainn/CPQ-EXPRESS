public with sharing class QuoteController {

    // ── Get all quotes with optional filters ──────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Quote> getQuotes(
            String statusFilter,
            String accountFilter) {
        return QuoteService.getQuotes(statusFilter, accountFilter);
    }

    // ── Get single quote by Id ────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static Quote getQuoteById(Id quoteId) {
        return QuoteService.getQuoteById(quoteId);
    }

    // ── Create quote ──────────────────────────────────────────────────────
    @AuraEnabled
    public static Id createQuote(
            Id opportunityId,
            Id accountId,
            String description,
            Date startDate,
            Date endDate,
            String timePeriod) {
        return QuoteService.createQuote(
            opportunityId, accountId, description,
            startDate, endDate, timePeriod);
    }

    // ── Update quote fields ───────────────────────────────────────────────
    @AuraEnabled
    public static void updateQuote(Quote quote) {
        QuoteService.updateQuote(quote);
    }

    // ── Delete quote ──────────────────────────────────────────────────────
    @AuraEnabled
    public static void deleteQuote(Id quoteId) {
        QuoteService.deleteQuote(quoteId);
    }

    // ── Clone quote ───────────────────────────────────────────────────────
    @AuraEnabled
    public static Id cloneQuote(Id quoteId, Id accountId) {
        return QuoteService.cloneQuote(quoteId, accountId);
    }

    // ── Submit for approval ───────────────────────────────────────────────
    @AuraEnabled
    public static void submitForApproval(Id quoteId, String comment) {
        try {
            QuoteService.submitForApproval(quoteId, comment);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Approve quote ─────────────────────────────────────────────────────
    @AuraEnabled
    public static void approveQuote(Id quoteId) {
        try {
            QuoteService.approveQuote(quoteId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Reject quote ──────────────────────────────────────────────────────
    @AuraEnabled
    public static void rejectQuote(Id quoteId, String reason) {
        try {
            QuoteService.rejectQuote(quoteId, reason);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Recall quote ──────────────────────────────────────────────────────
    @AuraEnabled
    public static void recallQuote(Id quoteId) {
        try {
            QuoteService.recallQuote(quoteId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Get all accounts for filter dropdown ──────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsForFilter() {
        return QuoteService.getAccountsForFilter();
    }

    // ── Recalculate quote totals from line items ──────────────────────────
    // Kept public so QuoteLineItemService can call it cross-module
    @AuraEnabled
    public static void recalculateQuoteTotals(Id quoteId) {
        QuoteService.recalculateQuoteTotals(quoteId);
    }

    // ── Helper: Count Business Days (Excl. Weekends) ──────────────────────
    // Kept public for any external consumer
    public static Integer countBusinessDays(Date d1, Date d2) {
        return QuoteService.countBusinessDays(d1, d2);
    }
}