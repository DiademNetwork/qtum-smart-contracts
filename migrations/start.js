require('dotenv').config()

const MigrationDataStream = require('./MigrationDataStream')
const MigrationApplyStream = require('./MigrationApplyStream')

const { Qtum } = require('qtumjs')

const repo = require('../solar.development.json')
const qtum = new Qtum(process.env.QTUM_RPC_ADDRESS, repo)

const users = qtum.contract('contracts/Users.sol')
const achievements = qtum.contract('contracts/Achievements.sol')
const rewards = qtum.contract('contracts/Rewards.sol')

const options = {
  senderAddress: process.env.SENDER_ADDRESS,
  gasLimit: 4000000
};

(new MigrationDataStream('migration.json'))
  .pipe(new MigrationApplyStream({ users, achievements, rewards, options }))
