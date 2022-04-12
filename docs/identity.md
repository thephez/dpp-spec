# Identity Overview

Identities are a low-level construct that provide the foundation for user-facing functionality on the platform. An identity is a public key (or set of public keys) recorded on the platform chain that can be used to prove ownership of data. Please see the [Identity DIP](https://github.com/dashpay/dips/blob/master/dip-0011.md) for additional information.

Identities consist of three components that are described in further detail in the following sections:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The protocol version |
| id | array of bytes | The identity id (32 bytes) |
| publicKeys | array of keys | Public key(s) associated with the identity |
| balance | integer | Credit balance associated with the identity |
| revision | integer | Identity update revision |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/schema/identity/identity.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "id": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 32,
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
  "protocolVersion":1,
  "id":"6YfP6tT9AK8HPVXMK7CQrhpc8VMg7frjEnXinSPvUmZC",
  "publicKeys":[
    {
      "id":0,
      "type":0,
      "purpose":0,
      "securityLevel":0,
      "data":"AkWRfl3DJiyyy6YPUDQnNx5KERRnR8CoTiFUvfdaYSDS",
      "readOnly":false
    }
  ],
  "balance":0,
  "revision":0
}
```

## Identity id

The identity `id` is calculated by Base58 encoding the double sha256 hash of the [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint) used to fund the identity creation.

`id = base58(sha256(sha256(<identity create funding output>)))`

**Note:** The identity `id` uses the Dash Platform specific `application/x.dash.dpp.identifier` content media type. For additional information, please refer to the [js-dpp PR 252](https://github.com/dashevo/js-dpp/pull/252) that introduced it and [Identifier.js](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/lib/identifier/Identifier.js).

## Identity publicKeys

The identity `publicKeys` array stores information regarding each public key associated with the identity. Each identity must have at least one public key.

**Note:** Since v0.22, the same public key can be used for multiple identities. In previous versions any public key(s) assigned to an identity had to be unique (not already used by any identity).

Each item in the `publicKeys` array consists of an object containing:

| Field | Type | Description|
| - | - | - |
| id | integer | The key id (all public keys must be unique) |
| type | integer | Type of key (default: 0 - ECDSA) |
| data | array of bytes | Public key (ECDSA: 33 bytes; BLS: 48 bytes) |
| purpose | integer | Public key purpose (0 - Authentication, 1 - Encryption, 2 - Decryption) |
| securityLevel | integer | Public key security level. (0 - Master, 1 - Critical, 2 - High, 3 - Medium) |
| readonly | boolean | Identity public key can't be modified with `readOnly` set to `true`. This can’t be changed after adding a key. |

Each identity public key must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/schema/identity/publicKey.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
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
        1,
        2
      ],
      "description": "Public key type. 0 - ECDSA Secp256k1, 1 - BLS 12-381, 2 - ECDSA Secp256k1 Hash160",
      "$comment": "It can't be changed after adding a key"
    },
    "purpose": {
      "type": "integer",
      "enum": [
        0,
        1,
        2
      ],
      "description": "Public key purpose. 0 - Authentication, 1 - Encryption, 2 - Decryption",
      "$comment": "It can't be changed after adding a key"
    },
    "securityLevel": {
      "type": "integer",
      "enum": [
        0,
        1,
        2,
        3
      ],
      "description": "Public key security level. 0 - Master, 1 - Critical, 2 - High, 3 - Medium",
      "$comment": "It can't be changed after adding a key"
    },
    "data": true,
    "readOnly": {
      "type": "boolean",
      "description": "Read only",
      "$comment": "Identity public key can't be modified with readOnly set to true. It can’t be changed after adding a key"
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
            "type": "array",
            "byteArray": true,
            "minItems": 33,
            "maxItems": 33,
            "description": "Raw ECDSA public key",
            "$comment": "It must be a valid key of the specified type and unique for the identity. It can’t be changed after adding a key"
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
            "type": "array",
            "byteArray": true,
            "minItems": 48,
            "maxItems": 48,
            "description": "Raw BLS public key",
            "$comment": "It must be a valid key of the specified type and unique for the identity. It can’t be changed after adding a key"
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "type": {
            "const": 2
          }
        }
      },
      "then": {
        "properties": {
          "data": {
            "type": "array",
            "byteArray": true,
            "minItems": 20,
            "maxItems": 20,
            "description": "ECDSA Secp256k1 public key Hash160",
            "$comment": "It must be a valid key hash of the specified type and unique for the identity. It can’t be changed after adding a key"
          }
        }
      }
    }
  ],
  "required": [
    "id",
    "type",
    "data",
    "purpose",
    "securityLevel"
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
| 0 | ECDSA Secp256k1 (default) |
| 1 | BLS 12-381 (currently unused)|
| 2 | ECDSA Secp256k1 Hash160 |

### Public Key `data`

The `data` field contains the compressed public key.

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

### Public Key `purpose`

The `purpose` field describes which operations are supported by the key. Please refer to [DIP11 - Identities](https://github.com/dashpay/dips/blob/master/dip-0011.md#keys) for additional information regarding this.

| Type | Description |
| :-: | - |
| 0 | Authentication |
| 1 | Encryption
| 2 | Decryption |

### Public Key `securityLevel`

The `securityLevel` field indicates how securely the key should be stored by clients. Please refer to [DIP11 - Identities](https://github.com/dashpay/dips/blob/master/dip-0011.md#keys) for additional information regarding this.

| Level | Description | Security Practice |
| :-: | - | - |
| 0 | Master | Should always require a user to authenticate when signing a transition
| 1 | Critical | Should always require a user to authenticate when signing a transition
| 2 | High | Should be available as long as the user has authenticated at least once during a session
| 3 | Medium | Should not require user authentication but must require access to the client device

### Public Key `readOnly`

The `readOnly` field indicates that the public key can't be modified if it is set to `true`. The
value of this field cannot be changed after adding the key.

## Identity balance

Each identity has a balance of credits established by value locked via a layer 1 lock transaction. This credit balance is used to pay the fees associated with state transitions.

# Identity State Transition Details

There are two identity-related state transitions: [identity create](#identity-creation) and [identity topup](#identity-topup). Details are provided in this section including information about [asset locking](#asset-lock) and [signing](#identity-state-transition-signing) required for both state transitions.

## Identity Creation

Identities are created on the platform by submitting the identity information in an identity create state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The protocol version (currently `1`) |
| type | integer | State transition type (`2` for identity create) |
| assetLockProof | object | [Asset lock proof object](#asset-lock) proving the layer 1 locking transaction exists and is locked |
| publicKeys | array of keys | [Public key(s)](#identity-publickeys) associated with the identity |
| signature | array of bytes | Signature of state transition data (65 bytes) |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/schema/identity/stateTransition/identityCreate.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "type": {
      "type": "integer",
      "const": 2
    },
    "assetLockProof": {
      "type": "object"
    },
    "publicKeys": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10,
      "uniqueItems": true
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
    "assetLockProof",
    "publicKeys",
    "signature"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion":1,
  "type":2,
  "signature":"IBTTgge+/VDa/9+n2q3pb4tAqZYI48AX8X3H/uedRLH5dN8Ekh/sxRRQQS9LaOPwZSCVED6XIYD+vravF2dhYOE=",
  "assetLockProof":{
    "type":0,
    "instantLock":"AQHDHQdekbFZJOQFEe1FnRjoDemL/oPF/v9IME/qphjt5gEAAAB/OlZB9p8vPzPE55MlegR7nwhXRpZC4d5sYnOIypNgzfdDRsW01v8UtlRoORokjoDJ9hA/XFMK65iYTrQ8AAAAGI4q8GxtK9LHOT1JipnIfwiiv8zW+C/sbokbMhi/BsEl51dpoeBQEUAYWT7KRiJ4Atx49zIrqsKvmU1mJQza0Y1YbBSS/b/IPO8StX04bItPpDuTp6zlh/G7YOGzlEoe",
    "transaction":"0300000001c31d075e91b15924e40511ed459d18e80de98bfe83c5feff48304feaa618ede6010000006b483045022100dd0e4a6c25b1c7ed9aec2c93133f6de27b4c695a062f21f0aed1a2999fccf01c0220384aaf84cd5fd1c741fd1739f5c026a492abbfc18cfde296c6d90e98304f2f76012102fb9e87840f7e0a9b01f955d8eb4d1d2a52b32c9c43c751d7a348482c514ad222ffffffff021027000000000000166a14ea15af58c614b050a3b2e6bcc131fe0e7de37b9801710815000000001976a9140ccc680f945e964f7665f57c0108cba5ca77ed1388ac00000000",
    "outputIndex":0
  },
  "publicKeys":[
    {
      "id":0,
      "type":0,
      "purpose":0,
      "securityLevel":0,
      "data":"AkWRfl3DJiyyy6YPUDQnNx5KERRnR8CoTiFUvfdaYSDS",
      "readOnly":false
    }
  ]
}
```

