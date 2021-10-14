const Migrations = artifacts.require("LotteryPool");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
