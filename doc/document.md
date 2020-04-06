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

# Definition Overview

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

## Document Actions

| Action | Name | Description |
| :-: | - | - |
| 1 | Create | Create a new document with the provided data |
| 2 | Replace | Replace an existing document with the provided data |
| 3 | `RESERVED` | Unused action |
| 4 | Delete | Delete the referenced document |

**Note:** In the current implementation, actions start at `1`. In future releases, indexing may change to begin at `0` instead of `1`.

## Document Object

The `document` objects in the state transition's `documents` array consist of the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/document/RawDocumentInterface.js)):

| Property | Type | Required | Description |
| - | - | - | - |
| $type | string | Yes  | Document type defined in the referenced contract |
| $contractId | string (base58) | Yes | [Identity](identity.md) that registered the data contract defining the document (42-44 characters) |
| $userId | string (base58) | Yes | [Identity](identity.md) of the user submitting the document (42-44 characters) |
| $entropy | string | Yes | Randomness to ensure document uniqueness (34 characters)|
| $rev | integer | No | Document revision (=>1) |

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
