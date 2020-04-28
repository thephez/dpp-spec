# Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts: [documents](document.md#document-overview) and [definitions](document.md#definition-overview). All data contracts must define one or more documents, whereas definitions are optional and may not be used for simple contracts.

# General Constraints

**Note:** There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/dataContract/dataContractMeta.json)).

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

**Note:** These constraints are defined in the Dash Platform Protocol logic (not in JSON Schema).

All serialized data (including state transitions) is limited to a maximum size of [16 KB](https://github.com/dashevo/js-dpp/blob/v0.12.0/lib/util/serializer.js#L5).

## Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined.

Include the following at the same level as the `properties` keyword to ensure proper validation:
```json
"additionalProperties": false
```

# Data Contract Object

The data contract object consists of the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/dataContract/dataContractMeta.json)):

| Property | Type | Required | Description |
| - | - | - | - |
| $schema | string | Yes  | A valid URL (default: https://schema.dash.org/dpp-0-4-0/meta/data-contract)
| $id | string (base58) | Yes | Contract ID generated from `ownerId` and entropy (42-44 characters) |
| ownerId | string (base58) | Yes | [Identity](identity.md) that registered the data contract defining the document (42-44 characters) |
| documents | object | Yes | Document definitions (see [Documents](document.md) for details) |
| definitions | object | No | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with <= 100 valid properties) |

## Data Contract id

