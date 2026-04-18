@isTest
public class TestDataFactory {
    public static Account createAccount(Boolean doInsert) {
        Account acc = new Account(
            Name = 'Test Account',
            Type = 'Prospect',
            Industry = 'Technology',
            Website = 'www.test.com',
            Phone = '1234567890'
        );
        if (doInsert) insert acc;
        return acc;
    }
    
    public static Opportunity createOpportunity(Id accId, Boolean doInsert) {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = accId,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 10000
        );
        if (doInsert) insert opp;
        return opp;
    }
    
    public static Quote createQuote(Id oppId, Boolean doInsert) {
        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = oppId,
            Status = 'Draft',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Time_Period__c = 'Months',
            Description = 'Test Description'
        );
        if (doInsert) insert q;
        return q;
    }
    
    public static Product__c createProduct(Boolean doInsert) {
        Product__c p = new Product__c(
            Name__c = 'Test Product',
            Billing_Unit__c = 'Each',
            Price__c = 100,
            Cost__c = 50,
            Tags__c = 'Test',
            Is_Active__c = true
        );
        if (doInsert) insert p;
        return p;
    }
    
    public static Add_On__c createAddon(Boolean doInsert) {
        Add_On__c a = new Add_On__c(
            Name__c = 'Test Addon',
            Billing_Unit__c = 'Each',
            Price__c = 20,
            Cost__c = 10,
            Tags__c = 'Test',
            Is_Active__c = true
        );
        if (doInsert) insert a;
        return a;
    }
    
    public static Resource_Role__c createResourceRole(Boolean doInsert) {
        Resource_Role__c r = new Resource_Role__c(
            Name__c = 'Test Role',
            Location__c = 'Onshore',
            Billing_Unit__c = 'Hour',
            Price__c = 150,
            Cost__c = 100,
            Tags__c = 'Test',
            Is_Active__c = true
        );
        if (doInsert) insert r;
        return r;
    }
    
    public static Quote_Line_Item__c createQuoteLineItem(Id quoteId, String type, Id itemId, Boolean doInsert) {
        Quote_Line_Item__c qli = new Quote_Line_Item__c(
            Quote__c = quoteId,
            Item_Type__c = type,
            Phase__c = 'Phase 1',
            Quantity__c = 1,
            Base_Rate__c = 100,
            Unit_Price__c = 100,
            Cost__c = 50,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30)
        );
        if (type == 'Product') {
            qli.Product__c = itemId;
            qli.Name = 'Test Product';
        } else if (type == 'Add-on') {
            qli.Add_On__c = itemId;
            qli.Name = 'Test Addon';
        } else if (type == 'Resource Role') {
            qli.Resource_Role__c = itemId;
            qli.Name = 'Test Role';
        }
        
        if (doInsert) insert qli;
        return qli;
    }
    
    public static Organization_Settings__c createOrgSettings(Boolean doInsert) {
        Organization_Settings__c settings = new Organization_Settings__c(
            Company_Name__c = 'Test Org',
            Email__c = 'test@example.com',
            Phone__c = '555-5555',
            Website__c = 'www.test.com',
            Address__c = '123 Test St',
            City__c = 'Testville',
            State__c = 'TS',
            Zip_Code__c = '12345',
            Country__c = 'Testland'
        );
        if (doInsert) insert settings;
        return settings;
    }
}
