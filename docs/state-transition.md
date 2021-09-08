# State Transition Overview

 State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state. Each one must contain:

 - [Common fields](#common-fields) present in all state transitions
 - Additional fields specific to the type of action the state transition provides (e.g. [creating an identity](identity.md#identity-create-schema))

## Fees

State transition fees are paid via the credits established when an identity is created. Credits are created at a rate of [1000 credits/satoshi](https://github.com/dashevo/js-dpp/blob/v0.21.0/lib/identity/creditsConverter.js#L1). The current fee rate is [1 credit/byte](https://github.com/dashevo/js-dpp/blob/v0.21.0/lib/stateTransition/calculateStateTransitionFee.js#L1).

## Size

All serialized data (including state transitions) is limited to a maximum size of [16 KB](https://github.com/dashevo/js-dpp/blob/v0.21.0/lib/util/serializer.js#L5).

## Common Fields

All state transitions include the following fields:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type:<br>`0` - [data contract](data-contract.md#data-contract-creation)<br>`1` - [documents batch](document.md#document-submission)<br>`2` - [identity create](identity.md#identity-creation)<br>`3` - [identity topup](identity.md#identity-topup) |
| signature | array of bytes | Signature of state transition data (65 bytes) |

Additionally, all state transitions except the identity create and topup state transitions include:

| Field | Type | Description|
| - | - | - |
| signaturePublicKeyId | integer | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition (`=> 0`)|

# State Transition Types

## Data Contract

| Field | Type | Description|
| - | - | - |
| dataContract | [data contract object](data-contract.md#data-contract-object) | Object containing valid [data contract](data-contract.md) details |
| entropy | array of bytes | Entropy used to generate the data contract ID (32 bytes) |

More detailed information about the `dataContract` object can be found in the [data contract section](data-contract.md).

### Entropy Generation

Entropy is included in [Data Contracts](data-contract.md#data-contract-creation) and [Documents](document.md#document-create-transition).

```javascript
// From the JavaScript reference implementation (js-dpp)
// generateEntropy.js
function generate() {
  return crypto.randomBytes(32);
}
```

## Documents Batch

| Field | Type | Description|
| - | - | - |
| ownerId | array of bytes | [Identity](identity.md) submitting the document(s) (32 bytes) |
| transitions | array of transition objects | Document `create`, `replace`, or `delete` transitions (up to 10 objects) |

More detailed information about the `transitions` array can be found in the [document section](document.md).

## Identity Create

| Field | Type | Description|
| - | - | - |
| lockedOutPoint | array of bytes | Lock [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) from the layer 1 locking transaction (36 bytes) |
| publicKeys | array of keys | [Public key(s)](identity.md#identity-publickeys) associated with the identity (maximum number of keys: `10`)|

More detailed information about the `publicKeys` object can be found in the [identity section](identity.md).

## Identity TopUp

| Field | Type | Description|
| - | - | - |
| lockedOutPoint | array of bytes | Lock [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) from the layer 1 locking transaction (36 bytes) |
| identityId | array of bytes | An [Identity ID](identity.md#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |

# State Transition Signing

State transitions must be signed by a private key associated with the identity creating the state transition.

The process to sign a state transition consists of the following steps:

1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the identity creating the state transition
3. Set the state transition `signature` to the value of the signature created in the previous step
4. For all state transitions _other than identity create or topup_, set the state transition`signaturePublicKeyId` to the [public key `id`](identity.md#public-key-id) corresponding to the key used to sign

## Signature Validation

The `signature` validation (see [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.21.0/test/unit/stateTransition/validation/validateStateTransitionIdentitySignatureFactory.spec.js)) verifies that:

1. The identity exists
2. The identity has a public key
3. The identity's public key is of type `ECDSA`
4. The state transition signature is valid

The example test output below shows the necessary criteria:

```text
validateStateTransitionIdentitySignatureFactory
  ✔ should pass properly signed state transition
  ✔ should return invalid result if owner id doesn't exist
  ✔ should return MissingPublicKeyError if the identity doesn't have a matching public key
  ✔ should return InvalidIdentityPublicKeyTypeError if type is not ECDSA_SECP256K1
  ✔ should return InvalidStateTransitionSignatureError if signature is invalid
```

# State Transition Validation

The state transition schema must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/tree/v0.21.0/test/unit/stateTransition/validation). The test output below shows the necessary criteria:

```text
validateStateTransitionBasicFactory
  ✔ should return invalid result if ST type is missing
  ✔ should return invalid result if ST type is not valid
  ✔ should return invalid result if ST is invalid against validation function
  ✔ should return invalid result if ST size is more than 16 kb (219ms)
  ✔ should return valid result

validateStateTransitionFeeFactory
  ✔ should throw InvalidStateTransitionTypeError on invalid State Transition
  DataContractCreateTransition
    ✔ should return invalid result if balance is not enough
    ✔ should return valid result
  DocumentsBatchTransition
    ✔ should return invalid result if balance is not enough
    ✔ should return valid result
  IdentityCreateStateTransition
    ✔ should return invalid result if asset lock output amount is not enough
    ✔ should return valid result
  IdentityTopUpTransition
    ✔ should return invalid result if sum of balance and asset lock output amount is not enough
    ✔ should return valid result

validateStateTransitionIdentitySignatureFactory
  ✔ should pass properly signed state transition
  ✔ should return invalid result if owner id doesn't exist
  ✔ should return MissingPublicKeyError if the identity doesn't have a matching public key
  ✔ should return InvalidIdentityPublicKeyTypeError if type is not ECDSA_SECP256K1
  ✔ should return InvalidStateTransitionSignatureError if signature is invalid

validateStateTransitionKeySignatureFactory
  ✔ should return invalid result if signature is not valid
  ✔ should return valid result if signature is valid

validateStateTransitionStateFactory
  ✔ should return invalid result if State Transition type is invalid
  ✔ should return invalid result if Data Contract State Transition is not valid
  ✔ should return valid result
```
