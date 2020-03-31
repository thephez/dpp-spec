# Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts: [documents](document.md#document-overview) and [definitions](document.md#definition-overview). All data contracts must define one or more documents, whereas definitions are optional and may not be used for simple contracts.

# General Constraints

**Note:** There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/meta/data-contract.json)).

## Keyword

| Keyword | Constraint |
| - | - |
| `default` | Restricted - cannot be used (defined in DPP logic) |
| `propertyNames` | Restricted - cannot be used (defined in DPP logic) |
| `uniqueItems: true` | `maxItems` must be defined (maximum: 100000) |
| `pattern: <something>` | `maxLength` must be defined (maximum: 50000) |
| `format: <something>` | `maxLength` must be defined (maximum: 100000) |
| `$ref: <something>` | `$ref` can only reference `definitions` - <br> remote references not supported |

## Data Size
Additionally, there are several constraints limiting the overall size of data contracts and related data as defined here:

**Note:** These constraints are defined in the Dash Platform Protocol logic (not in JSON Schema).

| Description | Constraint |
| - | - |
| Maximum size of serialized data contract | [15 KB](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/errors/DataContractMaxByteSizeExceededError.js#L23) |
| Maximum size of CBOR-encoded data | [16 KB](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/util/serializer.js#L5) |


# Data Contract Creation

Data contracts are created on the platform by submitting the contract information in a data contract state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`1` for data contract) |
| dataContract | [data contract object](#data-contract-object) | Object containing the data contract details
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | string | Signature of state transition data |

Each data contract must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/data-contract.json) (in addition to the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/base.json) that is required for all state transitions):

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

Details regarding the `dataContract` object may be found in the [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/meta/data-contract.json).


**Example State Transition**

```json
{
  "protocolVersion": 0,
  "type": 1,
  "dataContract": {
    "$schema": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
    "contractId": "EzLBmQdQXYMaoeXWNaegK18iaaCDShitN3s14US3DunM",
    "version": 1,
    "documents": {
      "note": {
        "properties": {
          "message": {
            "type": "string"
          }
        },
        "additionalProperties": false
      }
    }
  },
  "signaturePublicKeyId": 1,
  "signature": "H8INAUHtjfW3sL/Z7JQC+915QrVUb6eqpXzaB/21N3i2GOESqvrEVgUbAZNm0wh6BXFJScNKkQG6TLHknViWXWA=",
}
```

## Data Contract Object

The `dataContract` object in the state transition consists of the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/dataContract/RawDataContractInterface.js)):

| Property | Type | Required | Description |
| - | - | - | - |
| $schema | string | Yes  | A valid URL (default: https://schema.dash.org/dpp-0-4-0/meta/data-contract)
| $contractId | string | Yes | [Identity](identity.md) that registered the data contract defining the document (Base58, 42-44 characters) |
| version | integer | Yes | Data Contract version (>= 1) (default: 1) (remove in 0.12 - see [https://github.com/dashevo/js-dpp/pull/128/](https://github.com/dashevo/js-dpp/pull/128)) |
| documents | object | Yes | Document definitions (see [Documents](document.md) for details) |
| definitions | object | No | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with <= 100 valid properties) |

**Example**

```json
{
  "$schema": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
  "contractId": "EzLBmQdQXYMaoeXWNaegK18iaaCDShitN3s14US3DunM",
  "version": 1,
  "documents": {
    "note": {
      "properties": {
        "message": {
          "type": "string"
        }
      },
      "additionalProperties": false
    }
  },
  "definitions": {}
}
```

## Data Contract State Transition Signing

Data contract state transitions must be signed by a private key associated with the contract's identity.

The process to sign a data contract state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the `contractId`
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step
4. Set the state transition`signaturePublicKeyId` to the [public key `id`](#public-key-id) corresponding to the key used to sign
