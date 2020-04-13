# Document Overview

The `documents` object defines each type of document required by the data contract. At a minimum, a document must consist of 1 or more properties. Documents may also define [indices](#document-indices) and a list of [required properties](#required-properties-optional).

The following example shows a minimal `documents` object defining a single document (`note`) that has one property (`message`).

```json
{
  "note": {
    "properties": {
      "message": {
        "type": "string"
      }
    },
    "additionalProperties": false
  }
}
```

## Document Properties

The `properties` object defines each field that will be used by a document. Each field consists of an object that, at a minimum, must define its data `type` (`string`, `number`, `integer`, `boolean`, `array`, `object`). Fields may also apply a variety of optional JSON Schema constraints related to the format, range, length, etc. of the data.

**Note:** A full explanation of the capabilities of JSON Schema is beyond the scope of this document. For more information regarding its data types and the constraints that can be applied, please refer to the [JSON Schema reference](https://json-schema.org/understanding-json-schema/reference/index.html) documentation.

### Property Constraints

There are a variety of constraints currently defined for performance and security reasons.

| Description | Value |
| - | - |
| Minimum number of properties | 1 |
| Maximum number of properties | 100 |
| Minimum property name length | 1 |
| Maximum property name length | 63 |
| Property name first/last characters | ** Alphanumeric only (`A-Z`, `a-z`, `0-9`)**|
| Property name characters | Alphanumeric (`A-Z`, `a-z`, `0-9`)<br>Hypen (`-`) <br>Underscore (`_`) |

### Required Properties (Optional)

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
  "nameHash",
  "label",
  "normalizedLabel",
  "normalizedParentDomainName",
  "preorderSalt",
  "records"
]
```

## Document Indices

**Note:** The `indices` object should be excluded for documents that do not require indices.

Document indices may be defined if indexing on document fields is required.

The `indices` array consists of:
 - One or more objects that each contain:
  - A `properties` array composed of a `<field name: sort order>` object for each document field that is part of the index (sort order: `asc` or `desc`)
  - An (optional) `unique` element that determines if duplicate values are allowed for the document

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

### Index Constraints

**Note:** For performance and security reasons, Evonet places the following constraints on indices. These constraints are subject to change over time.

| Description | Value |
| - | - |
| Maximum number of indices | 10 |
| Maximum number of unique indices | 3 |
| Maximum number of properties in a single index | 10 |

**Example**
The following example (excerpt from the DPNS contract's `preorder` document) creates an index on `saltedDomainHash` that also enforces uniqueness across all documents of that type:

```json
"indices": [
  {
    "properties": [
      { "saltedDomainHash": "asc" }
    ],
    "unique": true
  }
]
```

## Full Document Syntax
This example syntax shows the structure of a documents object that defines two documents, an index, and a required field.

```json
{
  "<document name a>": {
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

## Document Schema

Full document schema details may be found in this section of the [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/meta/data-contract.json#L314-L451).

# Additional Properties

Although JSON Schema allows additional, undefined properties [by default](https://json-schema.org/understanding-json-schema/reference/object.html?#properties), they are not allowed in Dash Platform data contracts. Data contract validation will fail if they are not explicitly forbidden using the `additionalProperties` keyword anywhere `properties` are defined.

Include the following at the same level as the `properties` keyword to ensure proper validation:
```json
"additionalProperties": false
```

# Document Submission

Documents are sent to the platform by submitting the them in a documents state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`2` for documents) |
| actions | array of integers | [Action](#document-actions) the platform should take for the associated document in the `documents` array |
| documents | array of [document objects](#document-object) | [Document(s)](#document-object) |
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | string | Signature of state transition data |

Each document state transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/documents.json) (in addition to the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/stateTransition/base.json) that is required for all state transitions):

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

**Example State Transition**

```json
{
  "protocolVersion": 0,
  "type": 2,
  "actions": [
    1
  ],
  "documents": [
    {
      "$type": "note",
      "$contractId": "EzLBmQdQXYMaoeXWNaegK18iaaCDShitN3s14US3DunM",
      "$userId": "At44pvrZXLwjbJp415E2kjav49goGosRF3SB1WW1QJoG",
      "$entropy": "ydQUKu7QxqPxt4tytY7dtKM7uKPGzWG9Az",
      "$rev": 1,
      "message": "Tutorial Test @ Thu, 26 Mar 2020 20:19:49 GMT"
    }
  ],
  "signaturePublicKeyId": 1,
  "signature": "IFue3isoXSuYd0Ky8LvYjOMExwq69XaXPvi+IE+YT0sSD6N22P75xWZNFqO8RkZRqtmO7+EwyMX7NVETcD2HTmw=",  
}
```

## State Transition Action

| Action | Name | Description |
| :-: | - | - |
| 1 | Create | Create a new document with the provided data |
| 2 | Replace | Replace an existing document with the provided data |
| 3 | `RESERVED` | Unused action |
| 4 | Delete | Delete the referenced document |

**Note:** In the current implementation, actions start at `1`. In future releases, indexing will change to begin at `0` instead of `1`.

## State Transition Document Object

The `document` objects in the state transition's `documents` array consist of the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/document/RawDocumentInterface.js)):

| Property | Type | Required | Description |
| - | - | - | - |
| $type | string | Yes  | Document type defined in the referenced contract |
| $contractId | string (base58) | Yes | [Identity](identity.md) that registered the data contract defining the document (42-44 characters) |
| $userId | string (base58) | Yes | [Identity](identity.md) of the user submitting the document (42-44 characters) |
| $entropy | string | Yes | Randomness to ensure document uniqueness (34 characters)|
| $rev | integer | No | Document revision (=>1) |

Each document object must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/base/document.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "$id": "https://schema.dash.org/dpp-0-4-0/base/document",
  "type": "object",
  "properties": {
    "$type": {
      "type": "string"
    },
    "$rev": {
      "type": "number",
      "multipleOf": 1.0,
      "minimum": 1
    },
    "$contractId": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "$userId": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "$entropy": {
      "type": "string",
      "minLength": 34,
      "maxLength": 34
    }
  },
  "required": [
    "$type",
    "$rev",
    "$contractId",
    "$userId",
    "$entropy"
  ],
  "additionalProperties": false
}
```

**Example Document Object**

```json
{
  "$type": "note",
  "$contractId": "EzLBmQdQXYMaoeXWNaegK18iaaCDShitN3s14US3DunM",
  "$userId": "At44pvrZXLwjbJp415E2kjav49goGosRF3SB1WW1QJoG",
  "$entropy": "ydQUKu7QxqPxt4tytY7dtKM7uKPGzWG9Az",
  "$rev": 1,
  "message": "Tutorial Test @ Thu, 26 Mar 2020 20:19:49 GMT"
}
```

# Document Validation

The platform protocol performs several forms of validation related to documents: model validation, structure validation, and data validation.
 - Model validation - ensures object models are correct
 - State transition structure validation - only checks the content of the state transition
 - State transition data validation - takes the overall platform state into consideration

**Example:** A document state transition for an existing document could pass structure validation; however, it would fail data validation since the document already exists.

## Document Model

The public key model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/integration/document/validateDocumentFactory.spec.js). The test output below shows the necessary criteria:

```
validateDocumentFactory
  ✓ should validate against base Document schema if `action` option is DELETE
  ✓ should throw validation error if additional fields are defined and `action` option is DELETE
  ✓ should return invalid result if a document contractId is not equal to Data Contract ID
  Base schema
    $type
      ✓ should be present
      ✓ should be defined in Data Contract
      ✓ should throw an error if getDocumentSchemaRef throws error
    $rev
      ✓ should be present
      ✓ should be a number
      ✓ should be an integer
      ✓ should be greater or equal to one
    $contractId
      ✓ should be present
      ✓ should be a string
      ✓ should be no less than 42 chars
      ✓ should be no longer than 44 chars
      ✓ should be base58 encoded
    $userId
      ✓ should be present
      ✓ should be a string
      ✓ should be no less than 42 chars
      ✓ should be no longer than 44 chars
      ✓ should be base58 encoded
    $entropy
      ✓ should be present
      ✓ should be a string
      ✓ should be no less than 34 chars
      ✓ should be no longer than 34 chars
      ✓ should be valid entropy
```

## State Transition Structure

State transition structure validation verifies that the content of state transition fields complies with the requirements for the fields. The state transition `actions` and `documents` fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/unit/document/stateTransition/structure/validateDocumentsSTStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateDocumentsSTStructureFactory
  ✓ should return invalid result if userId is not valid
  ✓ should return invalid result if actions and documents count are not equal
  ✓ should return invalid result if there are documents with different $contractId
  ✓ should return invalid result if Documents are invalid
  ✓ should return invalid result if Documents are invalid
  ✓ should return invalid result if there are duplicate Documents with the same ID
  ✓ should return invalid result if there are duplicate unique index values
  ✓ should return invalid result if there are documents with different User IDs
  ✓ should return invalid result with invalid signature
```

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/unit/document/stateTransition/data/validateDocumentsSTDataFactory.spec.js). The test output below shows the necessary criteria:

```
validateDocumentsSTDataFactory
  ✓ should return invalid result if Data Contract is not present
  ✓ should return invalid result if Document with action "create" is already present
  ✓ should return invalid result if Document with action "update" is not present
  ✓ should return invalid result if Document with action "delete" is not present
  ✓ should return invalid result if Document with action "update" has wrong revision
  ✓ should return invalid result if Document with action "delete" has wrong revision
  ✓ should throw an error if Document has invalid action
  ✓ should return invalid result if there are duplicate documents according to unique indices
  ✓ should return invalid result if data triggers execution failed

```
