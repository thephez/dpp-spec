# Dash Platform Protocol Specification v0.22.x (Draft)

## Introduction

The Dash Platform Protocol (DPP) specification defines a protocol for the data
objects (e.g.  data contracts, documents, state transitions) that can be stored
on [Dash's layer 2
platform](https://dashplatform.readme.io/docs/introduction-what-is-dash-platform).
All data stored on Dash platform is governed by DPP to ensure data consistency
and integrity is maintained.

Dash platform data objects consist of JSON and are validated using the
JSON-Schema specification via pre-defined JSON-Schemas and meta-schemas
described in this specification. The meta-schemas allow for creation of
DPP-compliant schemas which define fields for third-party Dash Platform
applications.

In addition to ensuring data complies with predefined JSON Schemas, DPP also
defines rules for hashing and serialization of these objects.

## Reference Implementation

The current reference implementation is the (JavaScript)
[js-dpp](https://github.com/dashevo/platform/tree/master/packages/js-dpp) library. The schemas and
meta-schemas referred to in this specification can be found here in the
reference implementation: https://github.com/dashevo/platform/tree/master/packages/js-dpp/schema.

## Outline

[Identities](identity.md)

 - [Create](identity.md#identity-creation)
 - [TopUp](identity.md#identity-topup)

[Data Contracts](data-contract.md)

 - [Documents](data-contract.md#data-contract-documents)
   - [Properties](data-contract.md#document-properties)
   - [Indices](data-contract.md#document-indices)
 - [Definitions](data-contract.md#data-contract-definitions)

[Document](document.md)

[State Transitions](state-transition.md)

 - [Overview / general structure](state-transition.md)
 - Types
   - [Identity Create ST](identity.md#identity-creation)
   - [Data Contract ST](data-contract.md#data-contract-creation)
   - [Document Batch ST](document.md)
     - Document Transitions
       - [Document Transition Base](document.md#document-base-transition)
       - [Document Create Transition](document.md#document-create-transition)
       - [Document Replace Transition](document.md#document-replace-transition)
       - [Document Delete Transition](document.md#document-delete-transition)
 - [Signing](state-transition.md#state-transition-signing)

[Data Triggers](data-trigger.md)
