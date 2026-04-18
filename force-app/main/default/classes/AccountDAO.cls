public with sharing class AccountDAO {

    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name FROM Account ORDER BY Name ASC];
    }

    public static List<Account> getAccounts(String query) {
        return Database.query(query);
    }

    public static Id insertAccount(Account acc) {
        insert acc;
        return acc.Id;
    }

    public static void deleteAccount(Id accountId) {
        delete new Account(Id = accountId);
    }

    public static List<Schema.PicklistEntry> getAccountTypePicklistValues() {
        return Account.Type.getDescribe().getPicklistValues();
    }

    public static List<Schema.PicklistEntry> getAccountIndustryPicklistValues() {
        return Account.Industry.getDescribe().getPicklistValues();
    }
}