The data contract `$id` is created by base58 encoding the hash of the `ownerId` and entropy as shown [here](https://github.com/dashevo/js-dpp/blob/v0.12.0/lib/dataContract/generateDataContractId.js).

```javascript
// From the JavaScript reference implementation (js-dpp)
// generateDataContractId.js
function generateDataContractId(ownerId, entropy) {
  return bs58.encode(
    hash(
      Buffer.concat([
        bs58.decode(ownerId),
        bs58.decode(entropy),
      ]),
    ),
  );
}
```

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

**Note:** In the `js-dpp` reference implementation, definitions are added to a data contract via the `.setDefinitions()` method (e.g. `myContract.setDefinitions({\"message\": { ... }})`). This must be done prior to broadcasting the contract for registration.

## Data Contract Schema

Details regarding the data contract object may be found in the [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/dataContract/dataContractMeta.json). A truncated version is shown below for reference:

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
    "$id":{
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "ownerId":{
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
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
    "$id",
    "ownerId",
    "documents"
  ],
  "additionalProperties": false
}
```

**Example**

```json
{
  "id": "E7Kh5MbMuTmGTHzyfpKZ9erRzu1fNa4JZYd6sJFDLbqh",
  "ownerId": "HcgaeTzwiwGMTpYFDBJuKERv8kjbDS2oDGDkQ4SN4Mi1",
  "schema": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
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
  "definitions": {},
  "entropy": "yRx116Yipokd6ueHW2NN8prZxgS2uUttqC"
}
```

# Data Contract Creation

Data contracts are created on the platform by submitting the [data contract object](#data-contract-object) in a data contract create state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`0` for data contract) |
| dataContract | [data contract object](#data-contract-object) | Object containing the data contract details
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | string | Signature of state transition data |
| entropy | string (base58) | Entropy used to generate the data contract ID. Generated as [shown here](state-transition.md#entropy-generation). |

Each data contract state transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/dataContract/stateTransition/dataContractCreate.json) (in addition to the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/stateTransition/stateTransitionBase.json) that is required for all state transitions):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "dataContract": {
      "type": "object"
    },
    "entropy": {
      "type": "string",
      "minLength": 26,
      "maxLength": 35,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    }
  },
  "required": [
    "dataContract",
    "entropy"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion": 0,
  "type": 0,
  "dataContract": {
    "$id": "E7Kh5MbMuTmGTHzyfpKZ9erRzu1fNa4JZYd6sJFDLbqh",
    "$schema": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
    "ownerId": "HcgaeTzwiwGMTpYFDBJuKERv8kjbDS2oDGDkQ4SN4Mi1",
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
  "entropy": "yRx116Yipokd6ueHW2NN8prZxgS2uUttqC",
  "signaturePublicKeyId": 0,
  "signature": "H9Z4mWQNzJWLkMlih450FiMDLybLZeyzbJT95ubyYIQfZcVFqEnABtLcoHb4Fi+AAhUUtHG0AaGmSiLgjQxjo8k=",
}
```

## Data Contract State Transition Signing

Data contract state transitions must be signed by a private key associated with the contract's identity.

The process to sign a data contract state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the `contractId`
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step
4. Set the state transition`signaturePublicKeyId` to the [public key `id`](identity.md#public-key-id) corresponding to the key used to sign

# Data Contract Validation

The platform protocol performs several forms of validation related to data contracts: model validation, structure validation, and data validation.
 - Model validation - ensures object models are correct
 - State transition structure validation - only checks the content of the state transition
 - State transition data validation - takes the overall platform state into consideration

**Example:** A data contract state transition for an existing application could pass structure validation; however, it would fail data validation if it used an application identity that has already created a data contract.

## Data Contract Model

The data contract model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/integration/dataContract/validateDataContractFactory.spec.js). The test output below (split into 3 sections for readability) shows the necessary criteria:

```
 validateDataContractFactory
   ✓ should return invalid result with circular $ref pointer
   ✓ should return valid result if Data Contract is valid

   $schema
     ✓ should be present
     ✓ should be a string
     ✓ should be a particular url
   ownerId
     ✓ should be present
     ✓ should be a string
     ✓ should be no less than 42 chars
     ✓ should be no longer than 44 chars
     ✓ should be base58 encoded
   $id
     ✓ should be present
     ✓ should be a string
     ✓ should be no less than 42 chars
     ✓ should be no longer than 44 chars
     ✓ should be base58 encoded
   definitions
     ✓ may not be present
     ✓ should be an object
     ✓ should not be empty
     ✓ should have no non-alphanumeric properties
     ✓ should have no more than 100 properties
     ✓ should have valid property names
     ✓ should return an invalid result if a property has invalid format
```

### Document Validation
```
   documents
     ✓ should be present
     ✓ should be an object
     ✓ should not be empty
     ✓ should have valid property names (document types)
     ✓ should return an invalid result if a property (document type) has invalid format
     ✓ should have no more than 100 properties
     Document schema
       ✓ should not be empty
       ✓ should have type "object"
       ✓ should have "properties"
       ✓ should have nested "properties"
       ✓ should have valid property names
       ✓ should have valid nested property names
       ✓ should return an invalid result if a property has invalid format
       ✓ should return an invalid result if a nested property has invalid format
       ✓ should have "additionalProperties" defined
       ✓ should have "additionalProperties" defined to false
       ✓ should have nested "additionalProperties" defined
       ✓ should return invalid result if there are additional properties
       ✓ should have no more than 100 properties
       ✓ should have defined items for arrays
       ✓ should not have additionalItems for arrays if items is subschema
       ✓ should have additionalItems for arrays
       ✓ should have additionalItems disabled for arrays
       ✓ should not have additionalItems enabled for arrays
       ✓ should return invalid result if "default" keyword is used
       ✓ should return invalid result if remote `$ref` is used
       ✓ should not have `propertyNames`
       ✓ should have `maxItems` if `uniqueItems` is used
       ✓ should have `maxItems` no bigger than 100000 if `uniqueItems` is used
       ✓ should return invalid result if document JSON Schema is not valid
       ✓ should have `maxLength` if `pattern` is used
       ✓ should have `maxLength` no bigger than 50000 if `pattern` is used
       ✓ should have `maxLength` if `format` is used
       ✓ should have `maxLength` no bigger than 50000 if `format` is used
```

### Index Validation
```
   indices
     ✓ should be an array
     ✓ should have at least one item
     ✓ should return invalid result if there are duplicated indices
     index
       ✓ should be an object
       ✓ should have properties definition
       ✓ should have "unique" flag to be of a boolean type
       ✓ should have no more than 10 indices
       ✓ should have no more than 3 unique indices
       ✓ should return invalid result if indices has undefined property
       ✓ should return invalid result if index property is object
       ✓ should return invalid result if index property is array of objects
       ✓ should return invalid result if index property is array of arrays
       ✓ should return invalid result if index property is array with many item definitions
       ✓ should return invalid result if index property is a single $id
       properties definition
         ✓ should be an array
         ✓ should have at least one property defined
         ✓ should have no more than 10 property definitions
         property definition
           ✓ should be an object
           ✓ should have at least one property
           ✓ should have no more than one property
           ✓ should have property values only "asc" or "desc"
```

## State Transition Structure

Structure validation verifies that the content of state transition fields complies with the requirements for the field. The data contract `contractId` and `signature` fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/unit/dataContract/stateTransition/validation/validateDataContractCreateTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateDataContractCreateTransitionStructureFactory
  ✓ should return invalid result if Data Contract Identity is invalid
  ✓ should return invalid result if data contract is invalid
  ✓ should return invalid result on invalid signature
  ✓ should return invalid result on invalid Data Contract id
  ✓ should return invalid result on invalid entropy
```

* See the [state transition document](state-transition.md) for signature validation details.

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/unit/dataContract/stateTransition/validation/validateDataContractCreateTransitionDataFactory.spec.js). The test output below shows the necessary criteria:

```
validateDataContractCreateTransitionDataFactory
  ✓ should return invalid result if Data Contract with specified contractId is already exist
```

## Contract Depth

Verifies that the data contract's JSON-Schema depth is not greater than the maximum ([500](https://github.com/dashevo/js-dpp/blob/v0.12.0/lib/errors/DataContractMaxDepthExceedError.js#L9)) (see [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/unit/dataContract/stateTransition/validation/validateDataContractMaxDepthFactory.spec.js)). The test output below shows the necessary criteria:

```
validateDataContractMaxDepthFactory
  ✓ should throw error if depth > MAX_DEPTH
  ✓ should return valid result if depth = MAX_DEPTH
  ✓ should throw error if contract contains array with depth > MAX_DEPTH
  ✓ should return error if refParser throws an error
```

**Note:** Additional validation rules will be added in future versions.
