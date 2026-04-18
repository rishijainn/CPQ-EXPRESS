public with sharing class QuotePdfController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getQuotePdfData(Id quoteId) {
        try {
            return QuotePdfService.getQuotePdfData(quoteId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}