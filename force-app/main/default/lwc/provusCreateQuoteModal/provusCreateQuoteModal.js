import { LightningElement, api, track, wire } from 'lwc';
import getAllAccounts from '@salesforce/apex/AccountController.getAllAccounts';
import getOpportunities from '@salesforce/apex/OpportunityController.getOpportunities';
import getOpportunityById from '@salesforce/apex/OpportunityController.getOpportunityById';
import createQuote from '@salesforce/apex/QuoteController.createQuote';

export default class ProvusCreateQuoteModal extends LightningElement {

    @api isOpen = false;

    // Form values
    @track accountId      = '';
    @track opportunityId  = '';
    @track description    = '';
    @track startDate      = new Date().toISOString().split('T')[0];
    @track endDate        = '';
    @track timePeriod     = 'Months';

    // UI state
    @track errorMessage   = '';
    @track isCreating     = false;

    @track accountList     = [];
    @track opportunityList = [];
    allOpportunities       = [];

    @wire(getAllAccounts)
    wiredAccounts({ data, error }) {
        if (data) {
            this.accountList = data;
        } else if (error) {
            console.error('Error loading accounts:', error);
        }
    }

    @wire(getOpportunities)
    wiredOpportunities({ data, error }) {
        if (data) {
            this.allOpportunities = data;
            this.opportunityList = data;
        } else if (error) {
            console.error('Error loading opportunities:', error);
        }
    }

    get descriptionLength() {
        return this.description ? this.description.length : 0;
    }

    get isAccountDisabled() {
        return !!this.opportunityId;
    }

    get accountOptions() {
        return this.accountList.map(acc => ({ label: acc.Name, value: acc.Id }));
    }

    get opportunityOptions() {
        const options = this.opportunityList.map(opp => ({ label: opp.Name, value: opp.Id }));
        return [{ label: '-- None --', value: '' }, ...options];
    }

    handleAccountChange(event) {
        this.accountId = event.detail.value;
        
        // Filter opportunities for this account
        if (this.accountId) {
            this.opportunityList = this.allOpportunities.filter(opp => opp.AccountId === this.accountId);
        } else {
            this.opportunityList = this.allOpportunities;
        }

        // If current opportunity doesn't belong to new account, reset it
        if (this.opportunityId) {
            const opp = this.allOpportunities.find(o => o.Id === this.opportunityId);
            if (opp && opp.AccountId !== this.accountId) {
                this.opportunityId = '';
            }
        }
    }

    handleOpportunityChange(event) {
        const selectedOppId = event.detail.value;
        this.opportunityId = selectedOppId;

        if (!selectedOppId) {
            // Re-enable and reset both if opportunity is cleared
            this.accountId = '';
            this.opportunityList = this.allOpportunities;
            return;
        }

        const opp = this.allOpportunities.find(o => o.Id === selectedOppId);
        if (opp && opp.AccountId) {
            this.accountId = opp.AccountId;
            // Note: We deliberately do NOT filter opportunityList here 
            // so the user can still see other options if they click again.
        } else {
            this.accountId = '';
        }
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    handleTimePeriodChange(event) {
        this.timePeriod = event.target.value;
    }

    // ── Validation ────────────────────────────────────────────────────────
    validate() {
        if (!this.accountId) {
            this.errorMessage = 'Please select an Account.';
            return false;
        }
        if (!this.startDate) {
            this.errorMessage = 'Please select a Start Date.';
            return false;
        }
        if (!this.timePeriod) {
            this.errorMessage = 'Please select a Time Period.';
            return false;
        }
        this.errorMessage = '';
        return true;
    }

    // ── Create quote ──────────────────────────────────────────────────────
    handleCreate() {
        if (!this.validate()) return;

        this.isCreating = true;

        createQuote({
            opportunityId: this.opportunityId || null,
            accountId:     this.accountId,
            description:   this.description   || '',
            startDate:     this.startDate,
            endDate:       this.endDate        || null,
            timePeriod:    this.timePeriod
        })
        .then(newQuoteId => {
            this.dispatchEvent(new CustomEvent('quotecreated', {
                detail: { quoteId: newQuoteId }
            }));
            this.resetForm();
        })
        .catch(error => {
            console.error('Create quote error:', error);
            this.errorMessage = error.body
                ? error.body.message
                : 'Error creating quote. Please try again.';
        })
        .finally(() => {
            this.isCreating = false;
        });
    }

    // ── Close modal ───────────────────────────────────────────────────────
    handleClose() {
        this.resetForm();
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleOverlayClick() {
        this.handleClose();
    }

    // ── Reset all fields ──────────────────────────────────────────────────
    resetForm() {
        this.accountId     = '';
        this.opportunityId = '';
        this.description   = '';
        this.startDate     = new Date().toISOString().split('T')[0];
        this.endDate       = '';
        this.timePeriod    = 'Months';
        this.errorMessage  = '';
        this.opportunityList = this.allOpportunities;
    }
}