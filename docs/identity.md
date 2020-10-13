# Identity Overview

Identities are a low-level construct that provide the foundation for user-facing functionality on the platform. An identity is a public key (or set of public keys) recorded on the platform chain that can be used to prove ownership of data. Please see the [Identity DIP](https://github.com/dashpay/dips/blob/master/dip-0011.md) for additional information.

Identities consist of three components that are described in further detail in following sections:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The identity version |
| id | object | The identity id (32 bytes) |
| publicKeys | array of keys | Public key(s) associated with the identity |
| balance | integer | Credit balance associated with the identity |
| revision | integer | Identity update revision |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/identity/identity.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 0,
      "$comment": "Maximum is the latest Identity protocol version"
    },
    "id": {
      "type": "object",
      "byteArray": true,
      "minBytesLength": 32,
      "maxBytesLength": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "uniqueItems": true
    },
    "balance": {
      "type": "integer",
      "minimum": 0
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "description": "Identity update revision"
  }
},
  "required": [
    "protocolVersion",
    "id",
    "publicKeys",
    "balance",
    "revision"
  ]
}
```

**Example Identity**

```json
{
  "protocolVersion": 0,
  "id": "3z343JK2X884uy8pK9iNRw8urymdEo71GJFPrC1QEjJe",
  "publicKeys": [
    {
      "id": 0,
      "type": 0,
      "data": "A677zlRADmHdE395/O/YrCQxmNxD1BlB3K+5Z+BSVrUo",
      "isEnabled": true
    }
  ],
  "balance": 0
}
```

## Identity id

The identity `id` is calculated by Base58 encoding the double sha256 hash of the [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) used to fund the identity creation.

`id = base58(sha256(sha256(<identity create funding output>)))`

### Example id creation
```javascript
// From the JavaScript reference implementation (js-dpp)
// IdentityCreateTransition.js
    this.identityId = new Identifier(
      hash(this.lockedOutPoint),
    );
```

**Note:** The identity `id` uses the Dash Platform specific `application/x.dash.dpp.identifier` content media type. For additional information, please refer to the [js-dpp PR 252](https://github.com/dashevo/js-dpp/pull/252) that introduced it and [Identifier.js](https://github.com/dashevo/js-dpp/blob/v0.16.0/lib/Identifier.js).

## Identity publicKeys

The identity `publicKeys` array stores information regarding each public key associated with the identity. Each identity must have at least one public key.

**Note:** As of Dash Platform Protocol [version 0.16](https://github.com/dashevo/js-dpp/pull/234), any public key(s) assigned to an identity must be unique (not already used by any identity). Prior versions checked (at most) the first key only.

Each item in the `publicKeys` array consists an object containing:

| Field | Type | Description|
| - | - | - |
| id | integer | The key id (all public keys must be unique) |
| type | integer | Type of key (default: 0 - ECDSA) |
| data | object | Public key (ECDSA: 33 bytes; BLS: 48 bytes) |

**Note:** the `isEnabled` field was removed in [version 0.16](https://github.com/dashevo/js-dpp/pull/236).

Each identity public key must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/identity/publicKey.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "minimum": 0,
      "description": "Public key ID",
      "$comment": "Must be unique for the identity. It can’t be changed after adding a key. Included when signing state transitions to indicate which identity key was used to sign."
    },
    "type": {
      "type": "integer",
      "enum": [
        0,
        1
      ],
      "description": "Public key type. 0 - ECDSA Secp256k1, 1 - BLS 12-381",
      "$comment": "It can't be changed after adding a key"
    },
    "data": {
      "type": "object",
      "byteArray": true,
      "description": "Raw public key",
      "$commit": "It must be a valid key of the specified type and unique for the identity. It can’t be changed after adding a key"
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "type": {
            "const": 0
          }
        }
      },
      "then": {
        "properties": {
          "data": {
            "byteArray": true,
            "minBytesLength": 33,
            "maxBytesLength": 33
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "type": {
            "const": 1
          }
        }
      },
      "then": {
        "properties": {
          "data": {
            "byteArray": true,
            "minBytesLength": 48,
            "maxBytesLength": 48
          }
        }
      }
    }
  ],
  "required": [
    "id",
    "type",
    "data"
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
pubKeyBase = new PublicKey({
  ...privateKeyModel.toPublicKey().toObject(),
  compressed: true,
})
  .toBuffer();
```

**Decode**
```javascript
// From the JavaScript reference implementation (js-dpp)
// validatePublicKeysFactory.js
const dataHex = rawPublicKey.data.toString('hex');
```

