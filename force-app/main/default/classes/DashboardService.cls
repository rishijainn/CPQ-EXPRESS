public with sharing class DashboardService {

    public static Map<String, Object> getDraftPipeline() {
        AggregateResult result = DashboardDAO.getDraftPipelineAgg();
        return new Map<String, Object>{
            'count'       => (Integer) result.get('quoteCount'),
            'totalAmount' => (Decimal) result.get('totalAmount')
        };
    }

    public static Map<String, Object> getHighMarginDeals() {
        AggregateResult result = DashboardDAO.getHighMarginDealsAgg();
        return new Map<String, Object>{
            'count'       => (Integer) result.get('quoteCount'),
            'totalAmount' => (Decimal) result.get('totalAmount')
        };
    }

    public static Map<String, Object> getWonThisMonth() {
        AggregateResult result = DashboardDAO.getWonThisMonthAgg();
        return new Map<String, Object>{
            'count'       => (Integer) result.get('quoteCount'),
            'totalAmount' => (Decimal) result.get('totalAmount')
        };
    }

    public static List<Quote> getRecentQuotes() {
        return DashboardDAO.getRecentQuotes();
    }

    public static Integer getTotalQuoteCount() {
        return DashboardDAO.getTotalQuoteCount();
    }
}
