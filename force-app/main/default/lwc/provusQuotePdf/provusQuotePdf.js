import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getQuotePdfData from
    '@salesforce/apex/QuotePdfController.getQuotePdfData';

import { NavigationMixin } from 'lightning/navigation';

export default class ProvusQuotePdf extends NavigationMixin(LightningElement) {

    _isOpen = false;
    @api 
    get isOpen() { return this._isOpen; }
    set isOpen(value) {
        this._isOpen = value;
        // Refresh data whenever the modal is opened to ensure we show the latest QLIs
        if (value && this.wiredPdfDataResult) {
            refreshApex(this.wiredPdfDataResult);
        }
    }

    @api quoteId = '';

    @track pdfData   = null;
    @track isLoading = true;
    wiredPdfDataResult;

    // ── Wire PDF data ─────────────────────────────────────────────────────
    @wire(getQuotePdfData, { quoteId: '$quoteId' })
    wiredPdfData(result) {
        this.wiredPdfDataResult = result;
        const { data, error } = result;
        this.isLoading = false;
        if (data) {
            // Process phases and format currency
            this.pdfData = {
                ...data,
                phases: (data.phases || []).map(phase => ({
                    ...phase,
                    formattedPhaseTotal:
                        this.fmt(phase.phaseTotal),
                    items: (phase.items || []).map(item => ({
                        ...item,
                        formattedPrice:
                            this.fmt(item.unitPrice),
                        formattedTotal:
                            this.fmt(item.total),
                        discountDisplay:
                            (item.discount != null && item.discount > 0)
                            ? item.discount + '%' : '-'
                    }))
                }))
            };
        }
        if (error) {
            console.error('PDF data error:', error);
            this.isLoading = false;
        }
    }

    // ── Computed ──────────────────────────────────────────────────────────
    get orgInfo() {
        return this.pdfData ? this.pdfData.orgInfo : {};
    }

    get companyAddressLine() {
        if (!this.pdfData) return '';
        const org = this.pdfData.orgInfo;
        const parts = [];
        if (org.address) parts.push(org.address);
        if (org.city)    parts.push(org.city);
        if (org.state)   parts.push(org.state);
        if (org.zipCode) parts.push(org.zipCode);
        return parts.join(', ');
    }

    get hasPhone() {
        return this.orgInfo && this.orgInfo.phone;
    }

    get formattedGrandTotal() {
        return this.fmt(
            this.pdfData ? this.pdfData.grandTotal : 0
        );
    }

    get formattedSubtotalAmount() {
        return this.fmt(
            this.pdfData?.quote?.Subtotal_Amount__c || 0
        );
    }

    get discountPercent() {
        const val = this.pdfData?.quote?.Calculated_Discount__c;
        return val != null ? Number(val).toFixed(1) : '0.0';
    }

    get formattedDiscountAmount() {
        const sub = this.pdfData?.quote?.Subtotal_Amount__c || 0;
        const tot = this.pdfData?.quote?.Total_Amount__c || 0;
        return this.fmt(sub - tot);
    }

    fmt(value) {
        if (value == null) return '$0.00';
        return '$' + Number(value).toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    // ── Handlers ──────────────────────────────────────────────────────────
    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleDownload() {
        const downloadUrl = '/apex/QuoteDownloadPdf?id=' + this.quoteId;
        // Create a hidden anchor element to trigger download without navigation
        const link = document.createElement('a');
        link.href = downloadUrl;
        link.target = '_self'; 
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    handleAddNotes() {
        // eslint-disable-next-line no-alert
        alert('Add notes feature coming soon!');
    }
}