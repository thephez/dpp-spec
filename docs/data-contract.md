# Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts: [documents](#data-contract-documents) and [definitions](#data-contract-definitions). All data contracts must define one or more documents, whereas definitions are optional and may not be used for simple contracts.

# General Constraints

**Note:** There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [js-dpp data contract meta schema](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/dataContractMeta.json)).

## Keyword

| Keyword | Constraint |
| - | - |
| `default` | Restricted - cannot be used (defined in DPP logic) |
| `propertyNames` | Restricted - cannot be used (defined in DPP logic) |
| `uniqueItems: true` | `maxItems` must be defined (maximum: 100000) |
| `pattern: <something>` | `maxLength` must be defined (maximum: 50000) |
| `format: <something>` | `maxLength` must be defined (maximum: 50000) |
| `$ref: <something>` | `$ref` can only reference `$defs` - <br> remote references not supported |
| `if`, `then`, `else`, `allOf`, `anyOf`, `oneOf`, `not` | Disabled for data contracts |

## Data Size

**Note:** These constraints are defined in the Dash Platform Protocol logic (not in JSON Schema).

All serialized data (including state transitions) is limited to a maximum size of [16 KB](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/lib/util/serializer.js#L5).

## Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined (including within document properties of type `object`).

Include the following at the same level as the `properties` keyword to ensure proper validation:

```json
"additionalProperties": false
```

# Data Contract Object

The data contract object consists of the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/schema/dataContract/dataContractMeta.json)):

