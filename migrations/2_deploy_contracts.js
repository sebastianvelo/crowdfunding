//2_deploy_contracts.js
const CrowdFunding = artifacts.require("CrowdFunding"); //Instancia de nuestro contrato CrowdFunding.sol

module.exports = function (deployer) {
  deployer.deploy(CrowdFunding); //Este script hace deploy de nuestro contrato a la blockchain
};