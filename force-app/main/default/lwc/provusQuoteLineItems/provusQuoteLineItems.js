import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLineItems from '@salesforce/apex/QuoteLineItemController.getLineItems';
import getPhaseList from '@salesforce/apex/QuoteLineItemController.getPhaseList';
import savePhaseList from '@salesforce/apex/QuoteLineItemController.savePhaseList';
import updateLineItem from '@salesforce/apex/QuoteLineItemController.updateLineItem';
import deleteLineItems from '@salesforce/apex/QuoteLineItemController.deleteLineItems';
import deletePhase from '@salesforce/apex/QuoteLineItemController.deletePhase';

// Helper for generating unique IDs for drag payload
const generateId = () => Math.random().toString(36).substring(2, 10);

export default class ProvusQuoteLineItems extends LightningElement {

    @api quoteId;
    @api quoteStatus;
    @api isLocked = false;

    @track showAddModal = false;
    @track lineItems = [];
    @track phases = []; // Extracted from comma separated Phase_List__c
    @track collapsedPhases = new Set();
    @track popoverItemId = null; // ID of item whose unit price popover is open
    @track popoverPosition = { top: 0, left: 0 }; // coordinates for fixed popover
    
    // Drag state
    draggedItemId = null;
    @track dragOverPhase = null;
    @track targetPhase = null; // Phase to add new items into
    @track selectedIds = new Set(); // Track selected line item IDs
    @track selectedPhases = new Set(); // Track selected phase names
    @track isPhaseModalOpen = false;
    @track newPhaseName = '';



    wiredItemsResult = undefined;
    wiredPhaseListResult = undefined;

    // ── Wire Phase List ───────────────────────────────────────────────────
    @wire(getPhaseList, { quoteId: '$quoteId' })
    wiredPhaseList(result) {
        this.wiredPhaseListResult = result;
        if (result.data) {
            try {
                this.phases = JSON.parse(result.data);
            } catch(e) {
                // simple comma separation fallback if not JSON
                this.phases = result.data.split(',').map(s => s.trim()).filter(x => x);
            }
        } else if (result.error) {
            this.phases = [];
        }
    }

    // ── Wire Line Items ───────────────────────────────────────────────────
    @wire(getLineItems, { quoteId: '$quoteId' })
    wiredItems(result) {
        this.wiredItemsResult = result;
        if (result.data) {
            this.lineItems = result.data.map(item => ({
                ...item,
                Task__c: item.Task__c || '',
                Start_Date__c: item.Start_Date__c || '',
                End_Date__c: item.End_Date__c || '',
                typeIcon: this.getTypeIcon(item.Item_Type__c),
                typeIconClass: this.getTypeIconClass(item.Item_Type__c),
                formattedBaseRate: this.formatCurrency(item.Base_Rate__c),
                formattedUnitPrice: this.formatCurrency(item.Unit_Price__c),
                formattedTotal: this.formatCurrency(item.Total_Price__c)
            }));
        } else if (result.error) {
            console.error('Line items error:', result.error);
            this.lineItems = [];
        }
    }

    // ── Tree Data Logic ───────────────────────────────────────────────────
    get displayRows() {
        const rows = [];
        
        // 1. Root items (Phase__c == null)
        const rootItems = this.lineItems.filter(i => !i.Phase__c);
        rootItems.forEach(item => {
            rows.push({
                isItem: true,
                isPhase: false,
                record: { ...item, showPopover: this.popoverItemId === item.Id },
                isSelected: this.selectedIds.has(item.Id),
                rowClass: this.selectedIds.has(item.Id) ? 'item-row root-item row-selected' : 'item-row root-item'
            });
        });

        // Collect all distinct phases
        const itemPhases = new Set(this.lineItems.filter(i => i.Phase__c).map(i => i.Phase__c));
        const allPhases = Array.from(new Set([...this.phases, ...itemPhases]));

        // 2. Loop through phases and insert headers/children
        allPhases.forEach(phaseName => {
            const children = this.lineItems.filter(i => i.Phase__c === phaseName);
            const isCollapsed = this.collapsedPhases.has(phaseName);
            const isDragOver = this.dragOverPhase === phaseName;
            
            // Phase row
            rows.push({
                isPhase: true,
                isItem: false,
                phaseName: phaseName,
                isCollapsed: isCollapsed,
                isPhaseSelected: this.selectedPhases.has(phaseName),
                chevron: isCollapsed ? '›' : 'v',
                dragOverClass: isDragOver ? 'phase-row drop-target-active' : 'phase-row'
            });

            // Children rows
            if (!isCollapsed) {
                children.forEach(item => {
                    const isSelected = this.selectedIds.has(item.Id);
                    rows.push({
                        isItem: true,
                        isPhase: false,
                        record: { ...item, showPopover: this.popoverItemId === item.Id },
                        isSelected: isSelected,
                        rowClass: isSelected ? 'item-row nested-item row-selected' : 'item-row nested-item'
                    });
                });
            }
        });

        return rows;
    }

