# Data Trigger Overview

Although [data contracts](data-contract.md) provide much needed constraints on the structure of the data being stored on Dash Platform, there are limits to what they can do. Certain system data contracts may require server-side validation logic to operate effectively. For example, [DPNS](https://dashplatform.readme.io/docs/explanation-dpns) must enforce some rules to ensure names remain DNS compatible. Dash Platform Protocol (DPP) supports this application-specific custom logic using Data Triggers.

# Details

Since all application data is submitted in the form of documents, data triggers are defined in the context of documents. To provide even more granularity, they also incorporate the [document transition action](document.md#document-transition-action) so separate triggers can be created for the CREATE, REPLACE, or DELETE actions.

When document state transitions are received, DPP checks if there is a trigger associated with the document transition type and action. If there is, it then executes the trigger logic.

**Note:** Successful execution of the trigger logic is necessary for the document to be accepted and applied to the platform state.

## Example

As an example, DPP contains several data triggers for DPNS as defined in the [data triggers factory](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_trigger/get_data_triggers_factory.rs). The `domain` document has added constraints for creation. All DPNS document types have constraints on replacing or deleting:

| Data Contract | Document | Action(s) | Trigger Description |
| - | - | - | - |
| DPNS | `domain` | [`CREATE`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/lib/dataTrigger/dpnsTriggers/createDomainDataTrigger.js) | Enforces DNS compatibility, validates provided hashes, and restricts top-level domain (TLD) registration |
| ---- | ----| ---- | ---- |
| DPNS | All Document Types | [`REPLACE`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_trigger/reject_data_trigger.rs) | Prevents updates to existing documents |
| DPNS | All Document Types| [`DELETE`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_trigger/reject_data_trigger.rs) | Prevents deletion of existing documents |

**DPNS Trigger Constraints**

The following table details the DPNS constraints applied via data triggers. These constraints are in addition to the ones applied directly by the DPNS data contract.

| Document | Action | Constraint |
| - | - | - |
| `domain` | `CREATE` | Full domain length <= 253 characters |
| `domain` | `CREATE` | `normalizedLabel` matches lowercase `label` |
| `domain` | `CREATE` | `ownerId` matches `records.dashUniqueIdentityId` or `dashAliasIdentityId` (whichever one is present) |
| `domain` | `CREATE` | Only creating a top-level domain with an authorized identity |
| `domain` | `CREATE` | Referenced `normalizedParentDomainName` must be an existing parent domain |
| `domain` | `CREATE` | Subdomain registration for non top level domains prevented if `subdomainRules.allowSubdomains` is true |
| `domain` | `CREATE` | Subdomain registration only allowed by the parent domain owner if `subdomainRules.allowSubdomains` is false |
| `domain` | `CREATE` | Referenced `preorder` document must exist |
| `domain` | `REPLACE` | Action not allowed |
| `domain` | `DELETE` | Action not allowed |
| `preorder` | `REPLACE` | Action not allowed |
| `preorder` | `DELETE` | Action not allowed |

# Data Trigger Validation

## State Transition Data

Data validation verifies that the data in the data trigger is valid in the context of the current platform state. The trigger data must pass validation tests as defined in [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/integration/document/stateTransition/DocumentsBatchTransition/validation/state/executeDataTriggersFactory.spec.js). The test output below shows the necessary criteria:

```text
  executeDataTriggersFactory
    ✔ should return an array of DataTriggerExecutionResult
    ✔ should execute multiple data triggers if there is more than one data trigger for the same document and action in the contract
    ✔ should return a result for each passed document with success or error
    ✔ should not call any triggers if documents have no triggers associated with it's type or action
    ✔ should call only one trigger if there's one document with a trigger and one without
    ✔ should not call any triggers if there's no triggers in the contract
```

An additional validation occurs related to document batch state transition as defined in [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/unit/document/stateTransition/DocumetsBatchTransition/validation/state/validateDocumentsBatchTransitionStateFactory.spec.js#L401):

```text
validateDocumentsBatchTransitionStateFactory
  -- Truncated
  ✔ should return invalid result if data triggers execution failed
  -- Truncated
```

## DPNS Trigger Validation

Only DPNS, DashPay, Feature Flags, and Reward Shares are able to use data triggers. Their data triggers are defined in [js-dpp](https://github.com/dashpay/platform/tree/v0.24.5/packages/js-dpp/lib/dataTrigger). See here for some [validation tests](https://github.com/dashpay/platform/tree/v0.24.5/packages/js-dpp/test/unit/dataTrigger/):

```text
createContactRequestDataTrigger
  ✔ should successfully execute if document is valid
  ✔ should successfully execute if document has no `coreHeightCreatedAt` field
  ✔ should fail with out of window error
  ✔ should successfully execute on dry run
  ✔ should fail if ownerId equals toUserId
  ✔ should fail if toUserId does not exist

createDomainDataTrigger
  ✔ should successfully execute if document is valid
  ✔ should fail with invalid normalizedLabel
  ✔ should fail with invalid parent domain
  ✔ should fail with invalid dashUniqueIdentityId
  ✔ should fail with invalid dashAliasIdentityId
  ✔ should fail with preorder document was not found
  ✔ should fail with invalid full domain name length
  ✔ should fail with identity can't create top level domain
  ✔ should fail with disallowed domain creation
  ✔ should fail with allowing subdomains for non top level domain
  ✔ should allow creating a second level domain by any identity
  ✔ should return DataTriggerExecutionResult om dry run

createFeatureFlagDataTrigger
  ✔ should return an error if height is lower than block height
  ✔ should return an error if owner id is not equal to top level identity id
  ✔ should pass
  ✔ should pass on dry run

getDataTriggers
  ✔ should return matching triggers
  ✔ should return empty trigger array for any other type except `domain`

rejectDataTrigger
  ✔ should always fail

createMasternodeRewardSharesDataTrigger
  ✔ should return an error if percentage > 10000
  ✔ should return an error if payToId does not exist
  ✔ should return an error if ownerId is not a masternode identity
  ✔ should pass
  ✔ should pass on dry run
  ✔ should return an error if there are 16 stored shares
```
