Id userId = '005C2000007nlmeIAA';

List<PermissionSet> permSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('CPQ_Salesperson_Access', 'Provus_CPQ_Base')];

List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
for (PermissionSet ps : permSets) {
    assignments.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id));
}

insert assignments;
