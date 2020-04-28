# Dash Platform Protocol Specification v0.12.0

[Identities](docs/identity.md)
 - [Create](docs/identity.md#identity-creation)
 - Non-implemented stuff
	 - Topup
	 - Update/Reset Key/Close Id
	 - Recovery mechanisms

[Data Contracts](docs/data-contract.md)
 - [Documents](docs/document.md#document-overview)
   - [Properties](docs/document.md#document-properties)
   - [Indices](docs/document.md#document-indices)
 - [Definitions](docs/document.md#definition-overview)

[State Transitions](docs/state-transition.md)
 - [Overview / general structure](docs/state-transition.md)
 - Types
   - [Identity Create ST](docs/identity.md#identity-creation)
   - [Data Contract ST](docs/data-contract.md#data-contract-creation)
   - [Document Batch ST](docs/document.md#document-submission)
     - Document Transitions
       - [Document Transition Base](docs/document.md#document-base-transition)
       - [Document Create Transition](docs/document.md#document-create-transition)
       - [Document Replace Transition](docs/document.md#document-replace-transition)
       - [Document Delete Transition](docs/document.md#document-delete-transition)
 - [Signing](docs/state-transition.md#state-transition-signing)

Serialization
 - Base 64
 - Canonical CBOR

Hashing

Validation
 - JSON-Schema
 - Logic

~~Data Triggers~~
~~- DPNS is using multihash for the nameHash~~