## Identity TopUp

Identity credit balances are increased by submitting the topup information in an identity topup state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The protocol version (currently `1`) |
| type | integer | State transition type (`3` for identity topup) |
| assetLockProof | object | [Asset lock proof object](#asset-lock) proving the layer 1 locking transaction exists and is locked |
| identityId | array of bytes | An [Identity ID](#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |
| signature | array of bytes | Signature of state transition data (65 bytes) |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/schema/identity/stateTransition/identityTopUp.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "protocolVersion": {
      "type": "integer",
      "$comment": "Maximum is the latest protocol version"
    },
    "type": {
      "type": "integer",
      "const": 3
    },
    "assetLockProof": {
      "type": "object"
    },
    "identityId": {
      "type": "array",
      "byteArray": true,
      "minItems": 32,
      "maxItems": 32,
      "contentMediaType": "application/x.dash.dpp.identifier"
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
    "assetLockProof",
    "identityId",
    "signature"
  ]
}
```

**Example State Transition**

```json
{
  "protocolVersion":1,
  "type":3,
  "signature":"IEqOV4DsbVa+nPipva0UrT0z0ZwubwgP9UdlpwBwXbFSWb7Mxkwqzv1HoEDICJ8GtmUSVjp4Hr2x0cVWe7+yUGc=",
  "identityId":"6YfP6tT9AK8HPVXMK7CQrhpc8VMg7frjEnXinSPvUmZC",
  "assetLockProof":{
    "type":0,
    "instantLock":"AQF/OlZB9p8vPzPE55MlegR7nwhXRpZC4d5sYnOIypNgzQEAAAAm8edm9p8URNEE9PBo0lEzZ2s9nf4u1SV0MaZyB0JTRasiXu8QtTmfqZWjI3qVtOpUhGPu6r/2fV+0Ffi3AAAAhA77E0aScf+5PTYzgV5WR6VJ/EnjvXyAMmAcu222JyvA7M+5OoCzVF/IQs2IWaPOFsRl1n5C+dMxdvrxhpVLT8QfZJSl19wzybWrHbGRaHDw4iWHvfYdwyXN+vP8UwDz",
    "transaction":"03000000017f3a5641f69f2f3f33c4e793257a047b9f0857469642e1de6c627388ca9360cd010000006b483045022100d8c383b15a3738d13b029605d242f041bea874cb4d0def1303ca7cdf76092bf102201b1d401ae9e8cdc5efc061249d2a967960dadce53c66e34d249c42049b48b26701210335b684aa510a9b54a3a4f79283e64482a323190045c239fae5ecb0450c78f965ffffffff02e803000000000000166a14f5383f51784bc4a27e2040bdd6cd9aae7fe6814d31690815000000001976a9144a0511ec3362b35983d0a101f0572dd26abce2ee88ac00000000",
    "outputIndex":0
  }
}
```

## Asset Lock

The [identity create](#identity-creation) and [identity topup](#identity-topup) state transitions both include an asset lock proof object. This object references the layer 1 lock transaction and includes proof that the transaction is locked.

Currently there are two types of asset lock proofs: InstantSend and ChainLock. Transactions almost always receive InstantSend locks, so the InstantSend asset lock proof is the predominate type.

### InstantSend Asset Lock Proof

The InstantSend asset lock proof is used for transactions that have received an InstantSend lock.

| Field | Type | Description|
| - | - | - |
| type | integer | The asset lock proof type (`0` for InstantSend locks) |
| instantLock | array of bytes | The InstantSend lock ([`islock`](https://dashcore.readme.io/docs/core-ref-p2p-network-instantsend-messages#islock)) |
| transaction | array of bytes | The asset lock transaction |
| outputIndex | integer | Index of the transaction output to be used |

Asset locks using an InstantSend lock as proof must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/schema/identity/stateTransition/assetLockProof/instantAssetLockProof.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "type": {
      "type": "integer",
      "const": 0
    },
    "instantLock": {
      "type": "array",
      "byteArray": true,
      "minItems": 165,
      "maxItems": 100000
    },
    "transaction": {
      "type": "array",
      "byteArray": true,
      "minItems": 1,
      "maxItems": 100000
    },
    "outputIndex": {
      "type": "integer",
      "minimum": 0
    }
  },
  "additionalProperties": false,
  "required": [
    "type",
    "instantLock",
    "transaction",
    "outputIndex"
  ]
}
```

### ChainLock Asset Lock Proof

The ChainLock asset lock proof is used for transactions that have note received an InstantSend lock, but have been included in a block that has received a ChainLock.

| Field | Type | Description|
| - | - | - |
| type | array of bytes | The type of asset lock proof (`1` for ChainLocks) |
| coreChainLockedHeight | integer | Height of the ChainLocked Core block containing the transaction  |
| outPoint | object | The  [outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#outpoint) being used as the asset lock |

Asset locks using a ChainLock as proof must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/schema/identity/stateTransition/assetLockProof/chainAssetLockProof.json):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "type": {
      "type": "integer",
      "const": 1
    },
    "coreChainLockedHeight":  {
      "type": "integer",
      "minimum": 1,
      "maximum": 4294967295
    },
    "outPoint": {
      "type": "array",
      "byteArray": true,
      "minItems": 36,
      "maxItems": 36
    }
  },
  "additionalProperties": false,
  "required": [
    "type",
    "coreChainLockedHeight",
    "outPoint"
  ]
}
```

## Identity State Transition Signing

**Note:** The identity create and topup state transition signatures are unique in that they must be signed by the private key used in the layer 1 locking transaction. All other state transitions will be signed by a private key of the identity submitting them.

The process to sign an identity create state transition consists of the following steps:

1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature`
2. Sign the encoded data with private key associated with a lock transaction public key
3. Set the state transition `signature` to the value of the signature created in the previous step

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

