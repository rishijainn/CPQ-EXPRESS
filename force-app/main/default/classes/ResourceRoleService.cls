public with sharing class ResourceRoleService {

    public static List<Resource_Role__c> getResourceRoles(String statusFilter) {
        String query = 'SELECT Id, Name, Name__c, Location__c, ' +
                       'Billing_Unit__c, Price__c, Cost__c, ' +
                       'Tags__c, Is_Active__c ' +
                       'FROM Resource_Role__c WHERE Id != null';

        if (String.isNotBlank(statusFilter)) {
            if (statusFilter == 'Active') {
                query += ' AND Is_Active__c = true';
            } else if (statusFilter == 'Inactive') {
                query += ' AND Is_Active__c = false';
            }
        }

        query += ' ORDER BY Name__c ASC';
        return ResourceRoleDAO.getResourceRoles(query);
    }

    public static Id createResourceRole(Id id, String name, String location,
                                        String billingUnit, Decimal price,
                                        Decimal cost, String tags) {
        Resource_Role__c role = new Resource_Role__c();
        if (id != null) role.Id = id;

        role.Name__c         = name;
        role.Location__c     = location;
        role.Billing_Unit__c = billingUnit;
        role.Price__c        = price;
        role.Cost__c         = cost;
        role.Tags__c         = tags;
        if (id == null) role.Is_Active__c = true;

        return ResourceRoleDAO.upsertResourceRole(role);
    }

    public static void toggleActiveStatus(Id roleId, Boolean isActive) {
        ResourceRoleDAO.toggleActiveStatus(roleId, isActive);
    }

    public static void deleteResourceRole(Id roleId) {
        ResourceRoleDAO.deleteResourceRole(roleId);
    }
}
