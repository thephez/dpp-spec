# Dash Platform Protocol Specification v0.20.x

## Introduction

The Dash Platform Protocol (DPP) specification defines a protocol for the data objects (e.g.  data contracts, documents, state transitions) that can be stored on [Dash's layer 2 platform](https://dashplatform.readme.io/docs/introduction-what-is-dash-platform). All data stored on Dash platform is governed by DPP to ensure data consistency and integrity is maintained.

Dash platform data objects consist of JSON and are validated using the JSON-Schema specification via pre-defined JSON-Schemas and meta-schemas described in this specification. The meta-schemas allow for creation of DPP-compliant schemas which define fields for third-party Dash Platform applications.

In addition to ensuring data complies with predefined JSON Schemas, DPP also defines rules for hashing and serialization of these objects.

## Reference Implementation

The current reference implementation is the (JavaScript) [js-dpp](https://github.com/dashevo/js-dpp) library. The schemas and meta-schemas referred to in this specification can be found here in the reference implementation: https://github.com/dashevo/js-dpp/tree/master/schema.

## Outline

[Identities](docs/identity.md)

 - [Create](docs/identity.md#identity-creation)
 - [TopUp](docs/identity.md#identity-topup)

[Data Contracts](docs/data-contract.md)

 - [Documents](docs/document.md#document-overview)
   - [Properties](docs/document.md#document-properties)
   - [Indices](docs/document.md#document-indices)
 - [Definitions](docs/document.md#definition-overview)

[State Transitions](docs/state-transition.md)

 - [Overview / general structure](docs/state-transition.md)
 - Types
   - [Identity Create ST](docs/identity.md#identity-creation)
   - [Data Contract ST](docs/data-contract.md#data-contract-creation)
   - [Document Batch ST](docs/document.md#document-submission)
     - Document Transitions
       - [Document Transition Base](docs/document.md#document-base-transition)
       - [Document Create Transition](docs/document.md#document-create-transition)
       - [Document Replace Transition](docs/document.md#document-replace-transition)
       - [Document Delete Transition](docs/document.md#document-delete-transition)
 - [Signing](docs/state-transition.md#state-transition-signing)

[Data Triggers](docs/data-trigger.md)

Serialization

 - Base 64
 - Canonical CBOR

Hashing

Validation

 - JSON-Schema
 - Logic