The platform protocol performs several forms of validation related to identities: model validation, basic validation, and state validation.

 - Model validation - ensures object models are correct
 - State transition basic validation - only checks the content of the state transition
 - State transition state validation - takes the overall platform state into consideration

**Example:** An identity create state transition for an existing identity could pass basic validation; however, it would fail state validation since the identity already exists.

## Identity Model

The identity model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/integration/identity/validation/validateIdentityFactory.spec.js). The test output below shows the necessary criteria:

```text
Identity
validateIdentityFactory
  ✔ should return valid result if a raw identity is valid
  ✔ should return valid result if an identity model is valid
  protocolVersion
    ✔ should be present
    ✔ should be an integer
    ✔ should be valid
  id
    ✔ should be present
    ✔ should be a byte array
    ✔ should not be less than 32 bytes
    ✔ should not be more than 32 bytes
  balance
    ✔ should be present
    ✔ should be an integer
    ✔ should be greater or equal 0
  publicKeys
    ✔ should be present
    ✔ should be an array
    ✔ should not be empty
    ✔ should be unique
    ✔ should throw an error if publicKeys have more than 100 keys
  revision
    ✔ should be present
    ✔ should be an integer
    ✔ should be greater or equal 0
```

## Public Key Model

The public key model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/integration/identity/validation/validatePublicKeysFactory.spec.js). The test output below shows the necessary criteria:

