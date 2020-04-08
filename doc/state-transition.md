# State Transition Overview

 State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state. Each one must contain:
 - All fields defined in the [base schema](#base-schema)
 - Additional fields specific to the type of action the state transition provides (e.g. [creating an identity](#identity-create-schema))

# Base Schema

All state transitions are built on the base schema and include the following fields:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type:<br>`1` - data contract<br>`2` - document<br>`3` - identity create |
| signaturePublicKeyId | integer | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition (=> 1)|
| signature | string (base64)| Signature of state transition data (86-88 characters) |

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

# State Transition Types

## Data Contract

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

More detailed information about the `dataContract` object can be found in the [data contract section](data-contract.md).

## Document

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

More detailed information about the `actions` and `documents` objects can be found in the [document section](document.md).

## Identity Create

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

More detailed information about the `id`, `type`, and `publicKeys` objects can be found in the [identity section](identity.md).

# State Transition Signing

State transitions must be signed by a private key associated with the identity creating the state transition.

The process to sign a state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the identity creating the state transition
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step
4. Set the state transition`signaturePublicKeyId` to the [public key `id`](identity.md#public-key-id) corresponding to the key used to sign

