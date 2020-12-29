# Document Submission

Documents are sent to the platform by submitting the them in a document batch state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`1` for document batch) |
| ownerId | array | [Identity](identity.md) submitting the document(s) (32 bytes) |
| transitions | array of transition objects | Document `create`, `replace`, or `delete` transitions (up to 10 objects) |
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | array | Signature of state transition data (65 bytes) |

**Note:** As of Dash Platform Protocol v0.13, documents from multiple data contracts can be submitted in the same document batch.

Each document batch state transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/stateTransition/documentsBatch.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 0,
      "$comment": "Maximum is the latest Documents Batch Transition protocol version"
    },
    "type": {
      "type": "integer",
      "const": 1
    },
    "ownerId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "transitions": {
      "type": "array",
      "items": {
        "type": "object"
      },
      "minItems": 1,
      "maxItems": 10
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
    "ownerId",
    "transitions",
    "signaturePublicKeyId",
    "signature"
  ]
}
```

## Document Base Transition

All document transitions in a document batch state transition are built on the base schema and include the following fields:

| Field | Type | Description|
| - | - | - |
| $id | array | The [document ID](#document-id) (32 bytes)|
| $type | string | Name of a document type found in the data contract associated with the `dataContractId` |
| $action | array of integers | [Action](#document-transition-action) the platform should take for the associated document |
| $dataContractId | array | Data contract ID [generated](data-contract.md#data-contract-id) from the data contract's `ownerId` and `entropy` (32 bytes) |

Each document transition must comply with the document transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/stateTransition/documentTransition/base.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$id": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$type": {
      "type": "string"
    },
    "$action": {
      "type": "integer",
      "enum": [0, 1, 3]
    },
    "$dataContractId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    }
  },
  "required": [
    "$id",
    "$type",
    "$action",
    "$dataContractId"
  ],
  "additionalProperties": false
}
```

### Document id

The document `$id` is created by hashing the document's `dataContractId`, `ownerId`, `type`, and `entropy` as shown [here](https://github.com/dashevo/js-dpp/blob/v0.16.0/lib/document/generateDocumentId.js).

```javascript
// From the JavaScript reference implementation (js-dpp)
// generateDocumentId.js
function generateDocumentId(contractId, ownerId, type, entropy) {
  return hash(Buffer.concat([
    contractId,
    ownerId,
    Buffer.from(type),
    entropy,
  ]));
}
```

### Document Transition Action

| Action | Name | Description |
| :-: | - | - |
| 0 | Create | Create a new document with the provided data |
| 1 | Replace | Replace an existing document with the provided data |
| 2 | `RESERVED` | Unused action |
| 3 | Delete | Delete the referenced document |

## Document Create Transition

The document create transition extends the base schema to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $entropy | array | Entropy used in creating the [document ID](#document-id). Generated as [shown here](state-transition.md#entropy-generation). (32 bytes) |
| $createdAt | integer | (Optional)  | Time (in milliseconds) the document was created |
| $updatedAt | integer | (Optional)  | Time (in milliseconds) the document was last updated |

Each document create transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/stateTransition/documentTransition/create.json) (in addition to the document transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/stateTransition/documentTransition/base.json)) that is required for all document transitions):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$entropy": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32
    },
    "$createdAt": {
      "type": "integer",
      "minimum": 0
    },
    "$updatedAt": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": [
    "$entropy"
  ],
  "additionalProperties": false
}
```

**Note:** The document create transition must also include all required properties of the document as defined in the data contract.

The following example document create transition and subsequent table demonstrate how the document transition base, document create transition, and data contract document definitions are assembled into a complete transition for inclusion in a [state transition](#document-submission):

```json
{
  "$action": 0,
  "$dataContractId": "5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8",
  "$id": "6oCKUeLVgjr7VZCyn1LdGbrepqKLmoabaff5WQqyTKYP",
  "$type": "note",
  "$entropy": "yfo6LnZfJ5koT2YUwtd8PdJa8SXzfQMVDz",
  "message": "Tutorial Test @ Mon, 27 Apr 2020 20:23:35 GMT"
}
```

| Field | Required By |
| - | - |
| $action | Document [base transition](#document-base-transition) |
| $dataContractId | Document [base transition](#document-base-transition) |
| $id | Document [base transition](#document-base-transition) |
| $type | Document [base transition](#document-base-transition) |
| $entropy | Document [create transition](#document-create-transition) |
| message | Data Contract (the `message` document defined in the referenced data contract -`5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8`) |

## Document Replace Transition

The document replace transition extends the base schema to include the following additional fields:

| Field | Type | Description|
| - | - | - |
| $revision | integer | Document revision (=> 1) |
| $updatedAt | integer | (Optional)  | Time (in milliseconds) the document was last updated |

Each document replace transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/stateTransition/documentTransition/replace.json) (in addition to the document transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/stateTransition/documentTransition/base.json)) that is required for all document transitions):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$revision": {
      "type": "integer",
      "minimum": 1
    },
    "$updatedAt": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": [
    "$revision"
  ],
  "additionalProperties": false
}
```

