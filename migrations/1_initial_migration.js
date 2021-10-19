const Migrations = artifacts.require("LotteryTicket");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
