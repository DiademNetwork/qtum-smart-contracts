require('dotenv').config()

const expect = require('chai').expect

const { Qtum } = require('qtumjs')

const bs58 = require('bs58')

describe('Contracts', () => {
  const options = {
    senderAddress: process.env.SENDER_ADDRESS,
    gasLimit: 4000000
  }

  let qtum = null
  let users = null
  let achievements = null
  let rewards = null

  const authorAddress = '360af3ba8bf00e6c4b5177f54b643a330ca3a5a6'
  const sponsorAddress = '63d75a7f8b447c8b911efa14a621bcc422d2dd9c'
  const witnessAddress = '76b1e0325250e4cfc9a24c6478c333cf3e9040e7'
  const authorAccount = 'authorID2'
  const authorName = 'author'
  const sponsorAccount = 'sponsorID2'
  const postLink = 'facebook.com/postid'
  const postContentHash = ''
  const title = 'John is going to publish second chapter of his book'

  before(() => {
    const repo = require('../solar.development.json')
    qtum = new Qtum(process.env.QTUM_RPC_ADDRESS, repo)

    users = qtum.contract('contracts/Users.sol')
    achievements = qtum.contract('contracts/Achievements.sol')
    rewards = qtum.contract('contracts/Rewards.sol')
  })

  describe('Sponsors support author of book for publishing new chapters', function () {
    this.timeout(123123)

    it('test', async () => {
      const response = await qtum.rawCall('getwalletinfo')

      console.log(JSON.stringify(response))
    })

    it('author can verify his identity with profile in facebook', async () => {
      const tx = await users.send('register', [authorAddress, authorAccount, authorName], options)

      await tx.confirm(1)

      console.log(`${authorAccount} => ${authorAddress} at ${tx.txid}`)
    })

    it('author should have his identity verified', async () => {
      const tx1 = await users.call('getAccountByAddress', [authorAddress])
      const account = tx1.outputs[0]

      const tx2 = await users.call('exists', [authorAddress])
      const exists = tx2.outputs[0]

      expect(account).to.be.not.equal('')
      expect(exists).to.be.equal(true)
    })

    it('achievement should be created with by author', async () => {
      const tx = await achievements.call('getAchievementCreatorRaw', [postLink])
      const creator = tx.outputs[0]

      expect(creator).to.be.equal(authorAddress)
    })

    it('author can create achievement with link to the post with published chapter', async () => {
      const tx = await achievements.send('createFrom', [authorAddress, postLink, postContentHash, title, ''], options)

      await tx.confirm(1)

      console.log(`${authorAddress} => ${title} at ${tx.txid}`)
    })

    it('achievement should be created with by author', async () => {
      const tx = await achievements.call('getAchievementCreatorRaw', [postLink])
      const creator = tx.outputs[0]

      expect(creator).to.be.equal(authorAddress)
    })

    it('sponsor can send funds to author if he likes published chapter', async () => {
      const tx = await rewards.send('support', [postLink], { senderAddress: options.senderAddress, value: 10 })

      await tx.confirm(1)

      console.log(`${options.senderAddress} sent funds for ${postLink} at ${tx.txid}`)
    })

    it('sponsor can create reward that will be available when witness will confirm achievement', async () => {
      const tx = await rewards.send('deposit', [postLink, witnessAddress], { senderAddress: options.senderAddress, value: 20 })

      await tx.confirm(1)

      console.log(`${options.senderAddress} => ${postLink} when ${witnessAddress} at ${txid}`)
    })

    it('reward should be created by sponsor and associated with witness', async () => {
      const tx = await rewards.call('getRewardAmount', [postLink, witnessAddress])
      const amount = tx.outputs[0]

      expect(amount).to.be.equal(20)
    })

    it('anyone can witness that achievement was accomplished', async () => {
      const tx = await achievements.send('confirmFrom', [witnessAddress, postLink], options)

      await tx.confirm(1)

      console.log(`${witnessAddress} has confirmed accomplishment of ${postLink}`)
    })

    it('achievement should be confirmed by witness', async () => {
      const tx = await achievements.call('confirmedByRaw', [postLink, witnessAddress], options)
      const confirmed = tx.outputs[0]

      expect(confirmed).to.be.equal(true)
    })

    it('anyone can initiate withdrawal of funds when specific witness has confirmed accomplishment of achievement', async () => {
      const tx = await rewards.send('withdraw', [postLink, witnessAddress], options)

      await tx.confirm(1)

      console.log(`someone initiated withrawal associated with ${witnessAddress} for ${postLink}`)
    })

    it('deposit should be withdrawn to creator of achievement', async () => {
      const tx = await rewards.call('getRewardAmount', [postLink, witnessAddress])
      const amount = tx.outputs[0]

      expect(amount).to.be.equal(0)
    })
  })

  describe('Migration', function() {
    it('should allow to migrate support transactions', async () => {
      const tx = await rewards.send('supportMigrate', [postLink, options.senderAddress], { senderAddress: options.senderAddress, value: 10 })

      await tx.confirm(1)

      console.log(`${options.senderAddress} sent funds for ${postLink} at ${tx.txid}`)
    })

    it('should allow to migrate deposit transactions', async () => {
      const tx = await rewards.send('depositMigrate', [postLink, witnessAddress, options.senderAddress], { senderAddress: options.senderAddress, value: 20 })

      await tx.confirm(1)

      console.log(`${options.senderAddress} => ${postLink} when ${witnessAddress} at ${txid}`)
    })
  })
})
