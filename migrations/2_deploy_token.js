const Token = artifacts.require("Token");

module.exports = function (deployer) {
  deployer.deploy(Token, 1000000000, "0x9bC1FE63324Aa8594595a2F6D32c3C59c54d6035");
};
