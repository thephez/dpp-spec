# Overview

Although data contracts provide much needed constraints on the structure of the data being stored on Dash Platform, there are limits to what they can do. Certain system data contracts may require server-side validation logic to operate effectively. For example, DPNS must enforce some rules to ensure names remain DNS compatible. Dash Platform Protocol (DPP) supports this application-specific custom logic using Data Triggers.

# Details

Since all application data is submitted in the form of documents, data triggers are defined in the context of documents. To provide even more granularity, they also incorporate the document action so separate triggers can be created for the CREATE, REPLACE, or DELETE actions.

## Example

As an example, DPP contains several data triggers for DPNS. The preorder document has no extra constraints, but the domain document requires additional validation:

| Data Contract | Document | Action(s) | Trigger Description |
| - | - | - | - |
| DPNS | `domain` | [`CREATE`](https://github.com/dashevo/js-dpp/blob/master/lib/dataTrigger/dpnsTriggers/createDomainDataTrigger.js) | Enforces DNS compatibility, validate provided hashes, and restrict top-level domain (TLD) registration |
| DPNS | `domain` | [`REPLACE`](https://github.com/dashevo/js-dpp/blob/master/lib/dataTrigger/dpnsTriggers/updateDomainDataTrigger.js) | Prevents updates to existing domains |
| DPNS | `domain` | [`DELETE`](https://github.com/dashevo/js-dpp/blob/master/lib/dataTrigger/dpnsTriggers/deleteDomainDataTrigger.js) | Prevents deletion of existing domains |
| ---- | ----| ---- | ---- |
| DPNS | `preorder` | `CREATE`, `REPLACE`, `DELETE` | No triggers defined for preorders |

When document state transitions are received, DPP checks if there is a trigger associated with the document type and action. If there is, it then executes the trigger logic. Successful execution of the trigger logic is necessary for the document to be accepted and applied to the platform state.


