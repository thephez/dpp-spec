# Dash Platform Protocol Specification v0.12.0

[Identities](identity.md)
 - [Create](identity.md#identity-creation)
 - Non-implemented stuff
	 - Topup
	 - Update/Reset Key/Close Id
	 - Recovery mechanisms

[Data Contracts](data-contract.md)
 - [Documents](data-contract-documents.md)
   - [Properties](data-contract-documents.md#document-properties)
   - [Indices](data-contract-documents.md#document-indices)
 - [Definitions](data-contract.md#data-contract-definitions)

[State Transitions](state-transition.md)
 - [Overview / general structure](state-transition.md)
 - Types
   - [Identity Create ST](identity.md#identity-creation)
   - [Data Contract ST](data-contract.md#data-contract-creation)
   - [Document Batch ST](document.md)
     - Document Transitions
       - [Document Transition Base](document.md#document-base-transition)
       - [Document Create Transition](document.md#document-create-transition)
       - [Document Replace Transition](document.md#document-replace-transition)
       - [Document Delete Transition](document.md#document-delete-transition)
 - [Signing](state-transition.md#state-transition-signing)

Serialization
 - Base 64
 - Canonical CBOR

Hashing

Validation
 - JSON-Schema
 - Logic

~~Data Triggers~~
~~- DPNS is using multihash for the nameHash~~
