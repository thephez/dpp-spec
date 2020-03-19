# Data Contract Overview

Data contracts define the schema (structure) of data an application will store on Dash Platform. Contracts are described using [JSON Schema](https://json-schema.org/understanding-json-schema/) which allows the platform to validate the contract-related data submitted to it.

The following sections provide details that developers need to construct valid contracts: [documents](document.md#document-overview) and [definitions](document.md#definition-overview). All data contracts must define one or more documents, whereas definitions are optional and may not be used for simple contracts.

# General Constraints

**Note:** There are a variety of constraints currently defined for performance and security reasons. The following constraints are applicable to all aspects of data contracts. Unless otherwise noted, these constraints are defined in the platform's JSON Schema rules (e.g. [js-dpp data contract meta schema](https://github.com/dashevo/js-dpp/blob/v0.11.1/schema/meta/data-contract.json)).

## Keyword

| Keyword | Constraint |
| - | - |
| `default` | Restricted - cannot be used (defined in DPP logic) |
| `propertyNames` | Restricted - cannot be used (defined in DPP logic) |
| `uniqueItems: true` | `maxItems` must be defined (maximum: 100000) |
| `pattern: <something>` | `maxLength` must be defined (maximum: 50000) |
| `format: <something>` | `maxLength` must be defined (maximum: 100000) |
| `$ref: <something>` | `$ref` can only reference `definitions` - <br> remote references not supported |

## Data Size
Additionally, there are several constraints limiting the overall size of data contracts and related data as defined here:

**Note:** These constraints are defined in the Dash Platform Protocol logic (not in JSON Schema).

| Description | Constraint |
| - | - |
| Maximum size of serialized data contract | 15 KB (https://github.com/dashevo/js-dpp/pull/117) |
| Maximum size of CBOR-encoded data | [16 KB](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/util/serializer.js#L5) (https://github.com/dashevo/js-dpp/pull/114) |




# Raw Data Contract Interface

Defined in [https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/dataContract/RawDataContractInterface.js](https://github.com/dashevo/js-dpp/blob/v0.11.1/lib/dataContract/RawDataContractInterface.js)

| Property | Type | Required | Description |
| - | - | - | - |
| $schema | string | Yes  | (a valid URL)
| $contractId | string | Yes | Identity that registered the data contract defining the document (Base58, 42-44 characters) |
| version | integer | Yes | Data Contract version (>= 1) (remove in 0.12 - see [https://github.com/dashevo/js-dpp/pull/128/](https://github.com/dashevo/js-dpp/pull/128)) |
| documents | Object | Yes | Document definitions (see Documents for details) |
| definitions | Object | No | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with <= 100 valid properties) |
