public with sharing class AccountService {

    public static List<Account> getAllAccounts() {
        return AccountDAO.getAllAccounts();
    }

    public static List<Account> getAccounts(String typeFilter, String industryFilter) {
        String query = 'SELECT Id, Name, AccountNumber, Type, ' +
                       'Industry, Website, Phone ' +
                       'FROM Account WHERE Id != null';

        if (String.isNotBlank(typeFilter) && typeFilter != 'All') {
            query += ' AND Type = \'' + String.escapeSingleQuotes(typeFilter) + '\'';
        }

        if (String.isNotBlank(industryFilter) && industryFilter != 'All') {
            query += ' AND Industry = \'' + String.escapeSingleQuotes(industryFilter) + '\'';
        }

        query += ' ORDER BY Name ASC';
        return AccountDAO.getAccounts(query);
    }

    public static Id createAccount(String name, String type, String industry,
                                   String website, String phone) {
        Account acc  = new Account();
        acc.Name     = name;
        acc.Type     = type;
        acc.Industry = industry;
        acc.Website  = website;
        acc.Phone    = phone;
        return AccountDAO.insertAccount(acc);
    }

    public static void deleteAccount(Id accountId) {
        AccountDAO.deleteAccount(accountId);
    }

    public static List<String> getAccountTypes() {
        List<String> types = new List<String>();
        for (Schema.PicklistEntry entry : AccountDAO.getAccountTypePicklistValues()) {
            types.add(entry.getValue());
        }
        return types;
    }

    public static List<String> getAccountIndustries() {
        List<String> industries = new List<String>();
        for (Schema.PicklistEntry entry : AccountDAO.getAccountIndustryPicklistValues()) {
            industries.add(entry.getValue());
        }
        return industries;
    }
}
