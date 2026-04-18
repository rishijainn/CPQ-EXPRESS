public without sharing class UserService {

    // ── Get all users ─────────────────────────────────────────────────────
    public static List<User> getUsers() {
        return UserDAO.getUsers();
    }

    // ── Get stats ─────────────────────────────────────────────────────────
    public static Map<String, Integer> getUserStats() {
        Integer usedSeats = UserDAO.countActiveUsers();
        Integer totalSeats = 5;
        return new Map<String, Integer>{
            'totalSeats' => totalSeats,
            'usedSeats'  => usedSeats,
            'available'  => totalSeats - usedSeats
        };
    }

    // ── Get available profiles ────────────────────────────────────────────
    public static List<Profile> getProfiles() {
        return UserDAO.getProfiles();
    }

    // ── Create new user ───────────────────────────────────────────────────
    public static String createUser(String firstName, String lastName,
                                    String email, String username,
                                    String role) {
        // Enforce role logic based on current user
        Map<String, Object> ctx = UserContextService.getCurrentUserContext();
        Boolean isAdmin = (Boolean) ctx.get('isAdmin');
        if (!isAdmin) {
            role = 'User';
        }

        // Find the correct Profile
        String profileName = getProfileName(role);
        List<Profile> profiles = UserDAO.findProfile(profileName, role);

        if (profiles.isEmpty()) {
            profiles = UserDAO.findFallbackProfile();
        }

        if (profiles.isEmpty()) {
            throw new AuraHandledException(
                'No valid profile found. Please create ' +
                'CPQ Salesperson and CPQ Manager ' +
                'profiles in Setup first.'
            );
        }

        // Build alias from name
        String alias = '';
        if (String.isNotBlank(firstName)) {
            alias += firstName.substring(0, 1);
        }
        if (String.isNotBlank(lastName)) {
            alias += lastName.substring(0, Math.min(4, lastName.length()));
        }
        alias = alias.toLowerCase();
        alias = alias + String.valueOf(
            Math.abs(Math.mod(Crypto.getRandomInteger(), 99))
        );

        // Build User record
        User u = new User();
        u.FirstName         = firstName;
        u.LastName          = lastName;
        u.Email             = email;
        u.Username          = username;
        u.Alias             = alias.left(8);
        u.CommunityNickname = alias.left(40);
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey      = 'en_US';
        u.TimeZoneSidKey    = 'America/New_York';
        u.ProfileId         = profiles[0].Id;

        // Assign User Role if found
        List<UserRole> roles = UserDAO.findUserRole(role);
        if (!roles.isEmpty()) {
            u.UserRoleId = roles[0].Id;
        }

        u.IsActive = true;

        // Trigger welcome email
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        u.setOptions(dlo);

        Id userId = UserDAO.insertUser(u);

        // Auto-assign Permission Set
        assignPermissionSet(userId, role);

        return 'Success: User ' + firstName + ' ' +
               lastName + ' created successfully! ' +
               'They will receive an email to set ' +
               'their password.';
    }

    // ── Deactivate user ───────────────────────────────────────────────────
    public static void deactivateUser(Id userId) {
        if (userId == UserInfo.getUserId()) {
            throw new AuraHandledException(
                'You cannot deactivate your own account.'
            );
        }
        UserDAO.deactivateUser(userId);
    }

    // ── Helper: assign permission set based on role ───────────────────────
    private static void assignPermissionSet(Id userId, String role) {
        try {
            String psName = getPermissionSetName(role);
            List<PermissionSet> ps = UserDAO.findPermissionSet(psName);
            if (ps.isEmpty()) return;

            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId      = userId,
                PermissionSetId = ps[0].Id
            );
            UserDAO.insertPermissionSetAssignment(psa);
        } catch (Exception e) {
            System.debug('Error assigning permission set: ' + e.getMessage());
        }
    }

    // ── Helper: role → permission set name ───────────────────────────────
    private static String getPermissionSetName(String role) {
        if (role == 'Admin' || role == 'Manager') {
            return 'CPQ_Manager_Access';
        }
        return 'CPQ_Salesperson_Access';
    }

    // ── Helper: role → profile name ───────────────────────────────────────
    private static String getProfileName(String role) {
        if (role == 'Admin')   return 'System Administrator';
        if (role == 'Manager') return 'CPQ Manager';
        return 'CPQ Salesperson';
    }
}
