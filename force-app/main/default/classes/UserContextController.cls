public with sharing class UserContextController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentUserContext() {
        try {
            return UserContextService.getCurrentUserContext();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}