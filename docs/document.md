# Document Submission

Documents are sent to the platform by submitting the them in a document batch state transition consisting of:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`1` for document batch) |
| ownerId | string (base58) | [Identity](identity.md) submitting the document(s) |
| transitions | array of transition objects | Document `create`, `replace`, or `delete` transitions (up to 10 objects) |
| signaturePublicKeyId | number | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition |
| signature | string | Signature of state transition data |

Each document batch state transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/stateTransition/documentsBatch.json) (in addition to the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/stateTransition/stateTransitionBase.json) that is required for all state transitions):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "ownerId": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "transitions": {
      "type": "array",
      "items": {
        "type": "object"
      },
      "minItems": 1,
      "maxItems": 10
    }
  },
  "required": [
    "ownerId",
    "transitions"
  ]
}
```

## Document Base Transition

All document transitions in a document batch state transition are built on the base schema and include the following fields:

| Field | Type | Description|
| - | - | - |
| $id | string (base58) | The [document ID](#document-id) |
| type | string | Name of a document type found in the data contract associated with the `dataContractId` |
| action | array of integers | [Action](#document-transition-action) the platform should take for the associated document |
| $dataContractId | string (base58) | [Identity](identity.md) that registered the data contract defining the document (42-44 characters) |

Each document transition must comply with the document transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/stateTransition/documentTransition/base.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$id": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "$type": {
      "type": "string"
    },
    "$action": {
      "type": "integer",
      "enum": [0, 1, 3]
    },
    "$dataContractId": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
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

The document `$id` is created by base58 encoding the hash of the document's `ownerId`, `type`, `dataContractId`, and `entropy` as shown [here](https://github.com/dashevo/js-dpp/blob/v0.12.0/lib/document/generateDocumentId.js).

```javascript
// From the JavaScript reference implementation (js-dpp)
// generateDocumentId.js
function generateDocumentId(contractId, ownerId, type, entropy) {
  return bs58.encode(
    hash(Buffer.concat([
      bs58.decode(contractId),
      bs58.decode(ownerId),
      Buffer.from(type),
      bs58.decode(entropy),
    ])),
  );
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

The document create transition extends the base schema to include the following additional field:

| Field | Type | Description|
| - | - | - |
| entropy | string | Entropy used in creating the [document ID](#document-id). Generated in the same way as the [data contract's entropy](state-transition.md#entropy-generation). |

Each document create transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/stateTransition/documentTransition/create.json) (in addition to the document transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/stateTransition/documentTransition/base.json)) that is required for all document transitions):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$entropy": {
      "type": "string",
      "minLength": 26,
      "maxLength": 35
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

The document replace transition extends the base schema to include the following additional field:

| Field | Type | Description|
| - | - | - |
| $revision | integer | Document revision (=> 1) |

Each document replace transition must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/stateTransition/documentTransition/replace.json) (in addition to the document transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/stateTransition/documentTransition/base.json)) that is required for all document transitions):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$revision": {
      "type": "integer",
      "minimum": 1
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
  "signature": "HwIqrNQmfpvu7wYbpHwEOSfmXlkImt1oBQBCweUVhsWtW6cjIl3CJ/qANrU3UoJlo2jnQKITUjIbhjcaoB7iHug=",
  "signaturePublicKeyId": 0,
  "ownerId": "5Zqim5LkL76dBMqa1kE2AFRng2yqpgyVTKK6kTqWbYmu",
  "transitions": [
    {
      "$action": 0,
      "$dataContractId": "5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8",
      "$id": "6oCKUeLVgjr7VZCyn1LdGbrepqKLmoabaff5WQqyTKYP",
      "$type": "note",
      "$entropy": "yfo6LnZfJ5koT2YUwtd8PdJa8SXzfQMVDz",
      "message": "Tutorial Test @ Mon, 27 Apr 2020 20:23:35 GMT"
    },
    {
      "$action": 0,
      "$dataContractId": "5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8",
      "$id": "E8NftpxhvBmSg9wsTVDNUFXEw774Gb4ioFtT5YWuKvcn",
      "$type": "note",
      "$entropy": "yeGZVSYACVPPdNrSkwc2shKDWpHFKvmmww",
      "message": "Tutorial Test 2 @ Mon, 27 Apr 2020 20:23:35 GMT"
    }
  ]
}
```

# Document Object

The document object represents the data provided by the platform in response to a query. Responses consist of an array of these objects containing the following fields as defined in the JavaScript reference client ([js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/documentBase.json)):

| Property | Type | Required | Description |
| - | - | - | - |
| $id | string (base58) | Yes | The [document ID](#document-id) |
| $type | string | Yes  | Document type defined in the referenced contract |
| $revision | integer | No | Document revision (=>1) |
| $dataContractId | string (base58) | Yes | [Identity](identity.md) that registered the data contract defining the document (42-44 characters) |
| $ownerId | string (base58) | Yes | [Identity](identity.md) of the user submitting the document (42-44 characters) |

Each document object must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/document/documentBase.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "$id": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "$type": {
      "type": "string"
    },
    "$revision": {
      "type": "integer",
      "minimum": 1
    },
    "$dataContractId": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "$ownerId": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    }
  },
  "required": [
    "$id",
    "$type",
    "$revision",
    "$dataContractId",
    "$ownerId"
  ],
  "additionalProperties": false
}
```

