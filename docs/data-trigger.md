# Data Trigger Overview

Although [data contracts](data-contract.md) provide much needed constraints on the structure of the data being stored on Dash Platform, there are limits to what they can do. Certain system data contracts may require server-side validation logic to operate effectively. For example, [DPNS](https://dashplatform.readme.io/docs/explanation-dpns) must enforce some rules to ensure names remain DNS compatible. Dash Platform Protocol (DPP) supports this application-specific custom logic using Data Triggers.

# Details

Since all application data is submitted in the form of documents, data triggers are defined in the context of documents. To provide even more granularity, they also incorporate the [document transition action](document.md#document-transition-action) so separate triggers can be created for the CREATE, REPLACE, or DELETE actions.

## Example

As an example, DPP contains several data triggers for DPNS. The preorder document has no extra constraints, but the domain document requires additional validation:

| Data Contract | Document | Action | Trigger Description |
| - | - | - | - |
| DPNS | `domain` | [`CREATE`](https://github.com/dashevo/js-dpp/blob/v0.12.1/lib/dataTrigger/dpnsTriggers/createDomainDataTrigger.js) | Enforces DNS compatibility, validate provided hashes, and restrict top-level domain (TLD) registration |
| DPNS | `domain` | [`REPLACE`](https://github.com/dashevo/js-dpp/blob/v0.12.1/lib/dataTrigger/dpnsTriggers/updateDomainDataTrigger.js) | Prevents updates to existing domains |
| DPNS | `domain` | [`DELETE`](https://github.com/dashevo/js-dpp/blob/v0.12.1/lib/dataTrigger/dpnsTriggers/deleteDomainDataTrigger.js) | Prevents deletion of existing domains |
| ---- | ----| ---- | ---- |
| DPNS | `preorder` | `CREATE`, `REPLACE`, `DELETE` | No triggers defined for preorders |

When document state transitions are received, DPP checks if there is a trigger associated with the document transition type and action. If there is, it then executes the trigger logic. Successful execution of the trigger logic is necessary for the document to be accepted and applied to the platform state.

# Data Trigger Validation

## State Transition Data

Data validation verifies that the data in the data trigger is valid in the context of the current platform state. The trigger data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.1/test/integration/document/stateTransition/validation/data/executeDataTriggersFactory.spec.js). The test output below shows the necessary criteria:

```
  executeDataTriggersFactory
    ✓ should return an array of DataTriggerExecutionResult
    ✓ should execute multiple data triggers if there is more than one data trigger for the same document and action in the contract
    ✓ should return a result for each passed document with success or error
    ✓ should not call any triggers if documents have no triggers associated with it's type or action
    ✓ should call only one trigger if there's one document with a trigger and one without
    ✓ should not call any triggers if there's no triggers in the contract
```

An additional validation occurs related to document batch state transition as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.1/test/unit/document/stateTransition/data/validateDocumentsBatchTransitionDataFactory.spec.js#L325):

```
  validateDocumentsBatchTransitionDataFactory
    ✓ should return invalid result if data triggers execution failed
```

## DPNS Trigger Validation

As of DPP v0.12, only DPNS is able to use data triggers. Its data triggers are defined in [js-dpp](https://github.com/dashevo/js-dpp/tree/v0.12.1/test/unit/dataTrigger/dpnsTriggers) and have some DPNS-specific [validation tests](https://github.com/dashevo/js-dpp/tree/v0.12.1/test/unit/dataTrigger/dpnsTriggers):


```
  createDomainDataTrigger
    ✓ should successfully execute if document is valid
    ✓ should fail with invalid hash
    ✓ should fail with invalid normalizedLabel
    ✓ should fail with invalid parent domain
    ✓ should fail with invalid ownerId
    ✓ should fail with preorder document was not found
    ✓ should fail with hash not being a valid multihash
    ✓ should fail with invalid full domain name length
    ✓ should fail with normalizedParentDomainName not being lower case
    ✓ should fail with identity can't create top level domain

  deleteDomainDataTrigger
    ✓ should always fail

  updateDomainDataTrigger
    ✓ should always fail

  getDataTriggers
    ✓ should return matching triggers
    ✓ should return empty trigger array for any other type except `domain`
```    

