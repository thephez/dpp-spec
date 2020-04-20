# Dash Platform Protocol Specification v0.12.0

[Identities](identity.md)
 - Create
 - Non-implemented stuff
	 - Topup
	 - Balance
	 - Update/Reset Key/Close Id
	 - Recovery mechanisms

[Data Contracts](data-contract.md)
 - [Documents](document.md#document-overview)
   - [Properties](document.md#document-properties)
   - [Indices](document.md#document-indices)
 - [Definitions](document.md#definition-overview)

[State Transitions](state-transition.md)
 - [Overview / general structure](state-transition.md)
 - Types
   - [Identity Create ST](identity.md#identity-creation)
   - [Data Contract ST](data-contract.md#data-contract-creation)
   - [Document ST](document.md#document-submission)
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