    get hasSelection() {
        return this.selectedIds.size > 0 || this.selectedPhases.size > 0;
    }

    get selectedCount() {
        return this.selectedIds.size;
    }

    get isAllSelected() {
        return this.lineItems.length > 0 && this.selectedIds.size === this.lineItems.length;
    }

    get isEmpty() {
        return this.lineItems.length === 0 && this.phases.length === 0;
    }

    get isDraft() {
        return this.quoteStatus === 'Draft';
    }

    get isLocked() {
        return !this.isDraft;
    }

    get grandTotal() {
        const total = this.lineItems.reduce((sum, item) => sum + (item.Total_Price__c || 0), 0);
        return this.formatCurrency(total);
    }

    // Toggle Phase Collapse
    handleTogglePhase(event) {
        const phase = event.currentTarget.dataset.phase;
        if (this.collapsedPhases.has(phase)) {
            this.collapsedPhases.delete(phase);
        } else {
            this.collapsedPhases.add(phase);
        }
        // Force reactivity since Set mutations aren't tracked
        this.collapsedPhases = new Set(this.collapsedPhases);
    }

    get collapseAllLabel() {
        const itemPhases = new Set(this.lineItems.filter(i => i.Phase__c).map(i => i.Phase__c));
        const allPhases = new Set([...this.phases, ...itemPhases].filter(x => x));
        if (allPhases.size > 0 && this.collapsedPhases.size === allPhases.size) {
            return '› Expand All';
        }
        return '› Collapse All';
    }

    handleCollapseAll() {
        const itemPhases = new Set(this.lineItems.filter(i => i.Phase__c).map(i => i.Phase__c));
        const allPhases = new Set([...this.phases, ...itemPhases].filter(x => x));
        if (this.collapsedPhases.size === allPhases.size) {
            this.collapsedPhases = new Set();
        } else {
            this.collapsedPhases = allPhases;
        }
    }

    // ── Drag and Drop Logic ──────────────────────────────────────────────
    handleDragStart(event) {
        this.draggedItemId = event.currentTarget.dataset.id;
        event.dataTransfer.effectAllowed = 'move';
        // Need to set data to make it draggable in Firefox
        event.dataTransfer.setData('text/plain', this.draggedItemId);
    }

    handleDragOver(event) {
        event.preventDefault(); // Necessary to allow dropping
        event.dataTransfer.dropEffect = 'move';
        
        const phase = event.currentTarget.dataset.phase || null;
        if (this.dragOverPhase !== phase) {
            this.dragOverPhase = phase;
        }
    }

    handleDragLeave(event) {
        this.dragOverPhase = null;
    }

    handleDrop(event) {
        event.preventDefault();
        const targetPhase = event.currentTarget.dataset.phase || null;
        this.dragOverPhase = null;

        if (!this.draggedItemId) return;

        // Immediately update local array for instant UI feedback
        const itemIndex = this.lineItems.findIndex(i => i.Id === this.draggedItemId);
        if (itemIndex > -1) {
            const currentPhase = this.lineItems[itemIndex].Phase__c || null;
            if (currentPhase === targetPhase) return; // Dropped in the same phase

            // Optimistic UI update
            this.lineItems[itemIndex] = { ...this.lineItems[itemIndex], Phase__c: targetPhase };
            this.lineItems = [...this.lineItems];

            // Persist to server
            updateLineItem({ item: { Id: this.draggedItemId, Phase__c: targetPhase } })
                .then(() => {
                    this.dispatchEvent(new CustomEvent('lineitemsupdated'));
                    // Ensure the cache is refreshed after dropping an item into a phase
                    if (this.wiredItemsResult) return refreshApex(this.wiredItemsResult);
                })
                .catch(error => {
                    console.error('Update phase error:', error);
                    refreshApex(this.wiredItemsResult); // Revert on failure
                });
        }
        this.draggedItemId = null;
    }