### Example Document Object

```json
{
  "$id": "2oGW6opwxKoJnb7KtLR8VZL2yPqk7jztgRMaa1mxMCnt",
  "$type": "note",
  "$dataContractId": "5wpZAEWndYcTeuwZpkmSa8s49cHXU5q2DhdibesxFSu8",
  "$ownerId": "5Zqim5LkL76dBMqa1kE2AFRng2yqpgyVTKK6kTqWbYmu",
  "$revision": 1,
  "message": "Tutorial Test @ Mon, 27 Apr 2020 15:30:17 GMT"
}
```

# Document Validation

The platform protocol performs several forms of validation related to documents: model validation, state transition structure validation, and state transition data validation.
 - Model validation - ensures object models are correct
 - State transition structure validation - only checks the content of the state transition
 - State transition data validation - takes the overall platform state into consideration

**Example:** A document state transition for an existing document could pass structure validation; however, it would fail data validation since the document already exists.

## Document Model

The document model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/integration/document/validateDocumentFactory.spec.js). The test output below shows the necessary criteria:

```
validateDocumentFactory
  ✓ should return invalid result if a document contractId is not equal to Data Contract ID
  ✓ should return valid result is a document is valid
  Base schema
    $id
      ✓ should be present
      ✓ should be a string
      ✓ should be no less than 42 chars
      ✓ should be no longer than 44 chars
      ✓ should be base58 encoded
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
      ✓ should be a string
      ✓ should be no less than 42 chars
      ✓ should be no longer than 44 chars
      ✓ should be base58 encoded
    $ownerId
      ✓ should be present
      ✓ should be a string
      ✓ should be no less than 42 chars
      ✓ should be no longer than 44 chars
      ✓ should be base58 encoded
```

## State Transition Structure

State transition structure validation verifies that the content of state transition fields complies with the requirements for the fields. The state transition `actions` and `documents` fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/integration/document/stateTransition/validation/structure/validateDocumentsBatchTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateDocumentsBatchTransitionStructureFactory
  ✓ should return invalid result if data contract was not found
  ✓ should return invalid result if there are duplicate document transitions with the same ID
  ✓ should return invalid result if there are duplicate unique index values
  ✓ should return invalid result if there are no identity found
  ✓ should return invalid result with invalid signature

  create
    ✓ should return invalid result if there are documents with wrong generated $id
    ✓ should return invalid result if there are documents with wrong $entropy
    schema
      $entropy
        ✓ should be present
        ✓ should be a string
        ✓ should be no less than 26 chars
        ✓ should be no longer than 35 chars
  replace
    schema
      $revision
        ✓ should be present
        ✓ should be a number
        ✓ should be multiple of 1.0
        ✓ should have a minimum value of 1
  base schema
    $id
      ✓ should be present
      ✓ should be a string
      ✓ should be no less than 42 chars
      ✓ should be no longer than 44 chars
      ✓ should be base58 encoded
```

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/unit/document/stateTransition/data/validateDocumentsBatchTransitionDataFactory.spec.js). The test output below shows the necessary criteria:

```
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
```
