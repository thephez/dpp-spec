# Identity Overview

Identities are a low-level construct that provide the foundation for user-facing functionality on the platform. An identity is a public key (or set of public keys) recorded on the platform chain that can be used to prove ownership of data.

Identities consist of three components that are described in further detail in following sections:

| Field | Type | Description|
| - | - | - |
| id | string (base58) | The identity id |
| publicKeys | array of keys | Public key(s) associated with the identity |
| balance | integer | Credit balance associated with the identity |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/identity/identity.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "id": {
      "type": "string",
      "minLength": 42,
      "maxLength": 44,
      "pattern": "^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$"
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100
    },
    "balance": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": [
    "id",
    "publicKeys",
    "balance"
  ]
}
```

## Identity id

The identity `id` is calculated by Base58 encoding the double sha256 hash of the [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) used to fund the identity creation.

`id = base58(sha256(sha256(<identity create funding output>)))`

### Example id creation
```javascript
// From the JavaScript reference implementation (js-dpp)
// IdentityCreateTransition.js
    this.identityId = bs58.encode(
      hash(Buffer.from(lockedOutPoint, 'base64')),
    );
```

## Identity publicKeys

The identity `publicKeys` array stores information regarding each public key associated with the identity. Each identity must have at least one public key.

Each item in the `publicKeys` array consists an object containing:

| Field | Type | Description|
| - | - | - |
| id | integer | The key id (`=> 0`, unique among keys in `publicKeys` array) |
| type | integer | Type of key (default: 0 - ECDSA) |
| data | string (base64) | Public key |
| isEnabled | boolean | Status of key |

Each identity public key must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/identity/publicKey.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "minimum": 0
    },
    "type": {
      "type": "integer",
      "enum": [0]
    },
    "data": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2048,
      "pattern": "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$"
    },
    "isEnabled": {
      "type": "boolean"
    }
  },
  "required": [
    "id",
    "type",
    "data",
    "isEnabled"
  ],
  "additionalProperties": false
}
```

### Public Key `id`

Each public key in an identity's `publicKeys` array must be assigned a unique index number (`id`).


### Public Key `type`

The `type` field indicates the algorithm used to derive the key.

| Type | Description |
| :-: | - |
| 0 | ECDSA (default) |
| 1 | BLS (currently unused)|

### Public Key `data`

The `data` field contains the compressed public key encoded as base64.

#### Example data encode/decode

**Encode**
```javascript
// From the JavaScript reference implementation (js-dpp)
// AbstractStateTransitionIdentitySigned.js
  /* We store compressed public key in the identity as a base64 string... */
  pubKeyBase = new PublicKey({
    ...privateKeyModel.toPublicKey().toObject(),
    compressed: true,
  })
    .toBuffer()
    .toString('base64');
```

**Decode**
```javascript
// From the JavaScript reference implementation (js-dpp)
// validatePublicKeysFactory.js
        const dataHex = Buffer.from(publicKey.data, 'base64').toString('hex');
```

### Public Key `isEnabled`

The `isEnabled` field indicates whether or not the key is an active, valid key. Setting this to `false` will disable the key.

**Note:** Keys are disabled (rather than deleted) to ensure that signature verification is possible for any data they signed.

## Identity balance

Each identity has a balance of credits established by value locked via a layer 1 lock transaction. This credit balance is used to pay the fees associated with state transitions.

# Identity Creation

Identities are created on the platform by submitting the identity information in an identity create state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`2` for identity create) |
| lockedOutPoint | string | Lock [outpoint]([https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint)) from the layer 1 locking transaction |
| publicKeys | array of keys | [Public key(s)](#identity-publickeys) associated with the identity |
| signature | string | Signature of state transition data |

**Note:** The lock transaction that creates the `lockedOutPoint` is not covered in this document. The preliminary design simply uses an `OP_RETURN` output.

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/identity/stateTransition/identityCreate.json) (in addition to the state transition [base schema](https://github.com/dashevo/js-dpp/blob/v0.12.0/schema/stateTransition/stateTransitionBase.json) that is required for all state transitions):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "lockedOutPoint": {
      "type": "string",
      "minLength": 48,
      "maxLength": 48,
      "pattern": "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$"
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10
    }
  },
  "required": [
    "lockedOutPoint",
    "publicKeys"
  ]
}
```

**Example State Transition**

**_TODO: Update with v0.12.0 example_**

```json
{
  "protocolVersion": 0,
  "type": 3,
  "lockedOutPoint": "6NnSpFNGO9RmTl/joS9Bow64fE1YASEV+nv/4DnH0RsAAAAA",
  "identityType": 1,  
  "publicKeys": [
    {
      "id": 1,
      "type": 1,
      "data": "A6AJAfRJyKuNoNvt33ygYfYh6OIYA8tF1s2BQcRA9RNg",
      "isEnabled": true
    }
  ],
  "signaturePublicKeyId": 1,  
  "signature": "IAN3MdbBZAU9Llpt8scGj11fAlJVOHj1Cfc/HAZrlE/Uf2IeD9nweGkUC3SULAnF1oIxfK7yndoOwLuvP8TLCwc=",
}
```

## Identity Create State Transition Signing

**Note:** The identity create state transition signature is unique in that it must be signed by the private key used in the layer 1 locking transaction. All other state transitions will be signed by a private key of the identity submitting them.

The process to sign an identity create state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature`
2. Sign the encoded data with private key associated with a lock transaction public key
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step

