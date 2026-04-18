import { LightningElement, api, wire, track } from 'lwc';
import getLineItems from '@salesforce/apex/QuoteLineItemController.getLineItems';
import getPhaseList from '@salesforce/apex/QuoteLineItemController.getPhaseList';

export default class ProvusQuoteTimeline extends LightningElement {
    @api quoteId;

    @track items = [];
    @track phasesOrder = [];
    @track months = [];
    @track isLoading = true;

    wiredItemsResult;
    wiredPhasesResult;

    // Timeline configuration
    MONTH_WIDTH = 150; // pixels per month
    
    @wire(getPhaseList, { quoteId: '$quoteId' })
    wiredPhases(result) {
        this.wiredPhasesResult = result;
        if (result.data) {
            try {
                this.phasesOrder = JSON.parse(result.data);
            } catch (e) {
                this.phasesOrder = result.data.split(',').map(p => p.trim()).filter(x => x);
            }
        }
    }

    @wire(getLineItems, { quoteId: '$quoteId' })
    wiredItems(result) {
        this.wiredItemsResult = result;
        if (result.data) {
            this.processTimelineData(result.data);
            this.isLoading = false;
        } else if (result.error) {
            console.error('Timeline items error:', result.error);
            this.isLoading = false;
        }
    }

    processTimelineData(data) {
        if (!data || data.length === 0) {
            this.items = [];
            this.months = [];
            return;
        }

        // 1. Find date range
        let minDate = null;
        let maxDate = null;

        data.forEach(item => {
            const start = item.Start_Date__c ? new Date(item.Start_Date__c) : null;
            const end = item.End_Date__c ? new Date(item.End_Date__c) : null;
            if (start && (!minDate || start < minDate)) minDate = start;
            if (end && (!maxDate || end > maxDate)) maxDate = end;
        });

        if (!minDate) minDate = new Date();
        if (!maxDate) maxDate = new Date(minDate.getTime() + 30 * 24 * 60 * 60 * 1000);

        // Normalize to start of month
        const timelineStart = new Date(minDate.getFullYear(), minDate.getMonth(), 1);
        const timelineEnd = new Date(maxDate.getFullYear(), maxDate.getMonth() + 2, 1); // +2 for buffer

        // 2. Build month headers
        const months = [];
        let curr = new Date(timelineStart);
        while (curr < timelineEnd) {
            months.push({
                name: curr.toLocaleString('default', { month: 'short' }),
                year: curr.getFullYear(),
                monthIndex: curr.getMonth(),
                id: `${curr.getFullYear()}-${curr.getMonth()}`
            });
            curr.setMonth(curr.getMonth() + 1);
        }
        this.months = months;

        const totalMonths = months.length;
        this.timelineTotalWidth = totalMonths * this.MONTH_WIDTH;

        // 3. Process items
        const processedItems = data.map(item => {
            const start = item.Start_Date__c ? new Date(item.Start_Date__c) : null;
            const end = item.End_Date__c ? new Date(item.End_Date__c) : null;
            
            let barStyle = 'display: none;';
            if (start && end) {
                const startOff = this.getDiffMonths(timelineStart, start);
                const durationMonths = this.getDiffMonths(start, end);

                const left = startOff * this.MONTH_WIDTH;
                const width = Math.max(durationMonths * this.MONTH_WIDTH, 40); // min width

                barStyle = `left: ${left}px; width: ${width}px;`;
            }

            return {
                ...item,
                displayName: item.Name,
                barStyle,
                barClass: `timeline-bar ${this.getBarTypeClass(item.Item_Type__c)}`,
                iconClass: `bar-icon ${this.getIconTypeClass(item.Item_Type__c)}`,
                durationText: this.getDurationText(start, end),
                dotStyle: `background-color: ${this.getDotColor(item.Item_Type__c)}`
            };
        });

        this.items = processedItems;
    }

    getDiffMonths(date1, date2) {
        const yearDiff = date2.getFullYear() - date1.getFullYear();
        const monthDiff = date2.getMonth() - date1.getMonth();
        const dayDiff = date2.getDate() - date1.getDate();
        
        // Return decimal months
        let total = (yearDiff * 12) + monthDiff;
        total += (dayDiff / 30); // simplistic but good for viz
        return total;
    }

    getDurationText(start, end) {
        if (!start || !end) return '-';
        const diffDays = Math.round((end - start) / (1000 * 60 * 60 * 24)) + 1;
        if (diffDays <= 1) return '1 day';
        if (diffDays < 30) return `${diffDays} days`;
        const mos = Math.round(diffDays / 30);
        return `about ${mos} month${mos > 1 ? 's' : ''}`;
    }

    getBarTypeClass(type) {
        if (type === 'Product') return 'bar-product';
        if (type === 'Add-on') return 'bar-addon';
        return 'bar-resource';
    }

    getIconTypeClass(type) {
        if (type === 'Product') return 'icon-cube';
        if (type === 'Add-on') return 'icon-puzzle';
        return 'icon-person';
    }

    getDotColor(type) {
        if (type === 'Product') return '#0070d2';
        if (type === 'Add-on') return '#7f8de1';
        return '#4bca81';
    }

    get groupedPhases() {
        const map = new Map();
        
        // Pre-fill with phases from quote list
        this.phasesOrder.forEach(p => {
            map.set(p, []);
        });

        // Add Default Phase if not exists
        if (!map.has('Default phase')) map.set('Default phase', []);

        this.items.forEach(item => {
            const phase = item.Phase__c || 'Default phase';
            if (!map.has(phase)) map.set(phase, []);
            map.get(phase).push(item);
        });

        return Array.from(map.keys())
            .filter(name => map.get(name).length > 0 || this.phasesOrder.includes(name))
            .map(name => ({
                name,
                items: map.get(name)
            }));
    }

    get yearLabels() {
        if (this.months.length === 0) return [];
        const years = [];
        this.months.forEach(m => {
            if (years.length === 0 || years[years.length - 1].year !== m.year) {
                years.push({ year: m.year, count: 1 });
            } else {
                years[years.length - 1].count++;
            }
        });
        return years.map(y => ({
            ...y,
            style: `width: ${y.count * this.MONTH_WIDTH}px`
        }));
    }

    get canvasBodyStyle() {
        return `width: ${this.timelineTotalWidth}px`;
    }
}