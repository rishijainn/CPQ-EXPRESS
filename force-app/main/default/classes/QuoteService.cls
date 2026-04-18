public with sharing class QuoteService {

    // ── Get all quotes with optional filters ──────────────────────────────
    public static List<Quote> getQuotes(String statusFilter, String accountFilter) {
        Boolean isManager = isManagerOrAdmin();

        String query = 'SELECT Id, QuoteNumber, Name, Status, ' +
                       'OpportunityId, Opportunity.Name, ' +
                       'AccountId, Account.Name, ' +
                       'CreatedById, CreatedBy.Name, CreatedDate, ' +
                       'Total_Amount__c, GrandTotal, Calculated_Discount__c, ' +
                       'Subtotal, ExpirationDate, ' +
                       'Start_Date__c, End_Date__c, Time_Period__c, ' +
                       'Margin_Amount__c, Margin_Percent__c ' +
                       'FROM Quote WHERE Id != null';

        if (!isManager) {
            query += ' AND CreatedById = \'' + UserInfo.getUserId() + '\'';
        }

        if (String.isNotBlank(statusFilter) && statusFilter != 'All') {
            query += ' AND Status = \'' +
                     String.escapeSingleQuotes(statusFilter) + '\'';
        }

        if (String.isNotBlank(accountFilter) && accountFilter != 'All') {
            query += ' AND AccountId = \'' +
                     String.escapeSingleQuotes(accountFilter) + '\'';
        }

        query += ' ORDER BY CreatedDate DESC';
        return QuoteDAO.getQuotes(query);
    }

    // ── Get single quote by Id ────────────────────────────────────────────
    public static Quote getQuoteById(Id quoteId) {
        return QuoteDAO.getQuoteById(quoteId);
    }

    // ── Create quote ──────────────────────────────────────────────────────
    public static Id createQuote(Id opportunityId, Id accountId,
                                 String description, Date startDate,
                                 Date endDate, String timePeriod) {

        if (opportunityId == null) {
            opportunityId = getStandaloneOpportunityId(accountId);
        }

        if (endDate == null && startDate != null && timePeriod != null) {
            Integer days = 0;
            if (timePeriod == 'Days')     days = 1;
            else if (timePeriod == 'Weeks')    days = 7;
            else if (timePeriod == 'Months')   days = 30;
            else if (timePeriod == 'Quarters') days = 90;
            else if (timePeriod == 'Years')    days = 365;
            endDate = startDate.addDays(days);
        }

        Quote q = new Quote();
        q.OpportunityId  = opportunityId;
        q.Name           = 'New Quote';
        q.Description    = description;
        q.Status         = 'Draft';
        q.Start_Date__c  = startDate;
        q.End_Date__c    = endDate;
        q.Time_Period__c = timePeriod;

        return QuoteDAO.insertQuote(q);
    }

    // ── Update quote fields ───────────────────────────────────────────────
    public static void updateQuote(Quote quote) {
        Quote oldQuote = QuoteDAO.getQuoteForUpdate(quote.Id);
        Boolean periodChanged = quote.Time_Period__c != null &&
                                quote.Time_Period__c != oldQuote.Time_Period__c;

        QuoteDAO.updateQuote(quote);

        if (periodChanged) {
            syncLineItemPrices(quote.Id, quote.Time_Period__c);
        }
    }

    // ── Delete quote ──────────────────────────────────────────────────────
    public static void deleteQuote(Id quoteId) {
        QuoteDAO.deleteQuote(quoteId);
    }

    // ── Clone quote ───────────────────────────────────────────────────────
    public static Id cloneQuote(Id quoteId, Id accountId) {
        Quote original = QuoteDAO.getQuoteForClone(quoteId);

        Quote cloned   = original.clone(false, true, false, false);
        cloned.Name    = 'new quote';
        cloned.Status  = 'Draft';

        Id targetAccount = (accountId != null) ? accountId : original.AccountId;
        cloned.OpportunityId = getStandaloneOpportunityId(targetAccount);

        QuoteDAO.insertQuote(cloned);

        List<Quote_Line_Item__c> originalItems =
            QuoteDAO.getLineItemsForClone(quoteId);

        List<Quote_Line_Item__c> clonedItems = new List<Quote_Line_Item__c>();
        for (Quote_Line_Item__c item : originalItems) {
            Quote_Line_Item__c clonedItem = item.clone(false, true, false, false);
            clonedItem.Quote__c = cloned.Id;
            clonedItems.add(clonedItem);
        }

        if (!clonedItems.isEmpty()) {
            QuoteDAO.insertLineItems(clonedItems);
        }

        recalculateQuoteTotals(cloned.Id);
        return cloned.Id;
    }

    // ── Submit for approval ───────────────────────────────────────────────
    public static void submitForApproval(Id quoteId, String comment) {
        QuoteDAO.updateQuote(new Quote(Id = quoteId, Status = 'Pending Approval'));
    }

    // ── Approve quote ─────────────────────────────────────────────────────
    public static void approveQuote(Id quoteId) {
        QuoteDAO.updateQuote(new Quote(Id = quoteId, Status = 'Approved'));
    }

    // ── Reject quote ──────────────────────────────────────────────────────
    public static void rejectQuote(Id quoteId, String reason) {
        QuoteDAO.updateQuote(new Quote(Id = quoteId, Status = 'Rejected'));
    }

    // ── Recall quote ──────────────────────────────────────────────────────
    public static void recallQuote(Id quoteId) {
        QuoteDAO.updateQuote(new Quote(Id = quoteId, Status = 'Draft'));
    }

    // ── Get all accounts for filter dropdown ──────────────────────────────
    public static List<Account> getAccountsForFilter() {
        return QuoteDAO.getAccountsForFilter();
    }

    // ── Recalculate quote totals from line items ──────────────────────────
    public static void recalculateQuoteTotals(Id quoteId) {
        List<Quote_Line_Item__c> qlis = QuoteDAO.getLineItemsForRecalc(quoteId);

        Decimal revenue   = 0;
        Decimal totalCost = 0;
        Decimal subtotal  = 0;
        Date maxEndDate   = null;

        Quote currentQuote = QuoteDAO.getQuoteForRecalc(quoteId);
        Decimal multiplier =
            QuoteLineItemService.getPeriodMultiplier(currentQuote.Time_Period__c);

        for (Quote_Line_Item__c item : qlis) {
            if (item.Total_Price__c != null) revenue += item.Total_Price__c;

            Decimal lineCost     = 0;
            Decimal lineSubtotal = 0;

            if (item.Item_Type__c == 'Resource Role') {
                lineCost = (item.Cost__c != null && item.Quantity__c != null)
                    ? (item.Cost__c * multiplier * item.Quantity__c) : 0;
            } else {
                lineCost = (item.Cost__c != null && item.Quantity__c != null)
                    ? (item.Cost__c * item.Quantity__c) : 0;
            }
            lineSubtotal = (item.Unit_Price__c != null && item.Quantity__c != null)
                ? (item.Unit_Price__c * item.Quantity__c) : 0;

            totalCost += lineCost;
            subtotal  += lineSubtotal;

            if (item.End_Date__c != null) {
                if (maxEndDate == null || item.End_Date__c > maxEndDate) {
                    maxEndDate = item.End_Date__c;
                }
            }
        }

        Quote q = new Quote(Id = quoteId);
        q.Margin_Amount__c    = revenue - totalCost;
        q.Margin_Percent__c   = (revenue > 0)
            ? (q.Margin_Amount__c / revenue) * 100 : 0;
        q.Subtotal_Amount__c  = subtotal;
        q.Total_Amount__c     = revenue;
        q.Calculated_Discount__c = (subtotal > 0)
            ? ((subtotal - revenue) / subtotal) * 100 : 0;

        if (maxEndDate != null) {
            q.End_Date__c = maxEndDate;
        }

        QuoteDAO.updateQuote(q);
    }

    // ── Helper: Update line item prices when period changes ───────────────
    private static void syncLineItemPrices(Id quoteId, String newPeriod) {
        List<Quote_Line_Item__c> items =
            QuoteDAO.getResourceRoleLineItems(quoteId);

        if (items.isEmpty()) return;

        Decimal multiplier = QuoteLineItemService.getPeriodMultiplier(newPeriod);

        for (Quote_Line_Item__c item : items) {
            item.Unit_Price__c = (item.Base_Rate__c != null)
                ? (item.Base_Rate__c * multiplier) : 0;
        }

        QuoteDAO.updateLineItems(items);
        recalculateQuoteTotals(quoteId);
    }

    // ── Helper: Get or Create Standalone Opportunity ──────────────────────
    private static Id getStandaloneOpportunityId(Id accountId) {
        if (accountId == null) return null;

        List<Opportunity> existingOpps =
            QuoteDAO.getStandaloneOpportunity(accountId);

        if (!existingOpps.isEmpty()) {
            return existingOpps[0].Id;
        } else {
            Account acc = QuoteDAO.getAccountById(accountId);
            Opportunity sharedOpp = new Opportunity(
                Name      = 'Standalone Quotes - ' + acc.Name,
                AccountId = accountId,
                StageName = 'Qualifying',
                CloseDate = Date.today().addDays(365)
            );
            return QuoteDAO.insertOpportunity(sharedOpp);
        }
    }

    // ── Helper: Count Business Days (Excl. Weekends) ──────────────────────
    public static Integer countBusinessDays(Date d1, Date d2) {
        if (d1 == null || d2 == null || d2 <= d1) return 0;
        Integer businessDays = 0;
        Integer totalDays = d1.daysBetween(d2);
        for (Integer i = 0; i < totalDays; i++) {
            Date checkDate = d1.addDays(i);
            Integer dayOfWeek =
                Math.mod(Date.newInstance(1900, 1, 8).daysBetween(checkDate), 7);
            if (dayOfWeek >= 0 && dayOfWeek < 5) {
                businessDays++;
            }
        }
        return businessDays;
    }

    // ── Helper: check if current user is Manager/Admin ────────────────────
    private static Boolean isManagerOrAdmin() {
        User currentUser = QuoteDAO.getCurrentUserWithRole();
        String profileName = currentUser.Profile.Name;
        String roleName    = (currentUser.UserRole != null)
            ? currentUser.UserRole.Name : '';

        return (profileName != null &&
                (profileName.contains('Admin') ||
                 profileName.contains('Manager'))) ||
               (roleName != null && roleName.contains('Manager'));
    }
}
