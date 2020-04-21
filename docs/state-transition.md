# State Transition Overview

 State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state. Each one must contain:
 - All fields defined in the [base schema](#base-schema)
 - Additional fields specific to the type of action the state transition provides (e.g. [creating an identity](identity.md#identity-create-schema))

## Fees

State transition fees are paid via the credits established when an identity is created. Credits are created at a rate of [1000 credits/satoshi](https://github.com/dashevo/js-dpp/blob/v0.12.0/lib/identity/creditsConverter.js#L1).

# Base Schema

All state transitions are built on the base schema and include the following fields:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type:<br>`0` - [data contract](data-contract.md#data-contract-creation)<br>`1` - [document](document.md#document-submission)<br>`2` - [identity create](identity.md#identity-creation) |
| signature | string (base64)| Signature of state transition data (86-88 characters) |

Additionally, all state transitions except the identity create state transition include:

| Field | Type | Description|
| - | - | - |
| signaturePublicKeyId | integer | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition (`=> 0`)|


Each state transition must comply with the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/stateTransition/stateTransitionBase.json):


```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "protocolVersion": {
      "type": "number",
      "const": 0
    },
    "type": {
      "type": "integer",
      "enum": [0, 1, 2]
    },
    "signaturePublicKeyId": {
      "type": ["integer", "null"],
      "minimum": 0
    },
    "signature": {
      "type": "string",
      "minLength": 86,
      "maxLength": 88,
      "pattern": "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$"
    }
  },
  "required": [
    "protocolVersion",
    "type",
    "signature"
  ],
  "additionalProperties": false
}
```

# State Transition Types

## Data Contract

| Field | Type | Description|
| - | - | - |
| dataContract | [data contract object](data-contract.md#data-contract-object) | Object containing valid [data contract](data-contract.md) details |

More detailed information about the `dataContract` object can be found in the [data contract section](data-contract.md).

## Document

| Field | Type | Description|
| - | - | - |
| actions | array of integers | [Action](document.md#document-actions) the platform should take for the associated document in the `documents` array |
| documents | array of [document objects](document.md#document-object) | [Document(s)](document.md#document-object) |

More detailed information about the `actions` and `documents` objects can be found in the [document section](document.md).

## Identity Create

| Field | Type | Description|
| - | - | - |
| lockedOutPoint | string (base64)| Lock [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) from the layer 1 locking transaction (48 characters) |
| publicKeys | array of keys | [Public key(s)](identity.md#identity-publickeys) associated with the identity (maximum number of keys: `10`)|

More detailed information about the `publicKeys` object can be found in the [identity section](identity.md).

# State Transition Signing

State transitions must be signed by a private key associated with the identity creating the state transition.

The process to sign a state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the identity creating the state transition
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step
4. For all state transitions _other than identity create_, set the state transition`signaturePublicKeyId` to the [public key `id`](identity.md#public-key-id) corresponding to the key used to sign

## Signature Validation

The `signature` validation (see [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/unit/stateTransition/validation/validateStateTransitionSignatureFactory.spec.js)) verifies that:

1. The identity has a public key
2. The identity's public key is of type `ECDSA`
3. The state transition signature is valid

The example test output below shows the necessary criteria:

```
validateStateTransitionSignatureFactory
  ✓ should return MissingPublicKeyError if the identity doesn't have a matching public key
  ✓ should return InvalidIdentityPublicKeyTypeError if type is not ECDSA_SECP256K1
  ✓ should return InvalidStateTransitionSignatureError if signature is invalid
```

# State Transition Validation

The state transition schema must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.11.1/test/integration/stateTransition/validation/validateStateTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateStateTransitionStructureFactory
    ✓ should return invalid result if ST invalid against extension schema
    ✓ should return invalid result if ST is invalid against extension function

    Base schema
      protocolVersion
        ✓ should be present
        ✓ should equal to 0
      type
        ✓ should be present
        ✓ should have defined extension
      signature
        ✓ should be present
        ✓ should no have length < 86
        ✓ should not have length > 88
        ✓ should be base64 encoded
      signaturePublicKeyId
        ✓ should be an integer
        ✓ should be a nullable
        ✓ should not be < 1
```

## Data Contract State Transition

```
    Data Contract Schema
      ✓ should be valid
      dataContract
        ✓ should be present
```

### Document State Transition

```
    Documents Schema
      ✓ should be valid
      actions
        ✓ should be present
        ✓ should be an array
        ✓ should have at least one element
        ✓ should have no more than 10 elements
        ✓ should have action types as elements
      documents
        ✓ should be present
        ✓ should be an array
        ✓ should have at least one element
        ✓ should have no more than 10 elements
        ✓ should have objects as elements
```

## Identity State Transition

```
    Identity schema
      ✓ should be valid
      lockedOutPoint
        ✓ should be present
        ✓ should not be less than 48 characters in length
        ✓ should not be more than 48 characters in length
        ✓ should be base64 encoded
      identityType
        ✓ should be present
        ✓ should be an integer
        ✓ should not be less than 0
        ✓ should not be more than 65535
      publicKeys
        ✓ should be present
        ✓ should not be empty
        ✓ should not have more than 10 items
```