    // ── Field Editing & Standard Handlers ─────────────────────────────────
    handleFieldChange(event) {
        const itemId = event.currentTarget.dataset.id;
        const field  = event.currentTarget.dataset.field;
        const value  = event.target.value;

        if (field === 'Discount_Percent__c') {
            const discount = parseFloat(value);
            if (discount < 0 || discount > 100) {
                this.dispatchEvent(new ShowToastEvent({ title: 'Invalid Discount', message: 'Discount percentage must be between 0 and 100.', variant: 'error' }));
                const item = this.lineItems.find(i => i.Id === itemId);
                if (item) event.target.value = item.Discount_Percent__c || 0;
                return;
            }
        }

        let parsedValue = value;
        if (field === 'Quantity__c') {
            parsedValue = parseFloat(value);
            if (isNaN(parsedValue)) parsedValue = 0;
        }

        let itemPayload = { Id: itemId, [field]: parsedValue };

        if (field === 'Start_Date__c') {
            const item = this.lineItems.find(i => i.Id === itemId);
            if (item && item.Start_Date__c && item.End_Date__c) {
                const oldStart = new Date(item.Start_Date__c);
                const newStart = new Date(parsedValue);
                if (!isNaN(oldStart) && !isNaN(newStart)) {
                    const diffTime = newStart.getTime() - oldStart.getTime();
                    const oldEnd = new Date(item.End_Date__c);
                    const newEnd = new Date(oldEnd.getTime() + diffTime);
                    itemPayload.End_Date__c = newEnd.toISOString().split('T')[0];
                }
            }
        } else if (field === 'Quantity__c') {
            const item = this.lineItems.find(i => i.Id === itemId);
            if (item && item.Item_Type__c === 'Resource Role' && item.Start_Date__c && item.Quote__r && item.Quote__r.Time_Period__c) {
                const start = new Date(item.Start_Date__c);
                if (!isNaN(start)) {
                    let days = 0;
                    const period = item.Quote__r.Time_Period__c;
                    if (period === 'Days') days = 1;
                    else if (period === 'Weeks') days = 7;
                    else if (period === 'Months') days = 30;
                    else if (period === 'Quarters') days = 90;
                    else if (period === 'Years') days = 365;

                    days = Math.round(days * parsedValue);
                    
                    const end = new Date(start.getTime());
                    end.setDate(end.getDate() + days);
                    itemPayload.End_Date__c = end.toISOString().split('T')[0];
                }
            }
        }

        updateLineItem({ item: itemPayload })
        .then(() => { if (this.wiredItemsResult) return refreshApex(this.wiredItemsResult); })
        .then(() => { this.dispatchEvent(new CustomEvent('lineitemsupdated')); })
        .catch(error => console.error('Update error:', error));
    }

    handleUnitPriceClick(event) {
        const itemId = event.currentTarget.dataset.id;
        if (this.popoverItemId === itemId) {
            this.popoverItemId = null;
            return;
        }
        // Compute position relative to the table-container (our position:relative ancestor)
        const clickedEl = event.currentTarget;
        const container = this.template.querySelector('.table-container');
        const clickedRect   = clickedEl.getBoundingClientRect();
        const containerRect = container ? container.getBoundingClientRect() : { top: 0, left: 0 };

        const topOffset  = clickedRect.bottom - containerRect.top + 8;
        const leftOffset = Math.max(8, clickedRect.right - containerRect.left - 280);

        this.popoverPosition = { top: topOffset, left: leftOffset };
        this.popoverItemId = itemId;
    }

    get popoverStyle() {
        return `top:${this.popoverPosition.top}px;left:${this.popoverPosition.left}px;`;
    }

    handleClosePopover() {
        this.popoverItemId = null;
    }

    get popoverItem() {
        if (!this.popoverItemId) return null;
        const item = this.lineItems.find(i => i.Id === this.popoverItemId);
        if (!item) return null;

        const isResourceRole = item.Item_Type__c === 'Resource Role';
        const baseRate = item.Base_Rate__c || 0;
        
        if (isResourceRole) {
            const period   = (item.Quote__r && item.Quote__r.Time_Period__c) ? item.Quote__r.Time_Period__c : 'Months';
            const periodHoursMap = { Days: 8, Weeks: 40, Months: 160, Quarters: 480, Years: 1920 };
            const hours      = periodHoursMap[period] || 160;
            const unitPrice  = item.Unit_Price__c || (baseRate * hours);

            return {
                isResourceRole: true,
                baseRateLabel : this.formatCurrency(baseRate) + '/hour',
                periodLabel   : period,
                periodHours   : hours + ' hours',
                calcLabel     : this.formatCurrency(baseRate) + ' × ' + hours,
                unitPrice     : this.formatCurrency(unitPrice)
            };
        } else {
            // Products or Add-ons
            return {
                isResourceRole: false,
                basePriceLabel: this.formatCurrency(baseRate),
                unitPrice     : this.formatCurrency(baseRate)
            };
        }
    }

    // ── Add Phase / Add Item ──────────────────────────────────────────────
    handleAddPhase() {
        this.newPhaseName = '';
        this.isPhaseModalOpen = true;
    }

