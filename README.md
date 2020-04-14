# Dash Platform Protocol Specification

[Identities](docs/identity.md)
 - Type (remove in 0.12)
 - Create
 - Non-implemented stuff
	 - Topup
	 - Balance
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
   - [Document ST](docs/document.md#document-submission)
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
