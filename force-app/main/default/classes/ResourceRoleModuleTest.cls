@isTest
private class ResourceRoleModuleTest {
    @isTest
    static void testResourceRoleModule() {
        // Test create
        Id roleId = ResourceRoleController.createResourceRole(null, 'Test Role', 'Onshore', 'Hour', 100, 50, 'Test');
        System.assertNotEquals(null, roleId, 'Role should be created');
        
        // Test update
        ResourceRoleController.createResourceRole(roleId, 'Updated Role', 'Offshore', 'Hour', 80, 40, 'Test');
        
        // Test get
        List<Resource_Role__c> allRoles = ResourceRoleController.getResourceRoles('All');
        System.assertEquals(1, allRoles.size(), 'Should find 1 role');
        
        List<Resource_Role__c> activeRoles = ResourceRoleController.getResourceRoles('Active');
        System.assertEquals(1, activeRoles.size(), 'Should find active role');
        
        // Test toggle
        ResourceRoleController.toggleActiveStatus(roleId, false);
        List<Resource_Role__c> inactiveRoles = ResourceRoleController.getResourceRoles('Inactive');
        System.assertEquals(1, inactiveRoles.size(), 'Should find inactive role');
        
        // Test delete
        ResourceRoleController.deleteResourceRole(roleId);
        System.assertEquals(0, ResourceRoleController.getResourceRoles('All').size(), 'Role should be deleted');
    }
}
