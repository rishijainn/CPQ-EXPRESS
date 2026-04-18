@isTest
private class AccountModuleTest {
    @isTest
    static void testAccountModule() {
        // Test creation
        Id accId = AccountController.createAccount('Acme Corp', 'Prospect', 'Technology', 'www.acme.com', '1231231234');
        System.assertNotEquals(null, accId, 'Account should be created');
        
        // Test getAllAccounts
        List<Account> allAccs = AccountController.getAllAccounts();
        System.assertEquals(1, allAccs.size(), 'Should find 1 account');
        
        // Test getAccounts with filters
        List<Account> filteredAccs = AccountController.getAccounts('Prospect', 'Technology');
        System.assertEquals(1, filteredAccs.size(), 'Should find account with filters');
        
        List<Account> emptyFilters = AccountController.getAccounts('All', 'All');
        System.assertEquals(1, emptyFilters.size(), 'Should find account with All/All');
        
        List<Account> noMatchAccs = AccountController.getAccounts('Customer', 'Healthcare');
        System.assertEquals(0, noMatchAccs.size(), 'Should not find any match');
        
        // Test picklist retrievals
        List<String> types = AccountController.getAccountTypes();
        System.assert(!types.isEmpty(), 'Should return account types');
        
        List<String> industries = AccountController.getAccountIndustries();
        System.assert(!industries.isEmpty(), 'Should return account industries');
        
        // Test deletion
        AccountController.deleteAccount(accId);
        List<Account> remaining = AccountController.getAllAccounts();
        System.assertEquals(0, remaining.size(), 'Account should be deleted');
    }
}
