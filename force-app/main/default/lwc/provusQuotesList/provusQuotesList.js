import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getQuotes from
    '@salesforce/apex/QuoteController.getQuotes';
import getAccountsForFilter from
    '@salesforce/apex/QuoteController.getAccountsForFilter';
import deleteQuote from
    '@salesforce/apex/QuoteController.deleteQuote';
import cloneQuote from
    '@salesforce/apex/QuoteController.cloneQuote';
import getCurrentUserContext from
    '@salesforce/apex/UserContextController.getCurrentUserContext';

const PAGE_SIZE = 10;

export default class ProvusQuotesList extends LightningElement {

    @track showCreateModal = false;
    @track statusFilter    = 'All';
    @track accountFilter   = 'All';
    @track searchTerm      = '';
    @track currentPage     = 1;
    @track isManager       = false;
    
    // Clone modal state
    @track isCloneModalOpen    = false;
    @track cloningQuoteId      = '';
    @track cloningQuoteNumber  = '';
    @track targetAccountId     = '';
    @track isCloning          = false;

    // ── IMPORTANT: initialize to undefined ───────────────────────────────
    wiredQuotesResult      = undefined;
    @track allQuotes       = [];
    @track accountOptions  = [];

    @wire(getCurrentUserContext)
    wiredContext({ data }) {
        if (data) {
            this.isManager = data.isManager;
        }
    }

    _hasRendered = false;

    renderedCallback() {
        if (!this._hasRendered) {
            this._hasRendered = true;
            // The component has mounted. Force a background refresh in case data changed.
            setTimeout(() => {
                if (this.wiredQuotesResult) {
                    refreshApex(this.wiredQuotesResult);
                }
            }, 100);
        }
    }

    // ── Wire accounts for filter ──────────────────────────────────────────
    @wire(getAccountsForFilter)
    wiredAccounts({ data, error }) {
        if (data)  this.accountOptions = data;
        if (error) console.error('Accounts error:', error);
    }

    // ── Wire quotes ───────────────────────────────────────────────────────
    @wire(getQuotes, {
        statusFilter:  '$statusFilter',
        accountFilter: '$accountFilter'
    })
    wiredQuotes(result) {
        // Store the full result for refreshApex
        this.wiredQuotesResult = result;

        if (result.data) {
            this.allQuotes = result.data.map((q, index) => {
                return {
                    ...q,
                    rowNumber: index + 1,
                    opportunityName: q.Opportunity
                        ? q.Opportunity.Name : 'N/A',
                    accountName: q.Account
                        ? q.Account.Name : '-',
                    createdByName: q.CreatedBy
                        ? q.CreatedBy.Name : '-',
                    formattedDate: q.CreatedDate
                        ? new Date(q.CreatedDate)
                            .toLocaleDateString('en-US')
                        : '-',
                    formattedAmount: q.Total_Amount__c != null
                        ? '$' + Number(q.Total_Amount__c)
                            .toLocaleString('en-US', {
                                minimumFractionDigits: 2,
                                maximumFractionDigits: 2
                            })
                        : '$0.00',
                    formattedDiscount: q.Calculated_Discount__c != null
                        ? Number(q.Calculated_Discount__c).toFixed(2) + '%' : '-',
                    formattedMargin: q.Margin_Percent__c != null
                        ? Number(q.Margin_Percent__c)
                            .toFixed(2) + '%'
                        : '-'
                };
            });
        } else if (result.error) {
            console.error('Quotes wire error:', result.error);
            this.allQuotes = [];
        }
    }

    // ── Computed: filtered quotes ─────────────────────────────────────────
    get filteredQuotes() {
        if (!this.searchTerm) return this.allQuotes;
        const term = this.searchTerm.toLowerCase();
        return this.allQuotes.filter(q =>
            (q.QuoteNumber || '').toLowerCase().includes(term) ||
            (q.accountName || '').toLowerCase().includes(term) ||
            (q.opportunityName || '').toLowerCase().includes(term)
        );
    }

    // ── Pagination getters ────────────────────────────────────────────────
    get totalRecords() { return this.filteredQuotes.length; }

    get totalPages() {
        return Math.max(1,
            Math.ceil(this.totalRecords / PAGE_SIZE));
    }

    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage()  { return this.currentPage >= this.totalPages; }
    get isEmpty()     { return this.filteredQuotes.length === 0; }