```text
PublicKeys
validatePublicKeysFactory
  ✔ should return invalid result if there are duplicate key ids
  ✔ should return invalid result if there are duplicate keys
  ✔ should return invalid result if key data is not a valid DER
  ✔ should return invalid result if key has an invalid combination of purpose and security level
  ✔ should pass valid public keys
  id
    ✔ should be present
    ✔ should be a number
    ✔ should be an integer
    ✔ should be greater or equal to one
  type
    ✔ should be present
    ✔ should be a number
  data
    ✔ should be present
    ✔ should be a byte array
    ECDSA_SECP256K1
      ✔ should be no less than 33 bytes
      ✔ should be no longer than 33 bytes
    BLS12_381
      ✔ should be no less than 48 bytes
      ✔ should be no longer than 48 bytes
```

## State Transition Basic

Basic validation verifies that the content of state transition fields complies with the requirements for the field.

### Identity Create Basic

The identity fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/integration/identity/stateTransition/IdentityCreateTransition/validation/basic/validateIdentityCreateTransitionBasicFactory.spec.js). The test output below shows the necessary criteria:

```text
validateIdentityCreateTransitionBasicFactory
  ✔ should return valid result
  protocolVersion
    ✔ should be present
    ✔ should be an integer
    ✔ should be valid
  type
    ✔ should be present
    ✔ should be equal to 2
  assetLockProof
    ✔ should be present
    ✔ should be an object
    ✔ should be valid
  publicKeys
    ✔ should be present
    ✔ should not be empty
    ✔ should not have more than 10 items
    ✔ should be unique
    ✔ should be valid
    ✔ should have at least 1 master key
  signature
    ✔ should be present
    ✔ should be a byte array
    ✔ should be not shorter than 65 bytes
    ✔ should be not longer than 65 bytes
```