## Identity balance

Each identity has a balance of credits established by value locked via a layer 1 lock transaction. This credit balance is used to pay the fees associated with state transitions.

# Identity Creation

Identities are created on the platform by submitting the identity information in an identity create state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The identity create protocol version (currently `0`) |
| type | integer | State transition type (`2` for identity create) |
| lockedOutPoint | object | Lock [outpoint]([https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint)) from the layer 1 locking transaction (36 bytes) |
| publicKeys | array of keys | [Public key(s)](#identity-publickeys) associated with the identity |
| signature | object | Signature of state transition data (65 bytes) |

**Note:** The lock transaction that creates the `lockedOutPoint` is not covered in this document. The preliminary design simply uses an `OP_RETURN` output.

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/identity/stateTransition/identityCreate.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 0,
      "$comment": "Maximum is the latest Identity Create Transition protocol version"
    },
    "type": {
      "type": "integer",
      "const": 2
    },
    "lockedOutPoint": {
      "type": "object",
      "byteArray": true,
      "minBytesLength": 36,
      "maxBytesLength": 36
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10,
      "uniqueItems": true
    },
    "signature": {
      "type": "object",
      "byteArray": true,
      "minBytesLength": 65,
      "maxBytesLength": 65
    }
  },
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "lockedOutPoint",
    "publicKeys",
    "signature"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion": 0,
  "type": 2,
  "lockedOutPoint": "qalDv8f/ZrHtkdoqVFA/lgyEHvj9RJM7bSJBZG0HDIIAAAAA",
  "publicKeys": [
    {
      "id": 1,
      "type": 0,
      "data": "A6AJAfRJyKuNoNvt33ygYfYh6OIYA8tF1s2BQcRA9RNg",
      "isEnabled": true
    }
  ],
  "signature": "IOSuSYdQnYVttzsrD6nlfdN6b+fXyOE8Yz3XWpoafC93R5YQmOwRtTYvqMiJ/EtkDEsBoQevuo2FjgTw8lC4pvM="
}
```

# Identity TopUp

Identity credit balances are increased by submitting the topup information in an identity topup state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The identity topup protocol version (currently `0`) |
| type | integer | State transition type (`3` for identity topup) |
| lockedOutPoint | object | Lock [outpoint]([https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint)) from the layer 1 locking transaction (36 bytes) |
| identityId | object | An [Identity ID](#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |
| signature | object | Signature of state transition data (65 bytes) |

**Note:** The lock transaction that creates the `lockedOutPoint` is not covered in this document. The preliminary design simply uses an `OP_RETURN` output.

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/schema/identity/stateTransition/identityTopUp.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 0,
      "$comment": "Maximum is the latest Identity TopUp Transition protocol version"
    },
    "type": {
      "type": "integer",
      "const": 3
    },
    "lockedOutPoint": {
      "type": "object",
      "byteArray": true,
      "minBytesLength": 36,
      "maxBytesLength": 36
    },
    "identityId": {
      "type": "object",
      "byteArray": true,
      "minBytesLength": 32,
      "maxBytesLength": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "signature": {
      "type": "object",
      "byteArray": true,
      "minBytesLength": 65,
      "maxBytesLength": 65
    }
  },
  "additionalProperties": false,
  "required": [
    "protocolVersion",
    "type",
    "lockedOutPoint",
    "identityId",
    "signature"
  ]
}

```

**Example State Transition**

```json
{
  "protocolVersion": 0,
  "type": 3,
  "identityId": "Gb9YEHMYxcMiSnBhtBQQmttmAoqN1asi6HKQxRR7YdXA",
  "lockedOutPoint": "o/wqVhGcP/p5QzE8ozVoVN1pnjesfDmhUjdhQv4EN6UAAAAA",
  "signature": "HwW7Dwq34OGgsoG8sDe+2G3Gs69+X5v7ELFHonpVgkzwSBqToRXUl6LePs+g+Pgq7DxEIGgSQG0C8OzHiXo8dT8=",
}
```

# Identity State Transition Signing

**Note:** The identity create and topup state transition signatures are unique in that they must be signed by the private key used in the layer 1 locking transaction. All other state transitions will be signed by a private key of the identity submitting them.

The process to sign an identity create state transition consists of the following steps:
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature`
2. Sign the encoded data with private key associated with a lock transaction public key
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step

### Code snipits related to signing
```javascript
// From js-dpp
// AbstractStateTransition.js
// toBuffer encodes the object (excluding the signature-related fields) with canonical CBOR
const data = this.toBuffer({ skipSignature: true });
const privateKeyModel = new PrivateKey(privateKey);

