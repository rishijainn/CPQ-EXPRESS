import { LightningElement, api, track, wire } from 'lwc';
import getCurrentUserContext from
    '@salesforce/apex/UserContextController.getCurrentUserContext';

export default class ProvusSidebar extends LightningElement {

    // activePage is passed from the parent (provusExpressApp)
    @api activePage = 'dashboard';
    @track isManager = false;

    @wire(getCurrentUserContext)
    wiredContext({ data }) {
        if (data) {
            this.isManager = data.isManager;
        }
    }

    // Nav items definition
    // icon, label, page name all defined here
    get navItems() {
    const items = [
        { id: 1, icon: '📊', label: 'Dashboard',      page: 'dashboard' },
        { id: 2, icon: '📋', label: 'Quotes',         page: 'quotes' },
        { id: 3, icon: '🏢', label: 'Accounts',       page: 'accounts' },
        { id: 8, icon: '📈', label: 'Opportunities',  page: 'opportunities' },
        { id: 4, icon: '👤', label: 'Resource Roles', page: 'resourceRoles' },
        { id: 5, icon: '📦', label: 'Products',       page: 'products' },
        { id: 6, icon: '➕', label: 'Add-ons',        page: 'addons' },
    ];
    return items.map(item => ({
        ...item,
        cssClass: item.page === this.activePage
            ? 'nav-item nav-item-active'
            : 'nav-item'
    }));
}

// Handle navigation clicks for all sidebar items including bottom ones
    handleNavClick(event) {
        const page = event.currentTarget.dataset.page;
        if (page) {
            this.dispatchEvent(new CustomEvent('navigation', {
                detail:   { page: page },
                bubbles:  true,
                composed: true
            }));
        }
    }
}