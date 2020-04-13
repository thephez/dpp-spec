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

## Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined.

Include the following at the same level as the `properties` keyword to ensure proper validation:
```json
"additionalProperties": false
```

# Data Contract Object

The data contract object consists of the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/dataContract/RawDataContractInterface.js)):

| Property | Type | Required | Description |
| - | - | - | - |
| $schema | string | Yes  | A valid URL (default: https://schema.dash.org/dpp-0-4-0/meta/data-contract)
| $contractId | string (base58) | Yes | [Identity](identity.md) that registered the data contract defining the document (42-44 characters) |
| version | integer | Yes | Data Contract version (>= 1) (default: 1) (remove in 0.12 - see [https://github.com/dashevo/js-dpp/pull/128/](https://github.com/dashevo/js-dpp/pull/128)) |
| documents | object | Yes | Document definitions (see [Documents](document.md) for details) |
| definitions | object | No | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with <= 100 valid properties) |

## Data Contract Documents

More detailed information about `documents` objects can be found in the [document section](document.md).

## Data Contract Definitions

The optional `definitions` object enables definition of aspects of a schema that are used in multiple places. This is done using the JSON Schema support for [reuse](https://json-schema.org/understanding-json-schema/structuring.html#reuse). Items defined in `definitions` may then be referenced when defining `documents` through use of the `$ref` keyword.

**Note:** Properties defined in the `definitions` object must meet the same criteria as those defined in the `documents` object.

**Note:** Data contracts can only use the `$ref` keyword to reference their own `definitions`. Referencing external definitions is not supported by the platform protocol.

**Example**
The following example shows a definition for a `message` object consisting of two properties:

```json
{
  // Preceeding content truncated ...
  "definitions": {
    "message": {
      "type": "object",
      "properties": {
        "timestamp": {
          "type": "number"
        },
        "description": {
          "type": "string"
        }
      },
      "additionalProperties": false
    }
  }
}
```

**Note:** In the `js-dpp` reference implementation, definitions are added to a data contract via the `.setDefinitions()` method (e.g. `myContract.setDefinitions({\"message\": { ... }})`. This must be done prior to broadcasting the contract for registration.

## Data Contract Schema

Details regarding the data contract object may be found in the [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/meta/data-contract.json). A truncated version is shown below for reference:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "$id": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
  "type": "object",
  "definitions": {
    // Truncated ...
  },
  "properties": {
    "$schema": {
      "type": "string",
      "const": "https://schema.dash.org/dpp-0-4-0/meta/data-contract"
    },
    "contractId":{
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "version": {
      "type": "number",
      "multipleOf": 1.0,
      "minimum": 1
    },
    "documents": {
      "type": "object",
      // Truncated ...
      "propertyNames": {
        "pattern": "^((?!-|_)[a-zA-Z0-9-_]{0,62}[a-zA-Z0-9])$"
      },
      "minProperties": 1,
      "maxProperties": 100
    },
    "definitions": {
      "$ref": "#/definitions/documentProperties"
    }
  },
  "required": [
    "$schema",
    "contractId",
    "version",
    "documents"
  ],
  "additionalProperties": false
}
```

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

# Data Contract Creation

Data contracts are created on the platform by submitting the [data contract object](#data-contract-object) in a data contract state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`1` for data contract) |
| dataContract | [data contract object](#data-contract-object) | Object containing the data contract details
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | string | Signature of state transition data |

Each data contract state transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/data-contract.json) (in addition to the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/base.json) that is required for all state transitions):

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

## Data Contract State Transition Signing

Data contract state transitions must be signed by a private key associated with the contract's identity.

The process to sign a data contract state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the `contractId`
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step
4. Set the state transition`signaturePublicKeyId` to the [public key `id`](#public-key-id) corresponding to the key used to sign

# Data Contract Validation

The platform protocol performs several forms of validation on data contract state transitions: structure validation and data validation.

- Structure validation - only checks the content of the state transition
- Data validation - takes the overall platform state into consideration

**Example:** A data contract state transition for an existing application could pass structure validation; however, it would fail data validation if it used an application identity that has already created a data contract.

## State Transition Structure






## State Transition Structure

Structure validation verifies that the content of state transition fields complies with the requirements for the field. The data contract `contractId` and `signature` fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/unit/dataContract/stateTransition/validation/validateDataContractSTStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateDataContractSTStructureFactory
  ✓ should return invalid result if Data Contract Identity is invalid
  ✓ should return invalid result if data contract is invalid
  ✓ should return invalid result on invalid signature
```

* See the [state transition document](state-transition.md) for signature validation details.

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/unit/dataContract/stateTransition/validation/validateDataContractSTDataFactory.spec.js). The test output below shows the necessary criteria:

```
validateDataContractSTDataFactory
  ✓ should return invalid result if Data Contract with specified contractId is already exist
```

## Contract Depth

Verifies that the data contract's JSON-Schema depth is not greater than the maximum ([500](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/errors/DataContractMaxDepthExceedError.js#L9)) (see [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/unit/dataContract/stateTransition/validation/validateDataContractMaxDepthFactory.spec.js)). The test output below shows the necessary criteria:

```
validateDataContractMaxDepthFactory
  ✓ should throw error if depth > MAX_DEPTH
  ✓ should return valid result if depth = MAX_DEPTH
  ✓ should throw error if contract contains array with depth > MAX_DEPTH
  ✓ should return error if refParser throws an error
```

**Note:** Additional validation rules will be added in future versions.
