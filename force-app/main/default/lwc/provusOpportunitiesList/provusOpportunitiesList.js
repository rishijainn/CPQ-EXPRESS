import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOpportunities from '@salesforce/apex/OpportunityController.getOpportunities';
import createOpportunity from '@salesforce/apex/OpportunityController.createOpportunity';
import deleteOpportunity from '@salesforce/apex/OpportunityController.deleteOpportunity';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

const PAGE_SIZE = 10;

export default class ProvusOpportunitiesList extends LightningElement {

    @track allOpportunities = [];
    @track accountOptions   = [];
    @track currentPage      = 1;
    @track showModal        = false;
    @track isSaving         = false;
    @track errorMessage     = '';

    // Form fields
    @track formData = {
        name: '', accountId: '', stageName: 'Prospecting',
        closeDate: '', amount: 0
    };

    wiredOppsResult = undefined;

    // ── Wire data ─────────────────────────────────────────────────────────
    @wire(getOpportunities)
    wiredOpportunities(result) {
        this.wiredOppsResult = result;
        if (result.data) {
            this.allOpportunities = result.data.map((o, i) => ({
                ...o,
                rowNumber:       i + 1,
                accountName:     o.Account ? o.Account.Name : '-',
                formattedAmount: this.fmt(o.Amount),
                formattedDate:   o.CloseDate ? new Date(o.CloseDate).toLocaleDateString() : '-'
            }));
        }
    }

    @wire(getAccounts, { typeFilter: 'All', industryFilter: 'All' })
    wiredAccounts({ data }) {
        if (data) {
            this.accountOptions = data;
        }
    }

    // ── Pagination ────────────────────────────────────────────────────────
    get totalRecords() { return this.allOpportunities.length; }
    get totalPages()   { return Math.max(1, Math.ceil(this.totalRecords / PAGE_SIZE)); }
    get isFirstPage()  { return this.currentPage === 1; }
    get isLastPage()   { return this.currentPage >= this.totalPages; }
    get isEmpty()      { return this.allOpportunities.length === 0; }
    get startRecord()  { return this.totalRecords === 0 ? 0 : (this.currentPage - 1) * PAGE_SIZE + 1; }
    get endRecord()    { return Math.min(this.currentPage * PAGE_SIZE, this.totalRecords); }
    get paginatedOpportunities() {
        const start = (this.currentPage - 1) * PAGE_SIZE;
        return this.allOpportunities.slice(start, start + PAGE_SIZE);
    }

    // ── Handlers ──────────────────────────────────────────────────────────
    handleRefresh() {
        if (this.wiredOppsResult) {
            refreshApex(this.wiredOppsResult);
        }
    }

    handleNew() { this.showModal = true; }

    handleModalClose() {
        this.showModal    = false;
        this.errorMessage = '';
        this.formData     = {
            name: '', accountId: '', stageName: 'Prospecting',
            closeDate: '', amount: 0
        };
    }

    handleFieldChange(event) {
        const field = event.currentTarget.dataset.field;
        this.formData = {
            ...this.formData,
            [field]: event.target.value
        };
    }

    handleSave() {
        if (!this.formData.name || !this.formData.accountId || !this.formData.closeDate || !this.formData.stageName) {
            this.errorMessage = 'Please fill in all required fields.';
            return;
        }

        // ── Date Validation ───────────────────────────────────────────────────
        const selectedDate = new Date(this.formData.closeDate);
        const today        = new Date();
        today.setHours(0, 0, 0, 0); // Start of today

        if (selectedDate < today) {
            this.errorMessage = 'Close Date cannot be in the past.';
            return;
        }

        this.isSaving = true;

        createOpportunity({
            name:      this.formData.name,
            accountId: this.formData.accountId,
            stageName: this.formData.stageName,
            closeDate: this.formData.closeDate,
            amount:    this.formData.amount
        })
        .then(() => {
            this.handleModalClose();
            if (this.wiredOppsResult) {
                refreshApex(this.wiredOppsResult);
            }
        })
        .catch(error => {
            this.errorMessage = error.body ? error.body.message : 'Error creating opportunity.';
        })
        .finally(() => {
            this.isSaving = false;
        });
    }

    handlePrevPage() {
        if (!this.isFirstPage) this.currentPage--;
    }

    handleNextPage() {
        if (!this.isLastPage) this.currentPage++;
    }

    handleDelete(event) {
        const oppId = event.currentTarget.dataset.id;
        // eslint-disable-next-line no-alert
        if (!confirm('Are you sure you want to delete this opportunity?')) return;

        deleteOpportunity({ oppId: oppId })
            .then(() => {
                if (this.wiredOppsResult) {
                    refreshApex(this.wiredOppsResult);
                }
            })
            .catch(error => {
                console.error('Delete error:', error);
            });
    }

    fmt(value) {
        if (value == null) return '$0.00';
        return '$' + Number(value).toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }
}