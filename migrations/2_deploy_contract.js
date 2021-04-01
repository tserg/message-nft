var MessageNFT = artifacts.require("Message")

module.exports = function(deployer) {
    deployer.deploy(MessageNFT, 'Immutable Message Version 0', 'IMESSAGE0');
};
