public with sharing class ResourceRoleDAO {

    public static List<Resource_Role__c> getResourceRoles(String query) {
        return Database.query(query);
    }

    public static Id upsertResourceRole(Resource_Role__c role) {
        upsert role;
        return role.Id;
    }

    public static void toggleActiveStatus(Id roleId, Boolean isActive) {
        update new Resource_Role__c(Id = roleId, Is_Active__c = isActive);
    }

    public static void deleteResourceRole(Id roleId) {
        delete new Resource_Role__c(Id = roleId);
    }
}
