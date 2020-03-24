# Identity Overview
Identities are a low-level construct that provide the foundation for user-facing functionality on the platform. An identity is a public key (or set of public keys) recorded on the platform chain that can be used to prove ownership of data.

Identities consist of three components that are described in further detail in following sections:

| Field | Type | Description|
| - | - | - |
| id | string | The identity id |
| type | integer | Type of identity (`user` or `application`) |
| publicKeys | array of keys | Public key(s) associated with the identity |

## Identity id

The identity `id` is calculated by Base58 encoding the double sha256 hash of the output used to fund the identity creation.

`id = base58(sha256(sha256(<identity create funding output>)))`

### Example id creation
```javascript
// From the JavaScript reference implementation (js-dpp)
// IdentityCreateTransition.js
    this.identityId = bs58.encode(
      hash(Buffer.from(lockedOutPoint, 'base64')),
    );
```

## Identity type

**Note:** Identity types will be deprecated in a future release

Identities are separated into multiple types depending on their purpose.

| Value | Identity Type | Description |
| :-: | :-: | - |
| 1 | User | Standard identity type for using the platform |
| 2 | Application | Used to register data contracts |
| 3 -<br>32767 | N/A | Reserved |

## Identity publicKeys

The identity `publicKeys` array stores information regarding each public key associated with the identity. Each identity must have at least one public key.

Each item in the `publicKeys` array consists an object containing:

| Field | Type | Description|
| - | - | - |
| id | integer | The key id (=> 1, unique among keys in `publicKeys` array) |
| type | integer | Type of key (default: 1 - ECDSA) |
| data | string (base64) | Public key |
| isEnabled | boolean | Status of key |

### Public Key `id`

Each public key in an identity's `publicKeys` array must be assigned a unique index number (`id`).

**Note:** In the current implementation, each `id` must be `=> 1`. In future releases, indexing may change to begin at `0` instead of `1`.

### Public Key `type`

The `type` field indicates the algorithm used to derive the key.

| Type | Description |
| :-: | - |
| 1 | ECDSA (default) |
| 2 | BLS |

### Public Key `data`

The `data` field contains the compressed public key encoded as base64.

#### Example data encode/decode

**Encode**
```javascript
// From the JavaScript reference implementation (js-dpp)
// AbstractStateTransition.js
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


# Identity Registration

Identities are registered on the platform by submitting the identity information in an identity create state transition.

| Field | Type | Description|
| - | - | - |
| protocolVersion | integer | The platform protocol version (currently `0`) |
| type | integer | State transition type (`3` for identity create) |
| lockedOutPoint | string | Lock [outpoint]([https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint](https://dashcore.readme.io/docs/core-additional-resources-glossary#section-outpoint)) from the layer 1 locking transaction |
| identityType | integer | [Type of identity](#identity-type) |
| publicKeys | array of keys | [Public key(s)](#identity-publickeys) associated with the identity |
| signaturePublicKeyId | number | The `id` of the public key that signed the state transition (not part of the identity create state transition) |
| signature | string | Signature of state transition data |

**Note:** The lock transaction that creates the `lockedOutPoint` is not covered in this document. The preliminary design simply uses an `OP_RETURN` output.

**Example State Transition**

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
1. Canonical CBOR encode the state transition data - this include all ST fields except the `signature` and `signaturePublicKeyId`
2. Sign the encoded data with private key associated with a lock transaction public key
3. Set the state transition `signature` to the base64 encoded value of the signature created in the previous step
4. Set the state transition`signaturePublicKeyId` to the [public key `id`](#public-key-id) corresponding to the key used to sign

### Code snipits related to signing
```javascript
// From js-dpp
// AbstractStateTransition.js
// Serialize encodes the object (excluding the signature-related fields) with canonical CBOR
const data = this.serialize({ skipSignature: true });
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

# Non-implemented topics
 - Balance
 - Topup
 - Update/Reset Key/Close Id
 - Recovery mechanisms
