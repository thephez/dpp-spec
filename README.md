# Dash Platform Protocol Specification

[Identities](doc/identity.md)
 - Type (remove in 0.12)
 - Create
 - Non-implemented stuff
	 - Topup
	 - Balance
	 - Update/Reset Key/Close Id
	 - Recovery mechanisms

[Data Contracts](doc/data-contract.md)
 - [Documents](doc/document.md#document-overview)
   - Properties
   - Indices
 - [Definitions](doc/document.md#definition-overview)

State Transitions
 - Overview / general structure
 - [Identity ST](doc/identity.md#identity-registration)
 - [Data Contract ST](doc/data-contract.md#data-contract-registration)
 - Document ST

Serialization
 - Base 64
 - Canonical CBOR

Hashing

Validation
 - JSON-Schema
 - Logic

~~Data Triggers~~
~~- DPNS is using multihash for the nameHash~~
