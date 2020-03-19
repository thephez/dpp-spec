# Raw Data Contract Interface

Defined in [https://github.com/dashevo/js-dpp/blob/master/lib/dataContract/RawDataContractInterface.js](https://github.com/dashevo/js-dpp/blob/master/lib/dataContract/RawDataContractInterface.js)

| Property | Type | Required | Description |
| - | - | - | - |
| $schema | string | Yes  | (a valid URL)
| $contractId | string | Yes | Identity that registered the data contract defining the document (Base58, 42-44 characters) |
| ~~version~~ | ~~integer~~ | ~~Yes~~ | ~~Data Contract version (>= 1)~~ Removed by [https://github.com/dashevo/js-dpp/pull/128/](https://github.com/dashevo/js-dpp/pull/128) |
| documents | Object | Yes | Document definitions (see Documents for details) |
| definitions | Object | No | Definitions for `$ref` references used in the `documents` object (if present, must be a non-empty object with <= 100 valid properties) |
