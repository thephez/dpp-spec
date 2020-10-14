# State Transition Overview

 State transitions are the means for submitting data that creates, updates, or deletes platform data and results in a change to a new state. Each one must contain:
 - Required fields from the [base schema](#base-schema)
 - Additional fields specific to the type of action the state transition provides (e.g. [creating an identity](identity.md#identity-create-schema))

## Fees

State transition fees are paid via the credits established when an identity is created. Credits are created at a rate of [1000 credits/satoshi](https://github.com/dashevo/js-dpp/blob/v0.16.0/lib/identity/creditsConverter.js#L1). The current fee rate is [1 credit/byte](https://github.com/dashevo/js-dpp/blob/v0.16.0/lib/stateTransition/calculateStateTransitionFee.js#L1).

## Size

All serialized data (including state transitions) is limited to a maximum size of [16 KB](https://github.com/dashevo/js-dpp/blob/v0.16.0/lib/util/serializer.js#L5).

## Common Fields

All state transitions include the following fields:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type:<br>`0` - [data contract](data-contract.md#data-contract-creation)<br>`1` - [documents batch](document.md#document-submission)<br>`2` - [identity create](identity.md#identity-creation)<br>`3` - [identity topup](identity.md#identity-topup) |
| signature | string (base64)| Signature of state transition data (86-88 characters) |

Additionally, all state transitions except the identity create and topup state transitions include:

| Field | Type | Description|
| - | - | - |
| signaturePublicKeyId | integer | The `id` of the [identity public key](identity.md#identity-publickeys) that signed the state transition (`=> 0`)|


# State Transition Types

## Data Contract

| Field | Type | Description|
| - | - | - |
| dataContract | [data contract object](data-contract.md#data-contract-object) | Object containing valid [data contract](data-contract.md) details |
| entropy | object | Entropy used to generate the data contract ID (20-35 bytes) |

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
| ownerId | string (base58) | [Identity](identity.md) submitting the document(s) |
| transitions | array of transition objects | Document `create`, `replace`, or `delete` transitions (up to 10 objects) |

More detailed information about the `transitions` array can be found in the [document section](document.md).

## Identity Create

| Field | Type | Description|
| - | - | - |
| lockedOutPoint | object | Lock [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) from the layer 1 locking transaction (36 bytes) |
| publicKeys | array of keys | [Public key(s)](identity.md#identity-publickeys) associated with the identity (maximum number of keys: `10`)|

More detailed information about the `publicKeys` object can be found in the [identity section](identity.md).

## Identity TopUp

| Field | Type | Description|
| - | - | - |
| lockedOutPoint | object | Lock [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) from the layer 1 locking transaction (36 bytes) |
| identityId | object | An [Identity ID](identity.md#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |


# State Transition Signing

State transitions must be signed by a private key associated with the identity creating the state transition.

The process to sign a state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with a private key associated with the identity creating the state transition
3. Set the state transition `signature` to the ~~base64 encoded~~ value of the signature created in the previous step
4. For all state transitions _other than identity create or topup_, set the state transition`signaturePublicKeyId` to the [public key `id`](identity.md#public-key-id) corresponding to the key used to sign

## Signature Validation

The `signature` validation (see [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/unit/stateTransition/validation/validateStateTransitionSignatureFactory.spec.js)) verifies that:

1. The identity has a public key
2. The identity's public key is of type `ECDSA`
3. The state transition signature is valid

The example test output below shows the necessary criteria:

```
validateStateTransitionSignatureFactory
  ✓ should pass properly signed state transition
  ✓ should return MissingPublicKeyError if the identity doesn't have a matching public key
  ✓ should return InvalidIdentityPublicKeyTypeError if type is not ECDSA_SECP256K1
  ✓ should return InvalidStateTransitionSignatureError if signature is invalid
```

# State Transition Validation

The state transition schema must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/stateTransition/validation/validateStateTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateIdentityExistence
  ✓ should return invalid result if identity is not found

validateStateTransitionDataFactory
  ✓ should return invalid result if State Transition type is invalid
  ✓ should return invalid result if Data Contract State Transition is not valid

validateStateTransitionFeeFactory
  ✓ should return invalid result if balance is not enough
  ✓ should return valid result for DataContractCreateTransition
  ✓ should return valid result for DocumentsBatchTransition
  ✓ should return valid result for IdentityCreateStateTransition
  ✓ should return valid result for IdentityTopUpTransition
  ✓ should throw InvalidStateTransitionTypeError on invalid State Transition

validateStateTransitionSignatureFactory
  ✓ should pass properly signed state transition
  ✓ should return MissingPublicKeyError if the identity doesn't have a matching public key
  ✓ should return InvalidIdentityPublicKeyTypeError if type is not ECDSA_SECP256K1
  ✓ should return InvalidStateTransitionSignatureError if signature is invalid

validateStateTransitionStructureFactory
  ✓ should return invalid result if ST type is missing
  ✓ should return invalid result if ST type is not valid
  ✓ should return invalid result if ST is invalid against validation function
  ✓ should return invalid result if ST size is more than 16 kb
```
