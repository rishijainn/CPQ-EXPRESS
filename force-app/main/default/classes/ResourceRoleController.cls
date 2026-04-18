public with sharing class ResourceRoleController {

    // ── Get all resource roles with optional status filter ─────────────────
    @AuraEnabled(cacheable=true)
    public static List<Resource_Role__c> getResourceRoles(String statusFilter) {
        return ResourceRoleService.getResourceRoles(statusFilter);
    }

    // ── Create new resource role ──────────────────────────────────────────
    @AuraEnabled
    public static Id createResourceRole(
            Id id,
            String name,
            String location,
            String billingUnit,
            Decimal price,
            Decimal cost,
            String tags) {
        return ResourceRoleService.createResourceRole(
            id, name, location, billingUnit, price, cost, tags);
    }

    // ── Toggle active/inactive status ─────────────────────────────────────
    @AuraEnabled
    public static void toggleActiveStatus(Id roleId, Boolean isActive) {
        ResourceRoleService.toggleActiveStatus(roleId, isActive);
    }

    // ── Delete resource role ──────────────────────────────────────────────
    @AuraEnabled
    public static void deleteResourceRole(Id roleId) {
        ResourceRoleService.deleteResourceRole(roleId);
    }
}