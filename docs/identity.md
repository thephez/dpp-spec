# Identity Overview

Identities are a low-level construct that provide the foundation for user-facing functionality on the platform. An identity is a public key (or set of public keys) recorded on the platform chain that can be used to prove ownership of data. Please see the [Identity DIP](https://github.com/dashpay/dips/blob/master/dip-0011.md) for additional information.

Identities consist of three components that are described in further detail in following sections:

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The identity version |
| id | array of bytes | The identity id (32 bytes) |
| publicKeys | array of keys | Public key(s) associated with the identity |
| balance | integer | Credit balance associated with the identity |
| revision | integer | Identity update revision |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/schema/identity/identity.json):

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
  "protocolVersion": 0,
  "id": "4ZJsE1Yg8AosmC4hAeo3GJgso4N9pCoa6eCTDeXsvdhn",
  "publicKeys": [
    {
      "id": 0,
      "type": 0,
      "data": "Ao57Lp0174Svimn3OW+JUxOu/JhjhgRjBWzx9Gu/hyjo"
    }
  ],
  "balance": 0,
  "revision": 0
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

**Note:** The identity `id` uses the Dash Platform specific `application/x.dash.dpp.identifier` content media type. For additional information, please refer to the [js-dpp PR 252](https://github.com/dashevo/js-dpp/pull/252) that introduced it and [Identifier.js](https://github.com/dashevo/js-dpp/blob/v0.19.1/lib/identifier/Identifier.js).

## Identity publicKeys

The identity `publicKeys` array stores information regarding each public key associated with the identity. Each identity must have at least one public key.

**Note:** As of Dash Platform Protocol [version 0.16](https://github.com/dashevo/js-dpp/pull/234), any public key(s) assigned to an identity must be unique (not already used by any identity). Prior versions checked (at most) the first key only.

Each item in the `publicKeys` array consists an object containing:

| Field | Type | Description|
| - | - | - |
| id | integer | The key id (all public keys must be unique) |
| type | integer | Type of key (default: 0 - ECDSA) |
| data | array of bytes | Public key (ECDSA: 33 bytes; BLS: 48 bytes) |

**Note:** the `isEnabled` field was removed in [version 0.16](https://github.com/dashevo/js-dpp/pull/236).

Each identity public key must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/schema/identity/publicKey.json):

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
      "type": "array",
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
            "minItems": 33,
            "maxItems": 33
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
            "minItems": 48,
            "maxItems": 48
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

## Identity balance

Each identity has a balance of credits established by value locked via a layer 1 lock transaction. This credit balance is used to pay the fees associated with state transitions.

# Identity State Transition Details

There are two identity-related state transitions: [identity create](#identity-creation) and [identity topup](#identity-topup). Details are provided in this section including information about [asset locking](#asset-lock) and [signing](#identity-state-transition-signing) required for both state transitions.

## Identity Creation

Identities are created on the platform by submitting the identity information in an identity create state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The identity create protocol version (currently `0`) |
| type | integer | State transition type (`2` for identity create) |
| assetLock | object | [Asset lock object](#asset-lock) proving the layer 1 locking transaction exists and is locked |
| publicKeys | array of keys | [Public key(s)](#identity-publickeys) associated with the identity |
| signature | array of bytes | Signature of state transition data (65 bytes) |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/schema/identity/stateTransition/identityCreate.json):

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
    "assetLock": {
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
    "assetLock",
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
  "signature": "IO15T6RCXSH2qHEYYBinXy8n+/E8AhEqNRFngPrxoZ+WT9Y4dF89uuUgzfTsK+L0FiTg6JQynk32IhII4XdBfLg=",
  "assetLock": {
    "transaction": "03000000011dc6578c8c60d1fa1e5ed3d9581a8028b2e9b08b1b8cd3d9535c56b69c77c743010000006a473044022063532c0f1cddc1dfcde853350204a44e747c9c575b2aa5d301fab633e69b28420220617c60520a0125d219c50000b24402adf01f9cfe81ea8996f5996cf2efb86d710121027369081c5d755fe493f1019c48911d2b0e2571d4c9a175e0a2620ccc7ad790a4ffffffff021027000000000000166a1445e54b74b591b28cde362b693186faf7ad2909ca905ce60e000000001976a914b07d21cb4aab2d4cd5fd2f636490bb4182fd2f6188ac00000000",
    "outputIndex": 0,
    "proof": {
      "type": 0,
      "instantLock": "AR3GV4yMYNH6Hl7T2VgagCiy6bCLG4zT2VNcVracd8dDAQAAAJirJim2+gA55+jG99faJMObo/kQtVkY+G6LBk6eNPOiDbqp+g4Tf735y3gm/ykFmZKxM5Q+kZn3pe4bPQCu8V4E6bKrhDUE80ZMSavYcGHXF86oSeeoqgejvs3wQlrntbxg3j5x8rZvF0CYJAzXgrF6N4IcGotA7gxE/HYOgJEU"
    }
  },
  "publicKeys": [
    {
      "id": 0,
      "type": 0,
      data: "AslQmm/K+kjV5GcUudY4GsAvcTd+v/4dE2G740AFdPeN"
    }
  ]
}
```

## Identity TopUp

Identity credit balances are increased by submitting the topup information in an identity topup state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The identity topup protocol version (currently `0`) |
| type | integer | State transition type (`3` for identity topup) |
| assetLock | object | [Asset lock object](#asset-lock) proving the layer 1 locking transaction exists and is locked |
| identityId | array of bytes | An [Identity ID](#identity-id) for the identity receiving the topup (can be any identity) (32 bytes) |
| signature | array of bytes | Signature of state transition data (65 bytes) |

Each identity must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/schema/identity/stateTransition/identityTopUp.json):

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
    "assetLock": {
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
    "assetLock",
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
  "signature": "IGXSpVuY8hqrfbISrBfFPBtYd3x4O+Jzf6263WMtQluuRsAtLpx3EQKYbsKl6wwRdUuKrtGQkd7KRY7XsuSI9iU=",
  "identityId": "EseVWo8sXWKjvp8VidwT2xBy5q9RHqMbra9iyHJB4uxp",
  "assetLock": {
    "transaction": "030000000198ab2629b6fa0039e7e8c6f7d7da24c39ba3f910b55918f86e8b064e9e34f3a2010000006a47304402203df77552c1e1680c1b91acb91676ad565d80f5a36633ba8139889af6472e35d9022014fdb848a167a31e39f2d12c5c724b2d9ff13dd3d6417ac2a1635a16b51f0e47012102e3aaadeb2800220bad531558888a47d5a03d0bdda21a30823594591d3f177429ffffffff02e803000000000000166a142c9dc681ab0512cd2395daa894d0fd9a8cc7b2e9c054e60e000000001976a914d6c0bedc22dacb338b869bbe77e677cf924702e288ac00000000",
    "outputIndex": 0,
    "proof": {
      "type": 0,
      "instantLock": "AZirJim2+gA55+jG99faJMObo/kQtVkY+G6LBk6eNPOiAQAAAG0TCt0zY6GexLs/NsjCXcyq4kqLgxnr0NWIDgf+FwFqFVNzc06l8lrPywHddUgWYSyUCPUQdsmTiiJgBPLzvpcfWm75wOcYw+4vJUhRxSLBBXfz1PkBeMPySzF9Gnf2Y+83ZsT8AY8UWK4FB/xkEHLkKHQOKtqYtMaCWcYV6j1h"
    }
  }
}
```

## Asset Lock

The [identity create](#identity-creation) and [identity topup](#identity-topup) state transitions both include an asset lock object. This object references includes the layer 1 lock transaction and includes proof that the transaction is locked.

| Field | Type | Description|
| - | - | - |
| transaction | array of bytes | The asset lock transaction |
| outputIndex | integer | Index of the transaction output to be used |
| proof | object | Proof that the transaction is locked via InstantSend or ChainLocks |

Each asset lock object must comply with this JSON-Schema definition established in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.17.0/schema/identity/stateTransition/assetLock/assetLock.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "properties": {
    "transaction": {
      "type": "array",
      "byteArray": true,
      "minItems": 1,
      "maxItems": 100000
    },
    "outputIndex": {
      "type": "integer",
      "minimum": 0
    },
    "proof": {
      "type": "object",
      "properties": {
        "type": {
          "type": "integer",
          "enum": [0]
        }
      },
      "required": ["type"]
    }
  },
  "additionalProperties": false,
  "required": [
    "transaction",
    "outputIndex",
    "proof"
  ]
}
```

### Asset Lock Proof

Currently only InstantSend locks are accepted as proofs.

| Field | Type | Description|
| - | - | - |
| type | integer | The asset lock proof type (`0` for InstantSend locks) |
| instantLock | array of bytes | The InstantSend lock ([`islock`?](https://dashcore.readme.io/docs/core-ref-p2p-network-instantsend-messages#islock)) |

Asset locks using an InstantSend lock as proof must comply with this JSON-Schema definition established in [js-dpp](https://raw.githubusercontent.com/dashevo/js-dpp/v0.17.0/schema/identity/stateTransition/assetLock/proof/instantAssetLockProof.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
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
    }
  },
  "additionalProperties": false,
  "required": [
    "type",
    "instantLock"
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

The platform protocol performs several forms of validation related to identities: model validation, structure validation, and data validation.

 - Model validation - ensures object models are correct
 - State transition structure validation - only checks the content of the state transition
 - State transition data validation - takes the overall platform state into consideration

**Example:** An identity create state transition for an existing identity could pass structure validation; however, it would fail data validation since the identity already exists.

## Identity Model

The identity model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/test/integration/identity/validation/validateIdentityFactory.spec.js). The test output below shows the necessary criteria:

```text
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

The public key model must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/test/integration/identity/validation/validatePublicKeysFactory.spec.js). The test output below shows the necessary criteria:

```text
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

### Identity Create Structure

The identity fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/test/integration/identity/stateTransition/identityCreateTransition/validateIdentityCreateTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```text
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
  assetLockProof
    ✓ should be present
    ✓ should be an object
    ✓ should be valid
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
    ✓ should be valid
```

### Identity TopUp Structure

The identity topup fields are validated in this way and must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/test/integration/identity/stateTransition/identityTopUpTransition/validateIdentityTopUpTransitionStructureFactory.spec.js). The test output below shows the necessary criteria:

```text
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
  assetLockProof
    ✓ should be present
    ✓ should be an object
    ✓ should be valid
  identityId
    ✓ should be present
    ✓ should be a byte array
    ✓ should be no less than 32 bytes
    ✓ should be no longer than 32 bytes
    ✓ should exist
  signature
    ✓ should be present
    ✓ should be a byte array
    ✓ should be not shorter than 65 bytes
    ✓ should be not longer than 65 bytes
    ✓ should be valid
```

## Asset Lock Structure

The asset lock fields must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.17.0/test/integration/identity/stateTransition/assetLock/validateAssetLockStructureFactory.spec.js). The test output below shows the necessary criteria:

```text
  validateAssetLockStructureFactory
    ✓ should return invalid result if proof is not valid
    ✓ should return valid result with public key hash
    transaction
      ✓ should be present
      ✓ should be a byte array
      ✓ should be not shorter than 1 byte
      ✓ should be not longer than 100 Kb
      ✓ should be valid
    outputIndex
      ✓ should be present
      ✓ should be an integer
      ✓ should be not less than 0
      ✓ should point to specific output in transaction
      ✓ should point to output with OR_RETURN
      ✓ should point to output with public key hash
    proof
      ✓ should be present
      ✓ should be an object
      ✓ should return invalid result if asset lock transaction outPoint exists
      type
        ✓ should be present
        ✓ should be equal to 0
```

## InstantSend Asset Lock Proof Structure

The InstantSend asset lock proof fields must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.17-dev/test/integration/identity/stateTransition/assetLock/proof/instant/validateInstantAssetLockProofStructureFactory.spec.js). The test output below shows the necessary criteria:

```text
  validateInstantAssetLockProofStructureFactory
    ✓ should skip signature verification if skipAssetLockProofSignatureVerification passed
    ✓ should return valid result
    type
      ✓ should be present
      ✓ should be equal to 0
    instantLock
      ✓ should be present
      ✓ should be a byte array
      ✓ should be not shorter than 160 bytes
      ✓ should be not longer than 100 Kb
      ✓ should be valid
      ✓ should lock the same transaction
      ✓ should have valid signature
```

## State Transition Data

Data validation verifies that the data in the state transition is valid in the context of the current platform state.

### Identity Create Data

The identity create state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/test/integration/identity/stateTransition/identityCreateTransition/validateIdentityCreateTransitionDataFactory.spec.js). The test output below shows the necessary criteria:

```text
validateIdentityCreateTransitionDataFactory
  ✓ should return invalid result if identity already exists
  ✓ should return invalid result if identity public key already exists
  ✓ should return valid result if state transition is valid
```

### Identity TopUp Data

The identity topup state transition data must pass validation tests as defined in [js-dpp](https://github.com/dashevo/js-dpp/blob/v0.19.1/test/integration/identity/stateTransition/identityTopUpTransition/validateIdentityTopUpTransitionDataFactory.spec.js). The test output below shows the necessary criteria:

```text
validateIdentityTopUpTransitionDataFactory
  ✓ should return valid result
```

**Note:** Additional validation rules may be added in future versions.
