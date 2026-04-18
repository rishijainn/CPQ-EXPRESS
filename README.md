# Provus Express Quoting

Provus Express Quoting is a streamlined, powerful Configure, Price, Quote (CPQ) application purpose-built natively on the Salesforce platform. It is designed to accelerate the sales cycle by enabling sales teams and managers to efficiently configure quotes, price services and products, map out delivery timelines, and generate professional PDF proposals.

## Key Features

### 1. Resource Roles & Configuration
Define billable roles (e.g., QA Lead, Full-stack Developer) along with custom **Cost** and **Price** rates. Manage regional pricing by location and assign standardized billing units (Hourly, Weekly, Monthly) to maintain precise margin calculations.

![Resource Roles Management](./docs/images/resource-roles.png)

### 2. General Settings & Billing Logic
Maintain absolute control over your environment's parameters:
- **Billing Time Defaults:** Define standard work capacities (e.g., 1 Week = 40 hours, 1 Month = 160 hours). The engine uses these defaults to calculate extended service estimates dynamically.
- **Organization Preferences:** Set universal metrics to ensure consistency applied across all project estimations.

![Billing Time Defaults](./docs/images/settings-billing-defaults.png)

### 3. Company Information & Branding
Easily manage your organization's essential details—including Company Name, Contact Email, Web Address, and Location. This data natively integrates with the quoting engine to dynamically brand your outgoing PDF proposals.

![Company Information Preferences](./docs/images/settings-company-info.png)

### 4. Team & User Management
A centralized administration portal to oversee your sales team. 
- Distribute available seats and assign proper permission layers (Admin vs. Standard User).
- Track user activity and easily integrate new salespersons into the CPQ ecosystem.

![User Team Management](./docs/images/settings-users.png)

### 5. Intelligent Quoting Engine & Timeline Planner
The core of the Provus Express Quoting application—an intuitive workspace for building opportunities:
- **Financial Summary:** Instantly track Total Amount, Subtotal, cumulative Margins, and Discount percentages up top.
- **Line Items & Services:** Add Products, Add-ons, and Resource Roles to the quote.
- **Timeline View:** A rich visual Gantt-style interface that plots line items along a project timeline. It allows users to group scope into distinct phases and visualize duration realistically before finalizing the quote.

![Quote Timeline View](./docs/images/quote-timeline.png)

## Architecture & Technologies

This application is built using modern Salesforce architecture:
- **Lightning Web Components (LWC):** Powers a sleek, Single Page Application (SPA)-like experience. Extensive use of modular components (`provusExpressApp`, `provusQuoteDetail`, `provusQuoteTimeline`, etc.).
- **Apex Code Layer:** Follows a rigorous separation of concerns utilizing Controllers, Services, and Data Access Objects (DAOs) for scalable business logic manipulation.
- **Custom Objects:** Natively integrated data layers utilizing custom structures like `Resource_Role__c`, `Add_On__c`, `Quote_Line_Item__c`, and `Organization_Settings__c`.
- **Security & Perms:** Fully governed by declarative security policies (`CPQ_Manager_Access`, `CPQ_Salesperson_Access`).

## Getting Started

1. **Deploy Metadata:** Use the Salesforce CLI (`sfdx` or `sf`) to deploy the source code to your org:
   ```bash
   sf project deploy start
   ```
2. **Assign Permission Sets:** Assign `CPQ_Manager_Access` to your environment Administrators, and `CPQ_Salesperson_Access` to standard users.
3. **Configure the Core System:** Navigate to the **Express Home** application tab, open up **Settings**, and complete your organizational defaults before constructing your first quote.
