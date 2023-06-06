# Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts: [documents](#data-contract-documents) and [definitions](#data-contract-definitions). All data contracts must define one or more documents, whereas definitions are optional and may not be used for simple contracts.

## General Constraints

There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [rs-dpp data contract meta schema](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json)).

### Keyword

**Note:** The `$ref` keyword has been [disabled](https://github.com/dashevo/platform/pull/300) since Platform v0.22.

| Keyword | Constraint |
| - | - |
| `default` | Restricted - cannot be used (defined in DPP logic) |
| `propertyNames` | Restricted - cannot be used (defined in DPP logic) |
| `uniqueItems: true` | `maxItems` must be defined (maximum: 100000) |
| `pattern: <something>` | `maxLength` must be defined (maximum: 50000) |
| `format: <something>` | `maxLength` must be defined (maximum: 50000) |
| `$ref: <something>` | **Temporarily disabled**<br>`$ref` can only reference `$defs` - <br> remote references not supported |
| `if`, `then`, `else`, `allOf`, `anyOf`, `oneOf`, `not` | Disabled for data contracts |
| `dependencies` | Not supported. Use `dependentRequired` and `dependentSchema` instead |
| `additionalItems` | Not supported. Use `items: false` and `prefixItems` instead |
| `patternProperties` | Restricted - cannot be used for data contracts |
| `pattern` | Accept only [RE2](https://github.com/google/re2/wiki/Syntax) compatible regular expressions (defined in DPP logic) |

### Data Size

**Note:** These constraints are defined in the Dash Platform Protocol logic (not in JSON Schema).

All serialized data (including state transitions) is limited to a maximum size of [16 KB](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/util/serializer.rs#L8).

### Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined (including within document properties of type `object`).

Include the following at the same level as the `properties` keyword to ensure proper validation:

```json
"additionalProperties": false
```

# Data Contract Object

The data contract object consists of the following fields as defined in the JavaScript reference client ([rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json)):

| Property | Type | Required | Description |
| - | - | - | - |
| protocolVersion | integer | Yes | The platform protocol version ([currently `1`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/version/mod.rs#L9)) |
| $schema | string | Yes  | A valid URL (default: https://schema.dash.org/dpp-0-4-0/meta/data-contract)
| $id | array of bytes| Yes | Contract ID generated from `ownerId` and entropy ([32 bytes; content media type: `application/x.dash.dpp.identifier`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L378-L384)) |
| version | integer | Yes | The data contract version |
| ownerId | array of bytes | Yes | [Identity](identity.md) that registered the data contract defining the document ([32 bytes; content media type: `application/x.dash.dpp.identifier`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L389-L395) |
| documents | object | Yes | Document definitions (see [Documents](#data-contract-documents) for details) |
| $defs | object | No | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with <= 100 valid properties) |

## Data Contract Schema

Details regarding the data contract object may be found in the [rs-dpp data contract meta schema](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json). A truncated version is shown below for reference:

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
      "minimum": 0,
      "$comment": "Maximum is the latest protocol version"
    },
    "$schema": {
      "type": "string",
      "const": "https://schema.dash.org/dpp-0-4-0/meta/data-contract"
    },
    "$id": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "version": {
      "type": "integer",
      "minimum": 1
    },
    "ownerId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "documents": {
      "type": "object",
      "propertyNames": {
        "pattern": "^[a-zA-Z0-9-_]{1,64}$"
      },
      "additionalProperties": {
        "type": "object",
        "allOf": [
          {
            "properties": {
              "indices": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 32
                    },
                    "properties": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "propertyNames": {
                          "maxLength": 256
                        },
                        "additionalProperties": {
                          "type": "string",
                          "enum": [
                            "asc"
                          ]
                        },
                        "minProperties": 1,
                        "maxProperties": 1
                      },
                      "minItems": 1,
                      "maxItems": 10
                    },
                    "unique": {
                      "type": "boolean"
                    }
                  },
                  "required": [
                    "properties",
                    "name"
                  ],
                  "additionalProperties": false
                },
                "minItems": 1,
                "maxItems": 10
              },
              "type": {
                "const": "object"
              },
              "signatureSecurityLevelRequirement": {
                "type": "integer",
                "enum": [
                  0,
                  1,
                  2,
                  3
                ],
                "description": "Public key security level. 0 - Master, 1 - Critical, 2 - High, 3 - Medium. If none specified, High level is used"
              }
            }
          },
          {
            "$ref": "#/$defs/documentSchema"
          }
        ],
        "unevaluatedProperties": false
      },
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
    "version",
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

The data contract `$id` is a hash of the `ownerId` and entropy as shown [here](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/generate_data_contract.rs).

```rust
// From the Rust reference implementation (rs-dpp)
// generate_data_contract.rs
/// Generate data contract id based on owner id and entropy
pub fn generate_data_contract_id(owner_id: impl AsRef<[u8]>, entropy: impl AsRef<[u8]>) -> Vec<u8> {
    let mut b: Vec<u8> = vec![];
    let _ = b.write(owner_id.as_ref());
    let _ = b.write(entropy.as_ref());
    hash(b)
}
```

## Data Contract version

The data contract `version` is an integer representing the current version of the contract. This
property must be incremented if the contract is updated.

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
| Minimum number of properties | [1](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L22) |
| Maximum number of properties | [100](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L23) |
| Minimum property name length | [1](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L20) (Note: minimum length was 3 prior to v0.23) |
| Maximum property name length | [64](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L20) |
| Property name characters | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hyphen (`-`) <br>Underscore (`_`) |

Prior to Dash Platform v0.23 there were stricter limitations on minimum property name length and the characters that could be used in property names.

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

Document indices may be defined if indexing on document fields is required.

**Note:** Dash Platform v0.23 only allows [ascending default ordering](https://github.com/dashpay/platform/pull/435) for indices.

The `indices` array consists of:

 - One or more objects that each contain:
   - A unique `name` for the index
   - A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index (sort order: `asc` only for Dash Platform v0.23)
   - An (optional) `unique` element that determines if duplicate values are allowed for the document type

**Note:**

 - The `indices` object should be excluded for documents that do not require indices.
 - When defining an index with multiple properties (i.e a compound index), the order in which the properties are listed is important. Refer to the [mongoDB documentation](https://docs.mongodb.com/manual/core/index-compound/#prefixes) for details regarding the significance of the order as it relates to querying capabilities. Dash uses [GroveDB](https://github.com/dashevo/grovedb) which works similarly but does requiring listing _all_ the index's fields in query order by statements.

```json
"indices": [
  {
    "name": "Index1",
    "properties": [
      { "<field name a>": "asc" },
      { "<field name b>": "asc" }
    ],
    "unique": true|false
  },
  {
    "name": "Index2",
    "properties": [
      { "<field name c>": "asc" },
    ],
  }
]
```

#### Index Constraints

For performance and security reasons, indices have the following constraints. These constraints are subject to change over time.

| Description | Value |
| - | - |
| Minimum/maximum length of index `name` | [1](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L413) / [32](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L414) |
| Maximum number of indices | [10](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L446) |
| Maximum number of unique indices | [3](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L40) |
| Maximum number of properties in a single index | [10](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L433) |
| Maximum length of indexed string property | [63](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L39) |
| **Note: Dash Platform v0.22+. [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225)**<br>Maximum length of indexed byte array property | [255](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L43) |
| **Note: Dash Platform v0.22+. [does not allow indices for arrays](https://github.com/dashpay/platform/pull/225)**<br>Maximum number of indexed array items | [1024](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/data_contract/validation/data_contract_validator.rs#L44) |
| Usage of `$id` in an index [disallowed](https://github.com/dashpay/platform/pull/178) | N/A |

**Example**
The following example (excerpt from the DPNS contract's `preorder` document) creates an index named `saltedHash` on the `saltedDomainHash` property that also enforces uniqueness across all documents of that type:

```json
"indices": [
  {
    "name": "saltedHash",
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
        "name": "<index name>",
        "properties": [
          {
            "<field name c>": "asc"
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

Full document schema details may be found in this section of the [rs-dpp data contract meta schema](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/dataContractMeta.json#L368-L471).

## Data Contract Definitions

> ❗️ Definitions are currently unavailable

The optional `$defs` object enables definition of aspects of a schema that are used in multiple places. This is done using the JSON Schema support for [reuse](https://json-schema.org/understanding-json-schema/structuring.html#defs). Items defined in `$defs` may then be referenced when defining `documents` through use of the `$ref` keyword.

**Note:**

 - Properties defined in the `$defs` object must meet the same criteria as those defined in the `documents` object (e.g. the `additionalProperties` properties keyword must be included as described in the [constraints](#additional-properties) section).
 - Data contracts can only use the `$ref` keyword to reference their own `$defs`. Referencing external definitions is not supported by the platform protocol.

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

# Data Contract State Transition Details

There are two data contract-related state transitions: [data contract create](#data-contract-creation) and [data contract update](#data-contract-update). Details are provided in this section.

## Data Contract Creation

Data contracts are created on the platform by submitting the [data contract object](#data-contract-object) in a data contract create state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version ([currently `1`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/version/mod.rs#L9)) |
| type | integer | State transition type (`0` for data contract create) |
| dataContract | [data contract object](#data-contract-object) | Object containing the data contract details
| entropy | array of bytes | Entropy used to generate the data contract ID. Generated as [shown here](state-transition.md#entropy-generation). (32 bytes) |
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | array of bytes | Signature of state transition data (65 or 96 bytes) |

Each data contract state transition must comply with this JSON-Schema definition established in [rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/stateTransition/dataContractCreate.json):

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
      "maxItems": 96
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
  "protocolVersion":1,
  "type":0,
  "signature":"IFmEb/OwyYG0yn33U4/kieH4JL63Ft25GAun+XqWOalkbDrpL9z+OH+Sb03xsyMNzoILC2T1Q8yV1q7kCmr0HuQ=",
  "signaturePublicKeyId":0,
  "dataContract":{
    "protocolVersion":1,
    "$id":"44dvUnSdVtvPPeVy6mS4vRzJ4zfABCt33VvqTWMM8VG6",
    "$schema":"https://schema.dash.org/dpp-0-4-0/meta/data-contract",
    "version":1,
    "ownerId":"6YfP6tT9AK8HPVXMK7CQrhpc8VMg7frjEnXinSPvUmZC",
    "documents":{
      "note":{
        "type":"object",
        "properties":{
          "message":{
            "type":"string"
          }
        },
        "additionalProperties":false
      }
    }
  },
  "entropy":"J2Sl/Ka9T1paYUv6f2ec5MzaaACs9lcUvOskBU0SMlo="
}
```

## Data Contract Update

Existing data contracts can be updated in certain backwards-compatible ways. The following aspects
of a data contract can be updated:

 - Adding a new document
 - Adding a new optional property to an existing document
 - Adding non-unique indices for properties added in the update

Data contracts are updated on the platform by submitting the modified [data contract
object](#data-contract-object) in a data contract update state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version ([currently `1`](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/version/mod.rs#L9)) |
| type | integer | State transition type (`4` for data contract update) |
| dataContract | [data contract object](#data-contract-object) | Object containing the updated data contract details<br>**Note:** the data contract's [`version` property](data-contract-version) must be incremented with each update
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | array of bytes | Signature of state transition data (65 or 96 bytes) |

Each data contract state transition must comply with this JSON-Schema definition established in
[rs-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/rs-dpp/src/schema/data_contract/stateTransition/dataContractUpdate.json):

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
      "const": 4
    },
    "dataContract": {
      "type": "object"
    },
    "signaturePublicKeyId": {
      "type": "integer",
      "minimum": 0
    },
    "signature": {
      "type": "array",
      "byteArray": true,
      "minItems": 65,
      "maxItems": 96
    }
  },
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "dataContract",
    "signaturePublicKeyId",
    "signature"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion":1,
  "type":4,
  "signature":"IBboAbqbGBiWzyJDyhwzs1GujR6Gb4m5Gt/QCugLV2EYcsBaQKTM/Stq7iyIm2YyqkV8VlWqOfGebW2w5Pjnfak=",
  "signaturePublicKeyId":0,
  "dataContract":{
    "protocolVersion":1,
    "$id":"44dvUnSdVtvPPeVy6mS4vRzJ4zfABCt33VvqTWMM8VG6",
    "$schema":"https://schema.dash.org/dpp-0-4-0/meta/data-contract",
    "version":2,
    "ownerId":"6YfP6tT9AK8HPVXMK7CQrhpc8VMg7frjEnXinSPvUmZC",
    "documents":{
      "note":{
        "type":"object",
        "properties":{
          "message":{
            "type":"string"
          },
          "author":{
            "type":"string"
          }
        },
        "additionalProperties":false
      }
    }
  }
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

The platform protocol performs several forms of validation related to data contracts: model validation, basic validation, and state validation.

 - Model validation - ensures object models are correct
 - State transition basic validation - only checks the content of the state transition
 - State transition state validation - takes the overall platform state into consideration

**Example:** A data contract state transition for an existing application could pass structure validation; however, it would fail data validation if it used an application identity that has already created a data contract.

## Data Contract Model

The data contract model must pass validation tests as defined in [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/integration/dataContract/validation/validateDataContractFactory.spec.js). The test output below (split into 4 sections for readability) shows the necessary criteria:

```text
validateDataContractFactory
  - should return invalid result with circular $ref pointer
  ✔ should return invalid result if indexed string property missing maxLength constraint
  ✔ should return invalid result if indexed string property have to big maxLength
  ✔ should return invalid result if indexed byte array property missing maxItems constraint
  ✔ should return invalid result if indexed byte array property have to big maxItems
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
      - should return invalid result if remote `$ref` is used
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
    ✔ should return invalid result if there are duplicated index names
    ✔ should return invalid result if there are unique indices with partially required properties
    index
      ✔ should be an object
      ✔ should have properties definition
      ✔ should have "unique" flag to be of a boolean type
      ✔ should have no more than 10 indices
      ✔ should have no more than 3 unique indices
      ✔ should return invalid result if $id is specified as an indexed property
      ✔ should return invalid result if indices has undefined property
      ✔ should return invalid result if index property is object
      ✔ should return invalid result if index property is an array
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
      property names
        ✔ should have valid property names (indices)
        ✔ should return an invalid result if a property (indices) has invalid format
  signatureSecurityLevelRequirement
    ✔ should be a number
    ✔ should be one of the available values
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

## State Transition Basic

### Data Contract Create Basic

Basic validation verifies that the content of state transition fields complies with the requirements for the field. The data contract create transition fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/integration/dataContract/stateTransition/DataContractCreateTransition/validation/basic/validateDataContractCreateTransitionBasicFactory.spec.js). The test output below shows the necessary criteria:

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
    ✔ should be not longer than 96 bytes
  signaturePublicKeyId
    ✔ should be an integer
    ✔ should not be < 0
```

- See the [state transition document](state-transition.md) for signature validation details.

### Data Contract Update Basic

Basic validation verifies that the content of state transition fields complies with the requirements for the field. The data contract update transition fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/integration/dataContract/stateTransition/DataContractUpdateTransition/validation/basic/validateDataContractUpdateTransitionBasicFactory.spec.js). The test output below shows the necessary criteria:

```text
  validateDataContractUpdateTransitionBasicFactory
    ✔ should return valid result
    ✔ should not check Data Contract on dry run
    protocolVersion
      ✔ should be present
      ✔ should be an integer
      ✔ should be valid
    type
      ✔ should be present
      ✔ should be equal to 4
    dataContract
      ✔ should be present
      ✔ should have no existing documents removed
      ✔ should allow making backward compatible changes to existing documents
      ✔ should have existing documents schema backward compatible
      ✔ should allow defining new document
      ✔ should not have root immutable properties changed
      ✔ should be valid
    signature
      ✔ should be present
      ✔ should be a byte array
      ✔ should be not less than 65 bytes
      ✔ should be not longer than 96 bytes
    signaturePublicKeyId
      ✔ should be an integer
      ✔ should not be < 0
```

- See the [state transition document](state-transition.md) for signature validation details.

### Data Contract Update Indices Basic

Basic validation also verifies that all indices comply with the requirement to remain backward
compatible. They must pass validation tests as defined in
[js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/unit/dataContract/stateTransition/DataContractUpdateTransition/validation/basic/validateIndicesAreBackwardCompatible.spec.js).
The test output below shows the necessary criteria:

```text
validateIndicesAreBackwardCompatible
  ✔ should return invalid result if some of unique indices have changed
  ✔ should return invalid result if already defined properties are changed in existing index
  ✔ should return invalid result if already indexed properties are added to existing index
  ✔ should return invalid result if one of new indices contains old properties in the wrong order
  ✔ should return invalid result if one of new indices is unique
  ✔ should return invalid result if existing property was used in a new index
  ✔ should return valid result if indices are not changed
```

## State Transition State

### Data Contract Create State

State validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/unit/dataContract/stateTransition/DataContractCreateTransition/validation/state/validateDataContractCreateTransitionStateFactory.spec.js). The test output below shows the necessary criteria:

```text
  validateDataContractCreateTransitionStateFactory
    ✔ should return invalid result if Data Contract with specified contractId is already exist
    ✔ should return valid result
    ✔ should return valid result on dry run
```

### Data Contract Update State

State validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/unit/dataContract/stateTransition/DataContractUpdateTransition/validation/state/validateDataContractUpdateTransitionStateFactory.spec.js). The test output below shows the necessary criteria:

```text
  validateDataContractUpdateTransitionStateFactory
    ✔ should return invalid result if Data Contract with specified contractId was not found
    ✔ should return invalid result if Data Contract version is not larger by 1
    ✔ should return valid result
    ✔ should return valid result on dry run
```

## Contract Depth

Verifies that the data contract's JSON-Schema depth is not greater than the maximum ([500](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/lib/errors/consensus/basic/dataContract/DataContractMaxDepthExceedError.js#L9)) (see [js-dpp](https://github.com/dashpay/platform/blob/v0.24.5/packages/js-dpp/test/unit/dataContract/validation/validateDataContractMaxDepthFactory.spec.js)). The test output below shows the necessary criteria:

```text
  validateDataContractMaxDepthFactory
    ✔ should throw error if depth > MAX_DEPTH
    ✔ should return valid result if depth = MAX_DEPTH
    ✔ should throw error if contract contains array with depth > MAX_DEPTH
    ✔ should return error if refParser throws an error
    ✔ should return valid result
```

**Note:** Additional validation rules will be added in future versions.
