module.exports = {
  "root": true,
  "globals": {
    "assert": true,
    "beforeEach": true,
    "it": true,
    "xit": true,
    "BigInt": true,
    "artifacts": true,
    "web3": true,
    "contract": true,
  },
  "extends": "eslint-config-node-strict",
  'plugins': [
    'import'
  ],
  rules: {
    'import/no-unresolved': 2,
    'import/named': 2,
    'import/default': 2,
    'import/no-duplicates': 2,
  }
};
