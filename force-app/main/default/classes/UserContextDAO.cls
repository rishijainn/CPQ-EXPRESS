public with sharing class UserContextDAO {

    public static User getCurrentUser() {
        return [
            SELECT Id, Name, Email, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }
}
