public with sharing class UserContextService {

    public static Map<String, Object> getCurrentUserContext() {
        User u = UserContextDAO.getCurrentUser();

        String profileName = u.Profile.Name;
        String roleName    = (u.UserRole != null) ? u.UserRole.Name : '';

        // Managers and Admins have full access
        Boolean isManager = (profileName != null &&
                             (profileName.contains('System Administrator') ||
                              profileName.contains('Manager'))) ||
                            (roleName != null && roleName.contains('Manager'));

        // Salespeople have restricted access (fallback if not manager/admin)
        Boolean isSalesperson = !isManager;

        return new Map<String, Object>{
            'userId'        => u.Id,
            'userName'      => u.Name,
            'email'         => u.Email,
            'profileName'   => profileName,
            'isManager'     => isManager,
            'isSalesperson' => isSalesperson,
            'isAdmin'       => (profileName != null && profileName.contains('Admin')) ||
                               (roleName != null && roleName.contains('Admin'))
        };
    }
}
