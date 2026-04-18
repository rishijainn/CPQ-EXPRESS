public without sharing class UserController {

    // ── Get all users ─────────────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        try {
            return UserService.getUsers();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Get stats ─────────────────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getUserStats() {
        try {
            return UserService.getUserStats();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Get available profiles ────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Profile> getProfiles() {
        try {
            return UserService.getProfiles();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Create new user ───────────────────────────────────────────────────
    @AuraEnabled
    public static String createUser(
            String firstName,
            String lastName,
            String email,
            String username,
            String role) {
        try {
            return UserService.createUser(
                firstName, lastName, email, username, role);
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ── Deactivate user ───────────────────────────────────────────────────
    @AuraEnabled
    public static void deactivateUser(Id userId) {
        try {
            UserService.deactivateUser(userId);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}