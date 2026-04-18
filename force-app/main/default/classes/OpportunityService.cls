public with sharing class OpportunityService {

    public static List<Opportunity> getOpportunities() {
        return OpportunityDAO.getOpportunities();
    }

    public static List<Opportunity> getOpportunitiesByAccountId(Id accountId) {
        return OpportunityDAO.getOpportunitiesByAccountId(accountId);
    }

    public static Opportunity getOpportunityById(Id oppId) {
        return OpportunityDAO.getOpportunityById(oppId);
    }

    public static Id createOpportunity(String name, Id accountId,
                                       String stageName, Date closeDate,
                                       Decimal amount) {
        Opportunity opp  = new Opportunity();
        opp.Name         = name;
        opp.AccountId    = accountId;
        opp.StageName    = stageName;
        opp.CloseDate    = closeDate;
        opp.Amount       = amount;
        return OpportunityDAO.insertOpportunity(opp);
    }

    public static void deleteOpportunity(Id oppId) {
        OpportunityDAO.deleteOpportunity(oppId);
    }
}