### Identity TopUp Basic

The identity topup fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/integration/identity/stateTransition/IdentityTopUpTransition/validation/basic/validateIdentityTopUpTransitionBasicFactory.spec.js). The test output below shows the necessary criteria:

```text
validateIdentityTopUpTransitionBasicFactory
  ✔ should return valid result
  protocolVersion
    ✔ should be present
    ✔ should be an integer
    ✔ should be valid
  type
    ✔ should be present
    ✔ should be equal to 3
  assetLockProof
    ✔ should be present
    ✔ should be an object
    ✔ should be valid
  identityId
    ✔ should be present
    ✔ should be a byte array
    ✔ should be no less than 32 bytes
    ✔ should be no longer than 32 bytes
  signature
    ✔ should be present
    ✔ should be a byte array
    ✔ should be not shorter than 65 bytes
    ✔ should be not longer than 65 bytes
```

## Asset Lock Basic

The asset lock fields must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/tree/v0.22.0/packages/js-dpp/test/integration/identity/stateTransition/assetLockProof). The specific tests are dependent on the type of proof as shown in the sections below.

### InstantSend Asset Lock Proof Basic

The InstantSend asset lock proof fields must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/integration/identity/stateTransition/assetLockProof/instant/validateInstantAssetLockProofStructureFactory.spec.js). The test output below shows the necessary criteria:

```text
validateInstantAssetLockProofStructureFactory
  ✔ should return valid result
  type
    ✔ should be present
    ✔ should be equal to 0
  instantLock
    ✔ should be present
    ✔ should be a byte array
    ✔ should not be shorter than 160 bytes
    ✔ should not be longer than 100 Kb
    ✔ should be valid
    ✔ should lock the same transaction
    ✔ should have valid signature
  transaction
    ✔ should be present
    ✔ should be a byte array
    ✔ should not be shorter than 1 byte
    ✔ should not be longer than 100 Kb
    ✔ should should be valid
  outputIndex
    ✔ should be present
    ✔ should be an integer
    ✔ should not be less than 0
```

### ChainLock Asset Lock Proof Basic

The ChainLock asset lock proof fields must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/integration/identity/stateTransition/assetLockProof/chain/validateChainAssetLockProofStructureFactory.spec.js). The test output below shows the necessary criteria:

```text
validateChainAssetLockProofStructureFactory
  ✔ should return valid result
  type
    ✔ should be present
    ✔ should be equal to 1
  coreChainLockedHeight
    ✔ should be preset
    ✔ should be an integer
    ✔ should be a number
    ✔ should be greater than 0
    ✔ should be less than 4294967296
    ✔ should be less or equal to consensus core height
  outPoint
    ✔ should be present
    ✔ should be a byte array
    ✔ should not be shorter than 36 bytes
    ✔ should not be longer than 36 bytes
    ✔ should point to existing transaction
    ✔ should point to valid transaction
    ✔ should point to transaction from block lower than core chain locked height
```

## State Transition State

State validation verifies that the data in the state transition is valid in the context of the current platform state.

### Identity Create State

The identity create state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/unit/identity/stateTransition/IdentityCreateTransition/validation/state/validateIdentityCreateTransitionStateFactory.spec.js). The test output below shows the necessary criteria:

```text
validateIdentityCreateTransitionStateFactory
  ✔ should return invalid result if identity already exists
  ✔ should return valid result if state transition is valid
```

### Identity TopUp State

The identity topup state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/platform/blob/v0.22.0/packages/js-dpp/test/unit/identity/stateTransition/IdentityTopUpTransition/validation/state/validateIdentityTopUpTransitionStateFactory.spec.js). The test output below shows the necessary criteria:

```text
validateIdentityTopUpTransitionStateFactory
  ✔ should return valid result
```

**Note:** Additional validation rules may be added in future versions.
