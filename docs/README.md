# Dash Platform Protocol Specification v0.12.0 (Draft)

[Identities](identity.md)
 - [Create](identity.md#identity-creation)
 - Non-implemented stuff
	 - Topup
	 - Update/Reset Key/Close Id
	 - Recovery mechanisms

[Data Contracts](data-contract.md)
 - [Documents](data-contract.md#data-contract-documents)
   - [Properties](data-contract.md#document-properties)
   - [Indices](data-contract.md#document-indices)
 - [Definitions](data-contract.md#data-contract-definitions)

[Document](document.md)

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