| Property | Type | Required | Description |
| - | - | - | - |
| protocolVersion | integer | Yes | The platform protocol version ([currently `1`](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/lib/version/protocolVersion.js#L2)) |
| $schema | string | Yes  | A valid URL (default: https://schema.dash.org/dpp-0-4-0/meta/data-contract)
| $id | array of bytes| Yes | Contract ID generated from `ownerId` and entropy ([32 bytes; content media type: `application/x.dash.dpp.identifier`](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/dataContractMeta.json#L346-L352)) |
| ownerId | array of bytes | Yes | [Identity](identity.md) that registered the data contract defining the document ([32 bytes; content media type: `application/x.dash.dpp.identifier`](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/dataContractMeta.json#L357-L363) |
| documents | object | Yes | Document definitions (see [Documents](#data-contract-documents) for details) |
| $defs | object | No | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with <= 100 valid properties) |

## Data Contract Schema

Details regarding the data contract object may be found in the [js-dpp data contract meta schema](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/schema/dataContract/dataContractMeta.json). A truncated version is shown below for reference:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
  "type": "object",
  "$defs": {
    // Truncated ...
  },
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "$schema": {
      "type": "string",
      "const": "https://schema.dash.org/dpp-0-4-0/meta/data-contract"
    },
    "$id":{
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "ownerId":{
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "documents": {
      "type": "object",
      "propertyNames": {
        "pattern": "^[a-zA-Z][a-zA-Z0-9-_]{1,62}[a-zA-Z0-9]$"
      },
      // Truncated ...
      "minProperties": 1,
      "maxProperties": 100
    },
    "$defs": {
      "$ref": "#/$defs/documentProperties"
    }
  },
  "required": [
    "protocolVersion",
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
  "id": "AoDzJxWSb1gUi2dSmvFeUFpSsjZQRJaqCpn7vCLkwwJj",
  "ownerId": "7NUbPf231ixt1kVBQsBvSMMBxd7AgPad8KtdtfFGhXDP",
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
  }
}
```

## Data Contract id

The data contract `$id` is a hash of the `ownerId` and entropy as shown [here](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/lib/dataContract/generateDataContractId.js).

```javascript
// From the JavaScript reference implementation (js-dpp)
// generateDataContractId.js
function generateDataContractId(ownerId, entropy) {
  return hash(
    Buffer.concat([
      ownerId,
      entropy,
    ]),
  );
}
```

## Data Contract Documents

The `documents` object defines each type of document required by the data contract. At a minimum, a document must consist of 1 or more properties. Documents may also define [indices](#document-indices) and a list of [required properties](#required-properties-optional). The `additionalProperties` properties keyword must be included as described in the [constraints](#additional-properties) section.

The following example shows a minimal `documents` object defining a single document (`note`) that has one property (`message`).

```json
{
  "note": {
    "type": "object",
    "properties": {
      "message": {
        "type": "string"
      }
    },
    "additionalProperties": false
  }
}
```

### Document Properties

The `properties` object defines each field that will be used by a document. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`). Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data.

**Note:** The `object` type is required to have properties defined either directly or via the data contract's [$defs](#data-contract-definitions).  For example, the body property shown below is an object containing a single string property (objectProperty):

```javascript
const contractDocuments = {
  message: {
    "type": "object",
    properties: {
      body: {
        type: "object",
        properties: {
          objectProperty: {
            type: "string"
          },
        },
        additionalProperties: false,
      },
      header: {
        type: "string"
      }
    },
    additionalProperties: false
  }
};
```

**Note:** A full explanation of the capabilities of JSON Schema is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

#### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| - | - |
| Minimum number of properties | [1](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/dataContractMeta.json#L22) |
| Maximum number of properties | [100](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/dataContractMeta.json#L23) |
| Minimum property name length | [3](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/dataContractMeta.json#L9) |
| Maximum property name length | [64](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/dataContractMeta.json#L9) |
| Property name first/last characters | \** First: (`A-Z`, `a-z`); Last: Alphanumeric (`A-Z`, `a-z`, `0-9`)**|
| Property name characters | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hypen (`-`) <br>Underscore (`_`) |

#### Required Properties (Optional)

Each document may have some fields that are required for the document to be valid and other fields that are optional. Required fields are defined via the `required` array which consists of a list of the field names from the document that must be present. The `required` object should be excluded for documents without any required properties.

```json
"required": [
  "<field name a>",
  "<field name b>"
]
```

**Example**
The following example (excerpt from the DPNS contract's `domain` document) demonstrates a document that has 6 required fields:

```json
"required": [
  "label",
  "normalizedLabel",
  "normalizedParentDomainName",
  "preorderSalt",
  "records",
  "subdomainRules"
]
```

### Document Indices

**Note:** The `indices` object should be excluded for documents that do not require indices.

Document indices may be defined if indexing on document fields is required.

The `indices` array consists of:

 - One or more objects that each contain:
   - A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index (sort order: `asc` or `desc`)
   - An (optional) `unique` element that determines if duplicate values are allowed for the document

**Note:** When defining an index with multiple properties (i.e a compound index), the order in which the properties are listed is important. Refer to the [mongoDB documentation](https://docs.mongodb.com/manual/core/index-compound/#prefixes) for details regarding the significance of the order as it relates to querying capabilities.

```json
"indices": [
  {
    "properties": [
      { "<field name a>": "<asc"|"desc>" },
      { "<field name b>": "<asc"|"desc>" }
    ],
    "unique": true|false
  },
  {
    "properties": [
      { "<field name c>": "<asc"|"desc>" },
    ],
  }
]
```

#### Index Constraints

**Note:** For performance and security reasons, indices have the following constraints. These constraints are subject to change over time.

| Description | Value |
| - | - |
| Maximum number of indices | [10](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/schema/dataContract/dataContractMeta.json#L400) |
| Maximum number of unique indices | [3](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/lib/errors/consensus/basic/dataContract/UniqueIndicesLimitReachedError.js#L22) |
| Maximum number of properties in a single index | [10](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/schema/dataContract/dataContractMeta.json#L390) |
| Maximum length of indexed string property | [1024](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/lib/dataContract/validation/validateDataContractFactory.js#L23) |

**Example**
The following example (excerpt from the DPNS contract's `preorder` document) creates an index on `saltedDomainHash` that also enforces uniqueness across all documents of that type:

```json
"indices": [
  {
    "properties": [
      {
        "saltedDomainHash": "asc"
      }
    ],
    "unique": true
  }
]
```

### Full Document Syntax

This example syntax shows the structure of a documents object that defines two documents, an index, and a required field.

```json
{
  "<document name a>": {
    "type": "object",
    "properties": {
      "<field name b>": {
        "type": "<field data type>"
      },
      "<field name c>": {
        "type": "<field data type>"
      },
    },
    "indices": [
      {
        "properties": [
          {
            "<field name c>": "<asc|desc>"
          }
        ],
        "unique": true|false
      },
    ],
    "required": [
      "<field name c>"
    ]
    "additionalProperties": false
  },
  "<document name x>": {
    "type": "object",
    "properties": {
      "<property name y>": {
        "type": "<property data type>"
      },
      "<property name z>": {
        "type": "<property data type>"
      },
    },
    "additionalProperties": false
  },    
}
```

### Document Schema

Full document schema details may be found in this section of the [js-dpp data contract meta schema](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/schema/dataContract/dataContractMeta.json#L360-L415).

## Data Contract Definitions

The optional `$defs` object enables definition of aspects of a schema that are used in multiple places. This is done using the JSON Schema support for [reuse](https://json-schema.org/understanding-json-schema/structuring.html#defs). Items defined in `$defs` may then be referenced when defining `documents` through use of the `$ref` keyword.

**Note:** Properties defined in the `$defs` object must meet the same criteria as those defined in the `documents` object (e.g. the `additionalProperties` properties keyword must be included as described in the [constraints](#additional-properties) section).

**Note:** Data contracts can only use the `$ref` keyword to reference their own `$defs`. Referencing external definitions is not supported by the platform protocol.

**Example**
The following example shows a definition for a `message` object consisting of two properties:

```json
{
  // Preceding content truncated ...
  "$defs": {
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

# Data Contract Creation

Data contracts are created on the platform by submitting the [data contract object](#data-contract-object) in a data contract create state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version ([currently `1`](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/lib/version/protocolVersion.js#L2)) |
| type | integer | State transition type (`0` for data contract) |
| dataContract | [data contract object](#data-contract-object) | Object containing the data contract details
| entropy | array of bytes | Entropy used to generate the data contract ID. Generated as [shown here](state-transition.md#entropy-generation). (32 bytes) |
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | array of bytes | Signature of state transition data (65 bytes) |

Each data contract state transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/platform/blob/v0.22-dev/packages/js-dpp/schema/dataContract/stateTransition/dataContractCreate.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "type": {
      "type": "integer",
      "const": 0
    },
    "dataContract": {
      "type": "object"
    },
    "entropy": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32
    },
    "signaturePublicKeyId": {
      "type": "integer",
      "minimum": 0
    },
    "signature": {
      "type": "array",
      "byteArray": true,
      "minItems": 65,
      "maxItems": 65
    }
  },
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "dataContract",
    "entropy",
    "signaturePublicKeyId",
    "signature"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion": 1,
  "type": 0,
  "signature": "IG2Tr16rS2+FNoiH71eAva94H5BLV5QNl7Fg25s8ZzWvPlR4wihupdqYupvzTXGiAqPqSK3KQE1EouATMhgHPDc=",
  "signaturePublicKeyId": 0,
  "dataContract": {
    "protocolVersion": 0,
    "$id": "AoDzJxWSb1gUi2dSmvFeUFpSsjZQRJaqCpn7vCLkwwJj",
    "$schema": "https://schema.dash.org/dpp-0-4-0/meta/data-contract",
    "ownerId": "7NUbPf231ixt1kVBQsBvSMMBxd7AgPad8KtdtfFGhXDP",
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
  "entropy": "ahw7IvTAYkZcPaGcvh6BCVYP9rh/KyBkoeCGk28yoAw="
}
```

## Data Contract State Transition Signing

Data contract state transitions must be signed by a private key associated with the contract owner's identity.

The process to sign a data contract state transition consists of the following steps:

1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the `ownerId`
3. Set the state transition `signature` to the value of the signature created in the previous step
4. Set the state transition`signaturePublicKeyId` to the [public key `id`](identity.md#public-key-id) corresponding to the key used to sign

# Data Contract Validation

The platform protocol performs several forms of validation related to data contracts: model validation, structure validation, and data validation.

 - Model validation - ensures object models are correct
 - State transition structure validation - only checks the content of the state transition
 - State transition data validation - takes the overall platform state into consideration

**Example:** A data contract state transition for an existing application could pass structure validation; however, it would fail data validation if it used an application identity that has already created a data contract.

## Data Contract Model

The data contract model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/test/integration/dataContract/validation/validateDataContractFactory.spec.js). The test output below (split into 3 sections for readability) shows the necessary criteria:

```text
validateDataContractFactory
  ✔ should return invalid result with circular $ref pointer
  ✔ should return invalid result if indexed property missing maxLength constraint
  ✔ should return invalid result if indexed property have to big maxLength
  ✔ should return valid result if Data Contract is valid
  protocolVersion
    ✔ should be present
    ✔ should be an integer
    ✔ should be valid
  $schema
    ✔ should be present
    ✔ should be a string
    ✔ should be a particular url
  ownerId
    ✔ should be present
    ✔ should be a byte array
    ✔ should be no less than 32 bytes
    ✔ should be no longer than 32 bytes
  $id
    ✔ should be present
    ✔ should be a byte array
    ✔ should be no less than 32 bytes
    ✔ should be no longer than 32 bytes
  $defs
    ✔ may not be present
    ✔ should be an object
    ✔ should not be empty
    ✔ should have no non-alphanumeric properties
    ✔ should have no more than 100 properties
    ✔ should have valid property names
    ✔ should return an invalid result if a property has invalid format
```

### Document Validation

```text
  documents
    ✔ should be present
    ✔ should be an object
    ✔ should not be empty
    ✔ should have valid property names (document types)
    ✔ should return an invalid result if a property (document type) has invalid format
    ✔ should have no more than 100 properties
    Document schema
      ✔ should not be empty
      ✔ should have type "object"
      ✔ should have "properties"
      ✔ should have nested "properties"
      ✔ should have valid property names
      ✔ should have valid nested property names
      ✔ should return an invalid result if a property has invalid format
      ✔ should return an invalid result if a nested property has invalid format
      ✔ should have "additionalProperties" defined
      ✔ should have "additionalProperties" defined to false
      ✔ should have nested "additionalProperties" defined
      ✔ should return invalid result if there are additional properties
      ✔ should have no more than 100 properties
      ✔ should have defined items for arrays
      ✔ should have sub schema in items for arrays
      ✔ should have items if prefixItems is used for arrays
      ✔ should not have items disabled if prefixItems is used for arrays
      ✔ should return invalid result if "default" keyword is used
      ✔ should return invalid result if remote `$ref` is used
      ✔ should not have `propertyNames`
      ✔ should have `maxItems` if `uniqueItems` is used
      ✔ should have `maxItems` no bigger than 100000 if `uniqueItems` is used
      ✔ should return invalid result if document JSON Schema is not valid
      ✔ should have `maxLength` if `pattern` is used
      ✔ should have `maxLength` no bigger than 50000 if `pattern` is used
      ✔ should have `maxLength` if `format` is used
      ✔ should have `maxLength` no bigger than 50000 if `format` is used
      ✔ should not have incompatible patterns
      byteArray
        ✔ should be a boolean
        ✔ should equal to true
        ✔ should be used with type `array`
        ✔ should not be used with `items`
      contentMediaType
        application/x.dash.dpp.identifier
          ✔ should be used with byte array only
          ✔ should be used with byte array not shorter than 32 bytes
          ✔ should be used with byte array not longer than 32 bytes
```

### Index Validation

```text
  indices
    ✔ should be an array
    ✔ should have at least one item
    ✔ should return invalid result if there are duplicated indices
    index
      ✔ should be an object
      ✔ should have properties definition
      ✔ should have "unique" flag to be of a boolean type
      ✔ should have no more than 10 indices
      ✔ should have no more than 3 unique indices
      ✔ should return invalid result if index is prebuilt
      ✔ should return invalid result if indices has undefined property
      ✔ should return invalid result if index property is object
      ✔ should return invalid result if index property is array of objects
      ✔ should return invalid result if index property is an array of different types
      ✔ should return invalid result if index property contained prefixItems array of arrays
      ✔ should return invalid result if index property contained prefixItems array of objects
      ✔ should return invalid result if index property is array of arrays
      ✔ should return invalid result if index property is array with different item definitions
      ✔ should return invalid result if unique compound index contains both required and optional properties
      properties definition
        ✔ should be an array
        ✔ should have at least one property defined
        ✔ should have no more than 10 property $defs
        property definition
          ✔ should be an object
          ✔ should have at least one property
          ✔ should have no more than one property
          ✔ should have property values only "asc" or "desc"
```

### Dependency Validation

```text
  dependentSchemas
    ✔ should be an object
  dependentRequired
    ✔ should be an object
    ✔ should have an array value
    ✔ should have an array of strings
    ✔ should have an array of unique strings
```

## State Transition Structure

Structure validation verifies that the content of state transition fields complies with the requirements for the field. The data contract `contractId` and `signature` fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/test/integration/dataContract/stateTransition/DataContractCreateTransition/validation/basic/validateDataContractCreateTransitionBasicFactory.spec.js). The test output below shows the necessary criteria:

```text
validateDataContractCreateTransitionBasicFactory
  ✔ should return valid result
  protocolVersion
    ✔ should be present
    ✔ should be an integer
    ✔ should be valid
  type
    ✔ should be present
    ✔ should be equal to 0
  dataContract
    ✔ should be present
    ✔ should be valid
    ✔ should return invalid result on invalid Data Contract id
  entropy
    ✔ should be present
    ✔ should be a byte array
    ✔ should be no less than 32 bytes
    ✔ should be no longer than 32 bytes
  signature
    ✔ should be present
    ✔ should be a byte array
    ✔ should be not less than 65 bytes
    ✔ should be not longer than 65 bytes
  signaturePublicKeyId
    ✔ should be an integer
    ✔ should not be < 0
```

- See the [state transition document](state-transition.md) for signature validation details.

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/test/unit/dataContract/stateTransition/DataContractCreateTransition/validation/state/validateDataContractCreateTransitionStateFactory.spec.js). The test output below shows the necessary criteria:

```text
validateDataContractCreateTransitionDataFactory
  ✓ should return invalid result if Data Contract with specified contractId is already exist
```

## Contract Depth

Verifies that the data contract's JSON-Schema depth is not greater than the maximum ([500](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/lib/errors/consensus/basic/dataContract/DataContractMaxDepthExceedError.js#L9)) (see [js-dpp](https://github.com/dashevo/platform/blob/v0.21.5/packages/js-dpp/test/unit/dataContract/validation/validateDataContractMaxDepthFactory.spec.js)). The test output below shows the necessary criteria:

```text
validateDataContractMaxDepthFactory
  ✔ should throw error if depth > MAX_DEPTH
  ✔ should return valid result if depth = MAX_DEPTH
  ✔ should throw error if contract contains array with depth > MAX_DEPTH
  ✔ should return error if refParser throws an error
```

**Note:** Additional validation rules will be added in future versions.