### Code snipits related to signing
```javascript
// From js-dpp
// AbstractStateTransition.js
// Serialize encodes the object (excluding the signature-related fields) with canonical CBOR
const data = this.serialize({ skipSignature: true });
const privateKeyModel = new PrivateKey(privateKey);

this.signature = sign(data, privateKeyModel).toString('base64');

// From dashcore-lib
// signer.js
/**
* @param {Buffer} data
* @param {string|PrivateKey} privateKey
* @return {Buffer}
*/
function sign(data, privateKey) {
	var hash = doubleSha(data);
	return signHash(hash, privateKey);
}

/**
* Sign hash.
* @param {Buffer} hash
* @param {string|PrivateKey} privateKey
* @return {Buffer} - 65-bit compact signature
*/
function signHash(hash, privateKey) {
	if (typeof privateKey === 'string') {
		privateKey = new PrivateKey(privateKey);
	}

	var ecdsa = new ECDSA();
	ecdsa.hashbuf = hash;
	ecdsa.privkey = privateKey;
	ecdsa.pubkey = privateKey.toPublicKey();
	ecdsa.signRandomK();
	ecdsa.calci();
	return ecdsa.sig.toCompact();
}
```

# Identity Validation

The platform protocol performs several forms of validation related to identities: model validation, structure validation, and data validation.
 - Model validation - ensures object models are correct
 - State transition structure validation - only checks the content of the state transition
 - State transition data validation - takes the overall platform state into consideration

**Example:** An identity create state transition for an existing identity could pass structure validation; however, it would fail data validation since the identity already exists.

## Identity Model

The identity model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/integration/identity/validation/validateIdentityFactory.spec.js). The test output below shows the necessary criteria:

```
Identity
validateIdentityFactory
  ✓ should return valid result if a raw identity is valid
  ✓ should return valid result if an identity model is valid
  id
    ✓ should be present
    ✓ should be a string
    ✓ should not be less than 42 characters
    ✓ should not be more than 44 characters
    ✓ should be base58 encoded
  balance
    ✓ should be present
    ✓ should be an integer
    ✓ should be greater or equal 0
  publicKeys
    ✓ should be present
    ✓ should be an array
    ✓ should not be empty
    ✓ should throw an error if publicKeys have more than 100 keys
```

## Public Key Model

The public key model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/integration/identity/validation/validatePublicKeysFactory.spec.js). The test output below shows the necessary criteria:

```
PublicKeys
validatePublicKeysFactory
  ✓ should return invalid result if there are duplicate key ids
  ✓ should return invalid result if there are duplicate keys
  ✓ should return invalid result if key data is not a valid DER
  id
    ✓ should be present
    ✓ should be a number
    ✓ should be an integer
    ✓ should be greater or equal to one
  type
    ✓ should be present
    ✓ should be a number
  data
    ✓ should be present
    ✓ should be a string
    ✓ should be no less than 1 character
    ✓ should be no longer than 2048 character
    ✓ should be in base64 format
  isEnabled
    ✓ should be present
    ✓ should be a number      
```

## State Transition Structure

Structure validation verifies that the content of state transition fields complies with the requirements for the field. The identity `type` and `publicKeys` fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/integration/identity/stateTransition/identityCreateTransition/validateIdentityCreateSTStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateIdentityCreateSTStructureFactory
  ✓ should pass valid raw state transition
  ✓ should pass valid state transition  
```

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. The state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.12.0/test/integration/identity/stateTransition/identityCreateTransition/validateIdentityCreateSTDataFactory.spec.js). The test output below shows the necessary criteria:

```
validateIdentityCreateSTDataFactory
  ✓ should return invalid result if identity already exists
  ✓ should return valid result if state transition is valid
  ✓ should return invalid result if lock transaction is invalid
```

**Note:** Additional validation rules will be added in future versions.
