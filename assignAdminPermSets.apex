Id adminId = UserInfo.getUserId();

List<PermissionSet> permSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('CPQ_Manager_Access', 'Provus_CPQ_Base')];

List<PermissionSetAssignment> existing = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :adminId];
Set<Id> assignedIds = new Set<Id>();
for (PermissionSetAssignment psa : existing) {
    assignedIds.add(psa.PermissionSetId);
}

List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
for (PermissionSet ps : permSets) {
    if (!assignedIds.contains(ps.Id)) {
        assignments.add(new PermissionSetAssignment(AssigneeId = adminId, PermissionSetId = ps.Id));
    }
}

if (!assignments.isEmpty()) {
    insert assignments;
}
