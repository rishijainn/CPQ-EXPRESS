# CPQ Express — Scratch Org Migration Guide (with Agentforce & Einstein)

This guide walks you through creating a **new scratch org** with Agentforce + Einstein AI features enabled, and migrating your entire CPQ Express project into it.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Update Dev Hub for Einstein & Agentforce](#2-update-dev-hub-for-einstein--agentforce)
3. [Update the Scratch Org Definition](#3-update-the-scratch-org-definition)
4. [Create the New Scratch Org](#4-create-the-new-scratch-org)
5. [Deploy Source Code](#5-deploy-source-code)
6. [Post-Deploy: Platform Configuration](#6-post-deploy-platform-configuration)
7. [Assign Permission Sets](#7-assign-permission-sets)
8. [Enable Agentforce in the Org](#8-enable-agentforce-in-the-org)
9. [Enable Einstein AI Features](#9-enable-einstein-ai-features)
10. [Create Custom Profiles (Manager & Salesperson)](#10-create-custom-profiles-manager--salesperson)
11. [Seed Sample Data (Optional)](#11-seed-sample-data-optional)
12. [Verification Checklist](#12-verification-checklist)
13. [Reference: Full Project Inventory](#13-reference-full-project-inventory)

---

## 1. Prerequisites

Before starting, make sure you have:

- [ ] **Salesforce CLI** (`sf`) installed and on the latest version:
  ```bash
  sf update
  sf --version   # Should be v2.x+
  ```
- [ ] **Dev Hub org** authenticated and set as default:
  ```bash
  sf org login web --set-default-dev-hub --alias my-devhub
  ```
- [ ] **Git** — All local changes committed so nothing is lost:
  ```bash
  cd "/Users/rishijain/CPQ EXPRESS"
  git add -A && git commit -m "pre-migration snapshot"
  ```

> [!IMPORTANT]
> Your Dev Hub org **must** have Agentforce and Einstein features enabled at the Dev Hub level before scratch orgs can inherit them. See Step 2.

---

## 2. Update Dev Hub for Einstein & Agentforce

You need to enable these features in your **Dev Hub org** (production/developer org that creates scratch orgs) BEFORE the scratch org can use them.

### In the Dev Hub org (Setup):

1. **Einstein Platform** → Search `Einstein Setup` in Setup
   - Toggle **Turn on Einstein** → ON
   - Accept the Einstein Terms of Service

2. **Agentforce** → Search `Agents` or `Einstein Copilot` in Setup
   - Enable `Einstein Copilot` (now called Agentforce)
   - Enable `Einstein Generative AI`

3. **Dev Hub Settings** → Search `Dev Hub` in Setup
   - Ensure `Enable Dev Hub` is ON
   - Ensure `Enable Einstein for Scratch Orgs` is ON (if available)
   - Ensure `Enable Unlocked Packages and Second-Generation Managed Packages` is ON

4. **Einstein Generative AI** → Search `Einstein Generative AI` in Setup
   - Toggle ON

> [!NOTE]
> These settings may take a few minutes to propagate. If features aren't available when creating the scratch org, wait 10-15 minutes and try again.

---

## 3. Update the Scratch Org Definition

Replace the contents of `config/project-scratch-def.json` with the following. This adds all the features needed for Einstein, Agentforce, AND your existing CPQ project:

```json
{
    "orgName": "Provus CPQ Express (AI-Enabled)",
    "edition": "Enterprise",
    "features": [
        "EnableSetPasswordInApi",
        "EinsteinGPTForDevelopers",
        "EinsteinGenAIForFlow"
    ],
    "settings": {
        "lightningExperienceSettings": {
            "enableS1DesktopEnabled": true
        },
        "mobileSettings": {
            "enableS1EncryptedStoragePref2": false
        },
        "userManagementSettings": {
            "enableEnhancedPermsetMgmt": true
        },
        "einsteinAssistantSettings": {
            "enableEinsteinAssistant": true
        }
    },
    "adminEmail": "jainrishirich2004@gmail.com"
}
```

### What Changed vs. Your Current Config

| Setting | Old Value | New Value |
|---------|-----------|-----------|
| `orgName` | `Provus CPQ Express` | `Provus CPQ Express (AI-Enabled)` |
| `features` | `["EnableSetPasswordInApi"]` | Added `EinsteinGPTForDevelopers`, `EinsteinGenAIForFlow` |
| `einsteinAssistantSettings` | _(missing)_ | `enableEinsteinAssistant: true` |

> [!WARNING]
> The exact feature names may have changed in the latest Salesforce API version. If you get an error during scratch org creation, check the [Salesforce Scratch Org Definition Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_def_file.htm) for the latest valid feature names. Common alternatives:
> - `EinsteinGPTForDevelopers` → `EinsteinBuilderBots`
> - `EinsteinGenAIForFlow` → `EinsteinCopilotForFlow`
>
> If a feature name doesn't work, you can always enable it manually in Setup after org creation (Step 9).

---

## 4. Create the New Scratch Org

Run the following commands from your project root:

```bash
cd "/Users/rishijain/CPQ EXPRESS"

# Create the scratch org (30-day duration)
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias cpq-ai \
  --duration-days 30 \
  --set-default \
  --wait 10

# Verify it was created
sf org list --all
```

If the creation **fails due to a feature name error**, try removing the problematic feature from the JSON and enable it manually later (Step 9). The core project doesn't depend on Einstein features to deploy.

```bash
# Open the org to verify it's working
sf org open --target-org cpq-ai
```

---

## 5. Deploy Source Code

This single command deploys **everything** in your `force-app` directory — all custom objects, fields, Apex classes, LWCs, permission sets, profiles, layouts, flexipages, VF pages, the Lightning app, tabs, and settings:

```bash
sf project deploy start \
  --target-org cpq-ai \
  --wait 15
```

### What Gets Deployed Automatically

Your `force-app/main/default/` directory contains all of the following, which will be created in the new org:

| Category | Items |
|----------|-------|
| **Custom Objects** | `Quote_Line_Item__c`, `Resource_Role__c`, `Product__c`, `Add_On__c`, `Organization_Settings__c` |
| **Standard Object Customizations** | `Quote` (custom fields: `Start_Date__c`, `End_Date__c`, `Margin_Amount__c`, `Margin_Percent__c`, `Phase_List__c`, `Total_Amount__c`, `Subtotal_Amount__c`, `Calculated_Discount__c`, `Time_Period__c`) |
| **Apex Classes (13)** | `AccountController`, `AddonController`, `DashboardController`, `OpportunityController`, `OrganizationSettingsController`, `ProductController`, `QuoteController`, `QuoteDownloadPdfController`, `QuoteLineItemController`, `QuotePdfController`, `ResourceRoleController`, `UserContextController`, `UserController` |
| **LWC Components (21)** | `provusExpressApp`, `provusDashboard`, `provusSidebar`, `provusQuotesList`, `provusQuoteDetail`, `provusQuoteLineItems`, `provusQuoteSummary`, `provusQuoteTimeline`, `provusQuotePdf`, `provusAddItemsModal`, `provusCreateQuoteModal`, `provusDeleteModal`, `provusAccountsList`, `provusAddonsList`, `provusProductsList`, `provusResourceRolesList`, `provusOpportunitiesList`, `provusSettings`, `provusRevenueCard`, `provusApprovalHistory`, `provusStatusBadge` |
| **Permission Sets (3)** | `CPQ_Manager_Access`, `CPQ_Salesperson_Access`, `Provus_CPQ_Base` |
| **Profile** | `Admin` (System Administrator overrides) |
| **Layouts (5)** | For `Add_On__c`, `Product__c`, `Quote`, `Quote_Line_Item__c`, `Resource_Role__c` |
| **Lightning App** | `Provus_Express_Quoting` |
| **Flexipages (2)** | `Express_Home`, `Provus_Express_Quoting_UtilityBar` |
| **Custom Tab** | `Express_Home` |
| **VF Page** | `QuoteDownloadPdf` |
| **Settings** | `Quote.settings-meta.xml` (Quotes enabled, Quotes without Opportunities enabled) |

### If Deployment Fails

Common issues and fixes:

| Error | Fix |
|-------|-----|
| `Dependent class is invalid` | Deploy objects first: `sf project deploy start --source-dir force-app/main/default/objects --target-org cpq-ai`, then retry the full deploy |
| `Cannot find profile: CPQ Manager` | This profile doesn't exist yet — see Step 10 |
| `QuotesWithoutOpp not enabled` | The `Quote.settings-meta.xml` should handle this, but if not: Setup → Quote Settings → Enable |

---

## 6. Post-Deploy: Platform Configuration

After the code is deployed, some settings need to be configured **manually in the Salesforce UI** because they can't be set via metadata:

### 6.1 — Set the Default App

1. Open the org: `sf org open --target-org cpq-ai`
2. Go to **App Launcher** (9-dot grid icon) → Search **Provus Express Quoting** → Click to open
3. This should load the `Express_Home` tab with the `provusExpressApp` LWC

### 6.2 — Quote Settings (verify)

1. Setup → **Quote Settings**
2. Ensure:
   - ✅ `Enable Quotes` is ON
   - ✅ `Enable Quotes without Opportunities` is ON (critical for your standalone opportunity pattern)

### 6.3 — Session Settings

1. Setup → **Session Settings**
2. ✅ Enable `Lock sessions to the IP address from which they originated` → **OFF** (for development convenience)
3. ✅ Enable `Clickjack protection` settings as needed

---

## 7. Assign Permission Sets

Run these Anonymous Apex scripts in the new org to assign permission sets to the admin user:

```bash
# Assign CPQ_Manager_Access and Provus_CPQ_Base to the admin user
sf apex run --file assignAdminPermSets.apex --target-org cpq-ai
```

This runs your existing `assignAdminPermSets.apex` script:
```apex
Id adminId = UserInfo.getUserId();
List<PermissionSet> permSets = [
    SELECT Id, Name FROM PermissionSet 
    WHERE Name IN ('CPQ_Manager_Access', 'Provus_CPQ_Base')
];
// ... assigns them to the current user
```

> [!IMPORTANT]
> You must do this **before** using the app, otherwise you'll get "Insufficient Privileges" errors on Apex calls.

---

## 8. Enable Agentforce in the Org

After the org is created and code is deployed:

1. Setup → Search **`Agents`** (or **`Einstein Copilot`**)
2. Toggle **Agentforce** → ON
3. Setup → Search **`Einstein Setup`**
   - Toggle **Turn on Einstein** → ON
   - Accept Terms of Service if prompted
4. Setup → Search **`Agents`** → Click **New Agent**
   - Name: `CPQ Assistant` (or your preferred name)
   - Description: `AI assistant for CPQ Express quoting`
   - Click **Save**

### Configure Agentforce Topics (for CPQ)

Once your agent is created, you can add Topics:

1. Open the Agent → **Topics** tab → **New Topic**
2. Suggested topics for CPQ:
   - **Quote Management**: "Help users create, view, and manage quotes"
   - **Line Items**: "Help users add, edit, and organize quote line items"
   - **Pricing**: "Help users with pricing calculations and discounts"

### Add Agent Actions (Apex Invocable Methods)

To let the agent call your Apex controllers, you'll need to create **Invocable Actions**. This is a future development task — you'll add `@InvocableMethod` annotations to your controllers. Example:

```apex
@InvocableMethod(label='Get Quote Details' description='Returns quote details by ID')
public static List<Quote> getQuoteForAgent(List<Id> quoteIds) {
    return [SELECT Id, Name, Status, GrandTotal FROM Quote WHERE Id IN :quoteIds];
}
```

---

## 9. Enable Einstein AI Features

These must be enabled **in the scratch org itself** after creation:

### 9.1 — Einstein Generative AI

1. Setup → Search **Einstein Generative AI**
2. Toggle → **ON**
3. Select your preferred **AI model** (e.g., OpenAI, Salesforce-hosted)

### 9.2 — Einstein for Developers (Code Assist)

1. Setup → Search **Einstein for Developers**
2. Toggle → **ON**
3. This enables AI code completion in the Salesforce Code Builder / VS Code

### 9.3 — Einstein Copilot for Flows (optional)

1. Setup → Search **Einstein for Flow**
2. Toggle → **ON**
3. This lets you build flows using natural language

### 9.4 — Data Cloud (if needed for AI grounding)

1. Setup → Search **Data Cloud Setup**
2. Follow the guided setup if you need AI grounding on your CPQ data

> [!TIP]
> Not all of these may be available depending on your Dev Hub edition. Start with Einstein Generative AI and Agentforce — those are the most impactful for your use case.

---

## 10. Create Custom Profiles (Manager & Salesperson)

Your `UserController.cls` references two custom profiles that need to exist in the new org:

### 10.1 — CPQ Manager Profile

1. Setup → **Profiles** → **New Profile**
2. Existing Profile: Clone from `Standard User`
3. Profile Name: `CPQ Manager`
4. Save
5. Edit the profile:
   - **Custom Object Permissions**: Full CRUD on all CPQ objects (`Quote_Line_Item__c`, `Resource_Role__c`, `Product__c`, `Add_On__c`, `Organization_Settings__c`)
   - **Standard Object Permissions**: Full CRUD on `Quote`, `Account`, `Opportunity`
   - **Administrative Permissions**: Enable `Manage Users` (so managers can create users via the app)
   - **Apex Class Access**: Enable all 13 Apex classes
   - **Visualforce Page Access**: Enable `QuoteDownloadPdf`
   - **Tab Settings**: Set `Express_Home` to Default On

### 10.2 — CPQ Salesperson Profile

1. Setup → **Profiles** → **New Profile**
2. Existing Profile: Clone from `Standard User`
3. Profile Name: `CPQ Salesperson`
4. Save
5. Edit the profile:
   - **Custom Object Permissions**: Read on `Product__c`, `Add_On__c`, `Resource_Role__c`; CRUD on `Quote_Line_Item__c`
   - **Standard Object Permissions**: CRUD on `Quote`, `Account`; Read on `Opportunity`
   - **Apex Class Access**: Enable all 13 Apex classes
   - **Visualforce Page Access**: Enable `QuoteDownloadPdf`
   - **Tab Settings**: Set `Express_Home` to Default On

> [!NOTE]
> These profiles cannot be included in metadata deployment because Salesforce does not allow deploying **new** custom profiles via source — only the `Admin` profile can be updated via metadata. Custom profiles must be created manually in Setup.

---

## 11. Seed Sample Data (Optional)

If you want test data in the new org, you can export from your old org and import:

### Option A: Manual via Anonymous Apex

```apex
// Create sample Resource Roles
insert new List<Resource_Role__c>{
    new Resource_Role__c(Name='SR001', Name__c='Senior Developer', Price__c=150, Cost__c=80, Billing_Unit__c='Hour', Is_Active__c=true),
    new Resource_Role__c(Name='SR002', Name__c='Project Manager', Price__c=175, Cost__c=95, Billing_Unit__c='Hour', Is_Active__c=true),
    new Resource_Role__c(Name='SR003', Name__c='QA Engineer', Price__c=120, Cost__c=65, Billing_Unit__c='Hour', Is_Active__c=true)
};

// Create sample Products
insert new List<Product__c>{
    new Product__c(Name='PRD001', Name__c='Enterprise License', Price__c=5000, Cost__c=500, Billing_Unit__c='Each', Is_Active__c=true),
    new Product__c(Name='PRD002', Name__c='Support Package', Price__c=2000, Cost__c=200, Billing_Unit__c='Each', Is_Active__c=true)
};

// Create sample Add-Ons
insert new List<Add_On__c>{
    new Add_On__c(Name='AO001', Name__c='Training (per session)', Price__c=1500, Cost__c=300, Billing_Unit__c='Each', Is_Active__c=true)
};

// Create Organization Settings
insert new Organization_Settings__c(
    Company_Name__c='Provus Inc.',
    Email__c='info@provus.com',
    Phone__c='+1 555 123 4567',
    Website__c='www.provus.com',
    Address__c='123 Tech Lane',
    City__c='San Francisco',
    State__c='CA',
    Zip_Code__c='94105',
    Country__c='US'
);
```

Save this as a file and run:
```bash
sf apex run --file seedData.apex --target-org cpq-ai
```

### Option B: Export from Old Org

```bash
# Export from old org
sf data export tree --query "SELECT Id, Name, Name__c, Price__c, Cost__c, Billing_Unit__c, Is_Active__c FROM Resource_Role__c" --output-dir data/ --target-org old-org

# Import to new org
sf data import tree --files data/Resource_Role__c.json --target-org cpq-ai
```

Repeat for `Product__c`, `Add_On__c`, and `Organization_Settings__c`.

---

## 12. Verification Checklist

After completing all steps, verify everything works:

### Deploy & Structure
- [ ] `sf project deploy start` completes with no errors
- [ ] All 5 custom objects exist in Setup → Object Manager
- [ ] All 38 custom fields on the Quote standard object are present
- [ ] All 13 Apex classes are deployed and compiled

### App & UI
- [ ] Open the org → App Launcher → **Provus Express Quoting** loads
- [ ] Dashboard page renders with revenue cards
- [ ] Create a new Quote → verify all fields work
- [ ] Add line items (Resource Role, Product, Add-On) to a quote
- [ ] PDF download works without blank page redirect
- [ ] Settings page → Company Info saves correctly
- [ ] Settings page → Users tab shows user list

### Permissions & Roles
- [ ] Admin can see all role options (Admin, Manager, User) in Create Team Member modal
- [ ] Create a test user with **CPQ Manager** profile → verify they can only create "User" role members
- [ ] Create a test user with **CPQ Salesperson** profile → verify appropriate access limits
- [ ] Permission Sets are assigned correctly

### Einstein & Agentforce
- [ ] Setup → Einstein Setup shows "Einstein is ON"
- [ ] Setup → Agents shows Agentforce is enabled
- [ ] (Optional) Einstein for Developers shows code suggestions in VS Code

---

## 13. Reference: Full Project Inventory

### Custom Objects & Field Counts

| Object | Type | # Fields |
|--------|------|----------|
| `Quote_Line_Item__c` | Custom | 18 (incl. `Phase__c`, `Margin__c`, `Total_Price__c`, etc.) |
| `Resource_Role__c` | Custom | 7 (incl. `Price__c`, `Cost__c`, `Billing_Unit__c`) |
| `Product__c` | Custom | 6 (incl. `Price__c`, `Billing_Unit__c`) |
| `Add_On__c` | Custom | 6 (incl. `Price__c`, `Billing_Unit__c`) |
| `Organization_Settings__c` | Custom | 10 (company info fields) |
| `Quote` | Standard (customized) | 38 total (12 custom: `Start_Date__c`, `End_Date__c`, `Margin_Amount__c`, `Margin_Percent__c`, `Phase_List__c`, `Total_Amount__c`, `Subtotal_Amount__c`, `Calculated_Discount__c`, `Time_Period__c`) |

### Permission Sets

| Name | API Name | Purpose |
|------|----------|---------|
| CPQ Manager Access | `CPQ_Manager_Access` | Full CRUD on all CPQ objects, `modifyAllRecords` enabled |
| CPQ Salesperson Access | `CPQ_Salesperson_Access` | CRUD on Quote/QLI, Read-Only on catalog objects |
| Provus CPQ Base | `Provus_CPQ_Base` | Base-level access needed by all CPQ users |

### Key Configuration Files

| File | Purpose |
|------|---------|
| `config/project-scratch-def.json` | Scratch org definition — **UPDATE THIS** |
| `sfdx-project.json` | SFDX project config (API v66.0) |
| `.forceignore` | Files excluded from source tracking |
| `assignAdminPermSets.apex` | Auto-assigns Manager + Base perm sets to admin |
| `assignPermSets.apex` | Assigns Salesperson + Base perm sets to a specific user |

---

## Quick-Start Command Summary

```bash
# 1. Create the scratch org
sf org create scratch -f config/project-scratch-def.json -a cpq-ai -d 30 -w 10 --set-default

# 2. Deploy all source
sf project deploy start --target-org cpq-ai --wait 15

# 3. Assign admin permission sets  
sf apex run --file assignAdminPermSets.apex --target-org cpq-ai

# 4. Open the org and do manual setup (Steps 6, 8, 9, 10)
sf org open --target-org cpq-ai

# 5. (Optional) Seed data
sf apex run --file seedData.apex --target-org cpq-ai
```

---

> [!CAUTION]
> Scratch orgs expire after 30 days. Make sure all code changes are committed to Git regularly. The source code IS your source of truth — the scratch org is disposable.