this.setSignature(sign(data, privateKeyModel));

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

The identity model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/identity/validation/validateIdentityFactory.spec.js). The test output below shows the necessary criteria:

```
Identity
validateIdentityFactory
  ✓ should return valid result if a raw identity is valid
  ✓ should return valid result if an identity model is valid
  id
    ✓ should be present
    ✓ should be a byte array
    ✓ should not be less than 32 bytes
    ✓ should not be more than 32 bytes
  balance
    ✓ should be present
    ✓ should be an integer
    ✓ should be greater or equal 0
  publicKeys
    ✓ should be present
    ✓ should be an array
    ✓ should not be empty
    ✓ should be unique
    ✓ should throw an error if publicKeys have more than 100 keys
  revision
    ✓ should be present
    ✓ should be an integer
    ✓ should be greater or equal 0    
```

## Public Key Model

The public key model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/identity/validation/validatePublicKeysFactory.spec.js). The test output below shows the necessary criteria:

```
PublicKeys
validatePublicKeysFactory
  ✓ should return invalid result if there are duplicate key ids
  ✓ should return invalid result if there are duplicate keys
  ✓ should return invalid result if key data is not a valid DER
  ✓ should pass valid public keys
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
    ✓ should be a byte array
    ECDSA_SECP256K1
      ✓ should be no less than 33 bytes
      ✓ should be no longer than 33 bytes
    BLS12_381
      ✓ should be no less than 48 bytes
      ✓ should be no longer than 48 bytes
```

## State Transition Structure

Structure validation verifies that the content of state transition fields complies with the requirements for the field. 

### Identity Create

The identity fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/identity/stateTransition/identityCreateTransition/validateIdentityCreateTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateIdentityCreateTransitionStructureFactory
  ✓ should return valid result
  protocolVersion
    ✓ should be present
    ✓ should be an integer
    ✓ should not be less than 0
    ✓ should not be greater than current version (0)
  type
    ✓ should be present
    ✓ should be equal to 2
  lockedOutPoint
    ✓ should be present
    ✓ should be a byte array
    ✓ should not be less than 36 bytes
    ✓ should not be more than 36 bytes
  publicKeys
    ✓ should be present
    ✓ should not be empty
    ✓ should not have more than 10 items
    ✓ should be unique
    ✓ should be valid
  signature
    ✓ should be present
    ✓ should be a byte array
    ✓ should be not shorter than 65 bytes
    ✓ should be not longer than 65 bytes
```

### Identity TopUp

The identity topup fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/identity/stateTransition/identityTopUpTransition/validateIdentityTopUpTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```
validateIdentityTopUpTransitionStructureFactory
  ✓ should return valid result
  protocolVersion
    ✓ should be present
    ✓ should be an integer
    ✓ should not be less than 0
    ✓ should not be greater than current version (0)
  type
    ✓ should be present
    ✓ should be equal to 3
  lockedOutPoint
    ✓ should be present
    ✓ should be a byte array
    ✓ should not be less than 36 bytes
    ✓ should not be more than 36 bytes
  identityId
    ✓ should be present
    ✓ should be a byte array
    ✓ should be no less than 32 bytes
    ✓ should be no longer than 32 bytes
  signature
    ✓ should be present
    ✓ should be a byte array
    ✓ should be not shorter than 65 bytes
    ✓ should be not longer than 65 bytes  
```

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state. 


### Identity Create

The identity create state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/identity/stateTransition/identityCreateTransition/validateIdentityCreateTransitionDataFactory.spec.js). The test output below shows the necessary criteria:

```
validateIdentityCreateTransitionDataFactory
  ✓ should return invalid result if identity already exists
  ✓ should return invalid result if lock transaction is invalid
  ✓ should return invalid result if identity public key already exists
  ✓ should return valid result if state transition is valid
```

### Identity TopUp

The identity topup state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.16.0/test/integration/identity/stateTransition/identityTopUpTransition/validateIdentityTopUpTransitionDataFactory.spec.js). The test output below shows the necessary criteria:

```
validateIdentityTopUpTransitionDataFactory
  ✓ should return invalid result if identity does not exist
  ✓ should return valid result if state transition is valid
  ✓ should return invalid result if lock transaction is invalid
```

**Note:** Additional validation rules may be added in future versions.
