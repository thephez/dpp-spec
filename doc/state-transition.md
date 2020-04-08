# State Transition Overview

# Base Schema

All state transitions are built on the base schema and include the following fields:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type:<br>`1` - data contract<br>`2` - document<br>`3` - identity create |
| signaturePublicKeyId | integer | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition (=> 1)|
| signature | string (base64)| Signature of state transition data (86 characters) |

Each state transition must comply with the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/base.json):


```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "protocolVersion": {
      "type": "number",
      "const": 0
    },
    "type": {
      "type": "number",
      "enum": [1, 2, 3]
    },
    "signaturePublicKeyId": {
      "type": ["integer", "null"],
      "minimum": 1
    },
    "signature": {
      "type": "string",
      "minLength": 86,
      "maxLength": 88,
      "pattern": "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$"
    }
  },
  "required": [
    "protocolVersion",
    "type",
    "signature"
  ],
  "additionalProperties": false
}
```

# Data Contract Schema

| Field | Type | Description|
| - | - | - |
| dataContract | [data contract object](data-contract.md#data-contract-object) | Object containing valid [data contract](data-contract.md) details |

Each data contract state transition must include the [base schema](#base-schema) along with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/data-contract.json):


```json
{
  "$id": "https://schema.dash.org/dpp-0-4-0/state-transition/data-contract",
  "properties": {
    "dataContract": {
      "type": "object"
    }
  },
  "required": [
    "dataContract"
  ]
}
```

# Document Schema

| Field | Type | Description|
| - | - | - |
| actions | array of integers | [Action](document.md#document-actions) the platform should take for the associated document in the `documents` array |
| documents | array of [document objects](document.md#document-object) | [Document(s)](document.md#document-object) |

Each document state transition must include the [base schema](#base-schema) along with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/documents.json):

```json
{
  "$id": "https://schema.dash.org/dpp-0-4-0/state-transition/documents",
  "properties": {
    "actions": {
      "type": "array",
      "items": {
        "type": "number",
        "enum": [1, 2, 4]
      },
      "minItems": 1,
      "maxItems": 10
    },
    "documents": {
      "type": "array",
      "items": {
        "type": "object"
      },
      "minItems": 1,
      "maxItems": 10
    }
  },
  "required": [
    "actions",
    "documents"
  ]
}
```

# Identity Schema

| Field | Type | Description|
| - | - | - |
| lockedOutPoint | string (base64)| Lock [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) from the layer 1 locking transaction (48 characters) |
| identityType | integer | [Type of identity](identity.md#identity-type) (range: 0- 65535) |
| publicKeys | array of keys | [Public key(s)](identity.md#identity-publickeys) associated with the identity (maximum number of keys: 10)|

Each identity create state transition must include the [base schema](#base-schema) along with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/identity/identity.json):

```json
{
  "$id": "https://schema.dash.org/dpp-0-4-0/identity/identity",
  "properties": {
    "id": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "type": {
      "type": "number",
      "multipleOf": 1.0,
      "minimum": 0,
      "maximum": 65535
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100
    }
  },
  "required": [
    "id",
    "type",
    "publicKeys"
  ]
}
```