# Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts: [documents](#section-documents) and [definitions](#section-definitions). All data contracts must define one or more documents, whereas definitions are optional and may not be used for simple contracts.

# General Constraints

**Note:** There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/master/schema/meta/data-contract.json)).

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
| Maximum size of serialized data contract | 15 KB (https://github.com/dashevo/js-dpp/pull/117) |
| Maximum size of CBOR-encoded data | [16 KB](https://github.com/dashevo/js-dpp/blob/v0.11.0-dev.3/lib/util/serializer.js#L5) (https://github.com/dashevo/js-dpp/pull/114) |

# Documents
The `documents` object defines each type of document required by the data contract. At a minimum, a document must consist of 1 or more properties. Documents may also define [indices](#section-document-indices) and a list of [required properties](#section-required-properties).

The following example shows a minimal `documents` object defining a single document (`note`) that has one property (`message`).

```json
{
  "note": {
    "properties": {
      "message": {
        "type": "string"
      }
    },
    "additionalProperties": "false"
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

# Definitions
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





# Raw Document Interface

Defined in [https://github.com/dashevo/js-dpp/blob/master/lib/document/RawDocumentInterface.js](https://github.com/dashevo/js-dpp/blob/master/lib/document/RawDocumentInterface.js)

| Property | Type | Description |
| - | - | - |
| $type | string | Type of document |
| $contractId | string | Identity that registered the data contract defining the document |
| $userId | string | Identity submitting the document |
| $entropy | string | Randomness to ensure document uniqueness |
| $rev | integer | Document revision |