    get startRecord() {
        return this.totalRecords === 0
            ? 0
            : (this.currentPage - 1) * PAGE_SIZE + 1;
    }

    get endRecord() {
        return Math.min(
            this.currentPage * PAGE_SIZE,
            this.totalRecords
        );
    }

    get paginatedQuotes() {
        const start = (this.currentPage - 1) * PAGE_SIZE;
        const end   = start + PAGE_SIZE;
        return this.filteredQuotes.slice(start, end);
    }

    // ── Handlers ──────────────────────────────────────────────────────────
    handleSearch(event) {
        this.searchTerm  = event.target.value;
        this.currentPage = 1;
    }

    handleStatusFilter(event) {
        this.statusFilter = event.target.value;
        this.currentPage  = 1;
    }

    handleAccountFilter(event) {
        this.accountFilter = event.target.value;
        this.currentPage   = 1;
    }

    handleNew() {
        this.showCreateModal = true;
    }

    handleModalClose() {
        this.showCreateModal = false;
    }

    handleQuoteCreated(event) {
        this.showCreateModal = false;
        // ── FIX: NO bubbles/composed ──────────────────────────────────
        this.dispatchEvent(new CustomEvent('viewquote', {
            detail: { quoteId: event.detail.quoteId }
        }));
    }

    // Click on quote ID link OR row
    handleQuoteClick(event) {
        event.stopPropagation();
        const quoteId = event.currentTarget.dataset.id;
        // ── FIX: NO bubbles/composed ──────────────────────────────────
        this.dispatchEvent(new CustomEvent('viewquote', {
            detail: { quoteId: quoteId }
        }));
    }

    handleRowClick(event) {
        const quoteId = event.currentTarget.dataset.id;
        // ── FIX: NO bubbles/composed ──────────────────────────────────
        this.dispatchEvent(new CustomEvent('viewquote', {
            detail: { quoteId: quoteId }
        }));
    }

    handleRefresh() {
        // ── FIX: only refresh if wire result exists ────────────────────
        if (this.wiredQuotesResult) {
            refreshApex(this.wiredQuotesResult);
        }
    }

    handleClone(event) {
        event.stopPropagation();
        const quoteId = event.currentTarget.dataset.id;
        const quote = this.allQuotes.find(q => q.Id === quoteId);
        
        if (quote) {
            this.cloningQuoteId = quoteId;
            this.cloningQuoteNumber = quote.QuoteNumber;
            this.targetAccountId = ''; // Default to original
            this.isCloneModalOpen = true;
        }
    }

    handleCloneCancel() {
        this.isCloneModalOpen = false;
        this.cloningQuoteId = '';
        this.cloningQuoteNumber = '';
        this.targetAccountId = '';
    }

    handleCloneAccountChange(event) {
        this.targetAccountId = event.target.value;
    }

    handleCloneConfirm() {
        if (!this.cloningQuoteId) return;

        this.isCloning = true;
        cloneQuote({ 
            quoteId: this.cloningQuoteId, 
            accountId: this.targetAccountId || null 
        })
            .then((newQuoteId) => {
                this.isCloneModalOpen = false;
                // Success toast or navigation
                this.dispatchEvent(new CustomEvent('viewquote', {
                    detail: { quoteId: newQuoteId }
                }));
                if (this.wiredQuotesResult) {
                    refreshApex(this.wiredQuotesResult);
                }
            })
            .catch(error => {
                console.error('Clone error:', error);
            })
            .finally(() => {
                this.isCloning = false;
            });
    }

    handleDelete(event) {
        event.stopPropagation();
        const quoteId = event.currentTarget.dataset.id;
        // eslint-disable-next-line no-alert
        if (!confirm('Delete this quote? This cannot be undone.')) {
            return;
        }

        deleteQuote({ quoteId: quoteId })
            .then(() => {
                if (this.wiredQuotesResult) {
                    return refreshApex(this.wiredQuotesResult);
                }
            })
            .catch(error => {
                console.error('Delete error:', error);
            });
    }

    handlePrevPage() {
        if (!this.isFirstPage) this.currentPage--;
    }

    handleNextPage() {
        if (!this.isLastPage) this.currentPage++;
    }

    stopPropagation(event) {
        event.stopPropagation();
    }
}