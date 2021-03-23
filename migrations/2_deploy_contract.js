var MessageNFT = artifacts.require("Message")

module.exports = function(deployer) {
    deployer.deploy(MessageNFT);
};