    handleClosePhaseModal() {
        this.isPhaseModalOpen = false;
        this.newPhaseName = '';
    }

    handlePhaseNameChange(event) {
        this.newPhaseName = event.target.value;
    }

    handleConfirmAddPhase() {
        if (!this.newPhaseName || !this.newPhaseName.trim()) {
            this.handleClosePhaseModal();
            return;
        }
        
        const newPhase = this.newPhaseName.trim();
        if(!this.phases.includes(newPhase)) {
            const newPhases = [...this.phases, newPhase];
            savePhaseList({ quoteId: this.quoteId, phaseList: JSON.stringify(newPhases) })
                .then(() => {
                    this.handleClosePhaseModal();
                    return refreshApex(this.wiredPhaseListResult);
                })
                .catch(err => {
                    console.error('Error saving phase', err);
                    this.handleClosePhaseModal();
                });
        } else {
            this.handleClosePhaseModal();
        }
    }


    handleAddItem(event) {
        this.targetPhase = event.currentTarget.dataset.phase || null;
        this.showAddModal = true;
    }

    handleModalClose() {
        this.showAddModal = false;
        this.targetPhase = null;
    }

    handleItemsAdded() {
        this.showAddModal = false;
        if (this.wiredItemsResult) refreshApex(this.wiredItemsResult);
        this.dispatchEvent(new CustomEvent('lineitemsupdated'));
    }

    // ── Selection Handlers ────────────────────────────────────────────────
    handleSelectItem(event) {
        const id = event.target.dataset.id;
        const newSelected = new Set(this.selectedIds);
        if (event.target.checked) {
            newSelected.add(id);
        } else {
            newSelected.delete(id);
        }
        this.selectedIds = newSelected;
    }

    handleSelectPhase(event) {
        const phase = event.target.dataset.phase;
        const checked = event.target.checked;
        const phaseItemIds = this.lineItems
            .filter(i => i.Phase__c === phase)
            .map(i => i.Id);
        
        const newSelected = new Set(this.selectedIds);
        const newSelectedPhases = new Set(this.selectedPhases);

        if (checked) {
            newSelectedPhases.add(phase);
        } else {
            newSelectedPhases.delete(phase);
        }
        this.selectedPhases = newSelectedPhases;

        phaseItemIds.forEach(id => {
            if (checked) newSelected.add(id);
            else newSelected.delete(id);
        });
        this.selectedIds = newSelected;
    }

    handleSelectAll(event) {
        const checked = event.target.checked;
        if (checked) {
            this.selectedIds = new Set(this.lineItems.map(i => i.Id));
            this.selectedPhases = new Set(this.phases);
        } else {
            this.selectedIds = new Set();
            this.selectedPhases = new Set();
        }
    }

    handleDeleteSelected() {
        const count = this.selectedIds.size;
        const phaseCount = this.selectedPhases.size;

        if (count === 0 && phaseCount === 0) return;

        let msg = `Are you sure you want to delete ${count} selected item(s)?`;
        if (phaseCount > 0) {
            msg = `Are you sure you want to delete ${phaseCount} selected phase(s) and its contents?`;
        }

        // eslint-disable-next-line no-alert
        if (!confirm(msg)) return;

        const promises = [];
        
        // 1. Delete Items
        if (count > 0) {
            promises.push(deleteLineItems({ itemIds: Array.from(this.selectedIds) }));
        }

        // 2. Delete Phases
        if (phaseCount > 0) {
            this.selectedPhases.forEach(pName => {
                promises.push(deletePhase({ quoteId: this.quoteId, phaseName: pName }));
            });
        }

        Promise.all(promises)
            .then(() => {
                this.selectedIds = new Set();
                this.selectedPhases = new Set();
                
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: `Deleted successfully.`,
                    variant: 'success'
                }));
                
                refreshApex(this.wiredPhaseListResult);
                if (this.wiredItemsResult) refreshApex(this.wiredItemsResult);
                this.dispatchEvent(new CustomEvent('lineitemsupdated'));
            })
            .catch(error => {
                console.error('Delete error:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error during deletion',
                    message: error.body ? error.body.message : 'Unknown error',
                    variant: 'error'
                }));
            });
    }

    // ── Formatters ────────────────────────────────────────────────────────
    getTypeIcon(type) {
        if (type === 'Resource Role') return '👤';
        if (type === 'Product')       return '📦';
        if (type === 'Add-on')        return '✨';
        return '📋';
    }
    getTypeIconClass(type) { return 'type-icon icon-' + (type ? type.toLowerCase().replace(' ', '') : 'default'); }
    formatCurrency(value) {
        if (value == null) return '$0.00';
        return '$' + Number(value).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }
}