public without sharing class UserDAO {

    public static List<User> getUsers() {
        return [
            SELECT Id, FirstName, LastName, Name,
                   Email, Username, IsActive,
                   Profile.Name, UserRole.Name, LastLoginDate,
                   CreatedDate
            FROM User
            WHERE IsActive = true
            AND UserType = 'Standard'
            ORDER BY Name ASC
        ];
    }

    public static Integer countActiveUsers() {
        return [
            SELECT COUNT() FROM User
            WHERE IsActive = true
            AND Profile.Name IN ('Standard User', 'System Administrator')
        ];
    }

    public static List<Profile> getProfiles() {
        return [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN (
                'System Administrator',
                'CPQ Manager',
                'CPQ Salesperson',
                'Standard User'
            )
            ORDER BY Name ASC
        ];
    }

    public static List<Profile> findProfile(String profileName, String role) {
        return [
            SELECT Id, Name FROM Profile
            WHERE Name = :profileName
            OR Name = :role
            OR Name = :('CPQ ' + role)
            LIMIT 1
        ];
    }

    public static List<Profile> findFallbackProfile() {
        return [
            SELECT Id FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];
    }

    public static List<UserRole> findUserRole(String role) {
        return [
            SELECT Id FROM UserRole
            WHERE Name = :role
            OR Name = :('CPQ ' + role)
            LIMIT 1
        ];
    }

    public static Id insertUser(User u) {
        insert u;
        return u.Id;
    }

    public static List<PermissionSet> findPermissionSet(String psName) {
        return [
            SELECT Id FROM PermissionSet
            WHERE Name = :psName
            LIMIT 1
        ];
    }

    public static void insertPermissionSetAssignment(PermissionSetAssignment psa) {
        insert psa;
    }

    public static void deactivateUser(Id userId) {
        update new User(Id = userId, IsActive = false);
    }
}
