# State Transition Overview

# Base Schema

All state transitions are built on the base schema and include the following fields:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type:<br>`1` - data contract<br>`2` - document<br>`3` - identity create |
| signaturePublicKeyId | integer | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition (=> 1)|
| signature | string (base64)| Signature of state transition data (86 characters)|


# Data Contract Schema

| Field | Type | Description|
| - | - | - |
| dataContract | [data contract object](data-contract.md#data-contract-object) | Object containing the [data contract](data-contract.md) details |

# Document Schema

| Field | Type | Description|
| - | - | - |
| actions | array of integers | [Action](document.md#document-actions) the platform should take for the associated document in the `documents` array |
| documents | array of [document objects](document.md#document-object) | [Document(s)](document.md#document-object) |

# Identity Schema

| Field | Type | Description|
| - | - | - |
| lockedOutPoint | string | Lock [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) from the layer 1 locking transaction |
| identityType | integer | [Type of identity](identity.md#identity-type) |
| publicKeys | array of keys | [Public key(s)](identity.md#identity-publickeys) associated with the identity |
