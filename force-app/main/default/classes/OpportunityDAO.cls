public with sharing class OpportunityDAO {

    public static List<Opportunity> getOpportunities() {
        return [
            SELECT Id, Name, AccountId, Account.Name,
                   StageName, CloseDate, Amount
            FROM Opportunity
            WHERE IsClosed = false
            ORDER BY Name ASC
        ];
    }

    public static List<Opportunity> getOpportunitiesByAccountId(Id accountId) {
        return [
            SELECT Id, Name, AccountId, Account.Name,
                   StageName, CloseDate, Amount
            FROM Opportunity
            WHERE AccountId = :accountId AND IsClosed = false
            ORDER BY Name ASC
        ];
    }

    public static Opportunity getOpportunityById(Id oppId) {
        return [
            SELECT Id, Name, AccountId, Account.Name
            FROM Opportunity
            WHERE Id = :oppId
            LIMIT 1
        ];
    }

    public static Id insertOpportunity(Opportunity opp) {
        insert opp;
        return opp.Id;
    }

    public static void deleteOpportunity(Id oppId) {
        delete [SELECT Id FROM Opportunity WHERE Id = :oppId];
    }
}