**Note:** The document create transition must also include all required properties of the document as defined in the data contract.

The following example document create transition and subsequent table demonstrate how the document transition base, document create transition, and data contract document definitions are assembled into a complete transition for inclusion in a [state transition](#document-submission):

```json
{
  "$action": 1,
  "$dataContractId": "5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8",
  "$id": "6oCKUeLVgjr7VZCyn1LdGbrepqKLmoabaff5WQqyTKYP",
  "$type": "note",
  "$revision": 1,
  "message": "Tutorial Test @ Mon, 27 Apr 2020 20:23:35 GMT"
}
```

| Field | Required By |
| - | - |
| $action | Document [base transition](#document-base-transition) |
| $dataContractId | Document [base transition](#document-base-transition) |
| $id | Document [base transition](#document-base-transition) |
| $type | Document [base transition](#document-base-transition) |
| $revision | Document revision |
| message | Data Contract (the `message` document defined in the referenced data contract -`5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8`) |

## Document Delete Transition

The document delete transition only requires the fields found in the [base document transition](#document-base-transition).

## Example Document Batch State Transition

```json
{
  "protocolVersion": 0,
  "type": 1,
  "signature": "ICu/H7MoqxNUzznP9P2aTVEo91VVy0T8M3QWCH/7dg2UVokG98TbD4DQB4E8SD4GzHoRrBMycJ75SbT2AaF9hFc=",
  "signaturePublicKeyId": 0,
  "ownerId": "4ZJsE1Yg8AosmC4hAeo3GJgso4N9pCoa6eCTDeXsvdhn",
  "transitions": [
    {
      "$id": "8jm8iHsYE6ENENvFVeFVFMCwfgEqo5P1iR2q4KAYgpbS",
      "$type": "note",
      "$action": 1,
      "$dataContractId": "AnmBaYH13RyiuvBkBD6qkdc36H5DKt6ToMrkqgUnnywz",
      "message": "Updated document @ Mon, 26 Oct 2020 14:58:31 GMT",
      "$revision": 2
    }
  ]
}
```

# Document Object

The document object represents the data provided by the platform in response to a query. Responses consist of an array of these objects containing the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/documentBase.json)):

| Property | Type | Required | Description |
| - | - | - | - |
| protocolVersion | integer | Yes | The platform protocol version (currently `0`) |
| $id | array | Yes | The [document ID](#document-id) (32 bytes)|
| $type | string | Yes  | Document type defined in the referenced contract |
| $revision | integer | No | Document revision (=>1) |
| $dataContractId | array | Yes | Data contract ID [generated](data-contract.md#data-contract-id) from the data contract's `ownerId` and `entropy` (32 bytes) |
| $ownerId | array | Yes | [Identity](identity.md) of the user submitting the document (32 bytes) |
| $createdAt | integer | (Optional)  | Time (in milliseconds) the document was created |
| $updatedAt | integer | (Optional)  | Time (in milliseconds) the document was last updated |

Each document object must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/document/documentBase.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$protocolVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 0,
      "$comment": "Maximum is the latest Document protocol version"
    },
    "$id": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$type": {
      "type": "string"
    },
    "$revision": {
      "type": "integer",
      "minimum": 1
    },
    "$dataContractId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$ownerId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "$createdAt": {
      "type": "integer",
      "minimum": 0
    },
    "$updatedAt": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": [
    "$protocolVersion",
    "$id",
    "$type",
    "$revision",
    "$dataContractId",
    "$ownerId"
  ],
  "additionalProperties": false
}
```

## Example Document Object

```json
{
  "$protocolVersion": 0,
  "$id": "4mWnFcDDzCpeLExJqE8v7pfN4EERC8NE2xn4hw3VKriU",
  "$type": "note",
  "$dataContractId": "63au7XVDt8aHtPrsYKoHx2bnRTSenwH62pDN1BQ5n5m9",
  "$ownerId": "7TkaE5uhG3T9AhyEkAvYCqZvRH4pyBibhjuSYPReNfME",
  "$revision": 1,
  "message": "Tutorial Test @ Mon, 26 Oct 2020 15:54:35 GMT",
  "$createdAt": 1603727675072,
  "$updatedAt": 1603727675072
}
```

# Document Validation

The platform protocol performs several forms of validation related to documents: model validation, state transition structure validation, and state transition data validation.

 - Model validation - ensures object models are correct
 - State transition structure validation - only checks the content of the state transition
 - State transition data validation - takes the overall platform state into consideration

**Example:** A document state transition for an existing document could pass structure validation; however, it would fail data validation since the document already exists.

## Document Model

The document model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/document/validateDocumentFactory.spec.js). The test output below shows the necessary criteria:

```text
validateDocumentFactory
  ✓ should return invalid result if a document contractId is not equal to Data Contract ID
  ✓ return invalid result if a byte array exceeds `maxItems`
  ✓ should return valid result is a document is valid
  Base schema
    $protocolVersion
      ✓ should be present
      ✓ should be an integer
      ✓ should not be less than 0
      ✓ should not be greater than current Document protocol version (0)
    $id
      ✓ should be present
      ✓ should be a byte array
      ✓ should be no less than 32 bytes
      ✓ should be no longer than 32 bytes
    $type
      ✓ should be present
      ✓ should be defined in Data Contract
      ✓ should throw an error if getDocumentSchemaRef throws error
    $revision
      ✓ should be present
      ✓ should be a number
      ✓ should be an integer
      ✓ should be greater or equal to one
    $dataContractId
      ✓ should be present
      ✓ should be a byte array
      ✓ should be no less than 32 bytes
      ✓ should be no longer than 32 bytes
    $ownerId
      ✓ should be present
      ✓ should be a byte array
      ✓ should be no less than 32 bytes
      ✓ should be no longer than 32 bytes
```

## State Transition Structure

State transition structure validation verifies that the content of state transition fields complies with the requirements for the fields. The state transition `actions` and `documents` fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/document/stateTransition/validation/structure/validateDocumentsBatchTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```text
validateDocumentsBatchTransitionStructureFactory
  ✓ should return valid result
  protocolVersion
    ✓ should be present
    ✓ should be an integer
    ✓ should not be less than 0
    ✓ should not be greater than current version (0)
  type
    ✓ should be present
    ✓ should be equal 1
  ownerId
    ✓ should be present
    ✓ should be a byte array
    ✓ should be no less than 32 bytes
    ✓ should be no longer than 32 bytes
    ✓ should exists
  transitions
    ✓ should be present
    ✓ should be an array
    ✓ should have at least one element
    ✓ should have no more than 10 elements
    ✓ should have objects as elements
    transaction
      ✓ should return invalid result if there are duplicate unique index values
      $id
        ✓ should be present
        ✓ should be a byte array
        ✓ should be no less than 32 bytes
        ✓ should be no longer than 32 bytes
        ✓ should no have duplicate IDs in the state transition
      $dataContractId
        ✓ should be present
        ✓ should be a byte array
        ✓ should exists in the state
      $type
        ✓ should be present
        ✓ should be defined in Data Contract
      $action
        ✓ should be present
        ✓ should be create, replace or delete
      create
        $id
          ✓ should be valid generated ID
        $entropy
          ✓ should be present
          ✓ should be a byte array
          ✓ should be no less than 32 bytes
          ✓ should be no longer than 32 bytes
      replace
        $revision
          ✓ should be present
          ✓ should be a number
          ✓ should be multiple of 1.0
          ✓ should have a minimum value of 1
  signature
    ✓ should be present
    ✓ should be a byte array
    ✓ should be not less than 65 bytes
    ✓ should be not longer than 65 bytes
    ✓ should be valid
  signaturePublicKeyId
    ✓ should be an integer
    ✓ should not be < 0
```

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/unit/document/stateTransition/data/validateDocumentsBatchTransitionDataFactory.spec.js). The test output below shows the necessary criteria:

```text
validateDocumentsBatchTransitionDataFactory
  ✓ should return invalid result if data contract was not found
  ✓ should return invalid result if document transition with action "create" is already present
  ✓ should return invalid result if document transition with action "replace" is not present
  ✓ should return invalid result if document transition with action "delete" is not present
  ✓ should return invalid result if document transition with action "replace" has wrong revision
  ✓ should return invalid result if document transition with action "replace" has mismatch of ownerId with previous revision
  ✓ should throw an error if document transition has invalid action
  ✓ should return invalid result if there are duplicate document transitions according to unique indices
  ✓ should return invalid result if data triggers execution failed
  ✓ should return valid result if document transitions are valid
  ✓ should return invalid result if document has partially set compound index data
  Timestamps
    CREATE transition
      ✓ should return invalid result if timestamps mismatch
      ✓ should return invalid result if "$createdAt" have violated time window
      ✓ should return invalid result if "$updatedAt" have violated time window
    REPLACE transition
      ✓ should return invalid result if documents with action "replace" have violated time window
```

The state transition data must also pass index validation tests as defined in [js-dpp here](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/unit/document/stateTransition/data/validateDocumentsUniquenessByIndicesFactory.spec.js) and [here](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/unit/document/stateTransition/data/validatePartialCompoundIndices.spec.js). The test output below shows the necessary criteria:

```text
validateDocumentsUniquenessByIndices
  ✓ should return valid result if Documents have no unique indices
  ✓ should return valid result if Document has unique indices and there are no duplicates
  ✓ should return invalid result if Document has unique indices and there are duplicates
  ✓ should return valid result if Document has undefined field from index
  ✓ should return valid result if Document being created and has createdAt and updatedAt indices
```

```text
validatePartialCompoundIndices
  ✓ should return invalid result if compound index contains not all fields
  ✓ should return valid result if compound index contains no fields
  ✓ should return valid result if compound index contains all fields
```
