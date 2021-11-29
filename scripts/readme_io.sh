find docs/ -type f -name '*.md' -exec sed -i -e 's/(data-contract.md#/(platform-protocol-reference-data-contract#/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(data-trigger.md#/(platform-protocol-reference-data-trigger#/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(document.md#/(platform-protocol-reference-document#/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(identity.md#/(platform-protocol-reference-identity#/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(state-transition.md#/(platform-protocol-reference-state-transition#/' {} +

find docs/ -type f -name '*.md' -exec sed -i -e 's/(data-contract.md)/(platform-protocol-reference-data-contract)/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(data-trigger.md)/(platform-protocol-reference-data-trigger)/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(document.md)/(platform-protocol-reference-document)/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(identity.md)/(platform-protocol-reference-identity)/' {} +
find docs/ -type f -name '*.md' -exec sed -i -e 's/(state-transition.md)/(platform-protocol-reference-state-transition)/' {} +
