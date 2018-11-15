const { Writable } = require("stream")

class MigrationApplyStream extends Writable {
  constructor({ users, achievements, rewards, options }) {
    super({ objectMode: true })

    this.users = users
    this.achievements = achievements
    this.rewards = rewards
    this.options = options

    this.eventHandlers = {
      'Create': this.createAchievement.bind(this),
      'Update': this.updateAchievement.bind(this),
      'Confirm': this.confirmAchievement.bind(this),
      'Support': this.supportAchievement.bind(this),
      'Deposit': this.depositReward.bind(this),
      'Withdraw': this.withdrawReward.bind(this),
      'Register': this.registerUser.bind(this)
    }
  }

  async registerUser(event) {
    const { _userAddress, _userAccount, _userName } = event

    const tx = await this.users.send('register', [_userAddress, _userAccount, _userName], this.options)
    console.log(tx.txid)
  }

  async createAchievement(event) {
    const { wallet, object, title, contentHash } = event

    const tx = await this.achievements.send('createFrom', [wallet, object, contentHash, title, ''], this.options)
    console.log(tx.txid)
  }

  async updateAchievement(event) {
    const { wallet, object, title, contentHash, previousLink } = event

    const tx = await this.achievements.send('createFrom', [wallet, object, contentHash, title, previousLink], this.options)
    console.log(tx.txid)
  }

  async confirmAchievement(event) {
    const { wallet, object, user } = event

    const tx = await this.achievements.send('confirmFrom', [user, object], this.options)
    console.log(tx.txid)
  }

  async supportAchievement(event) {
    const { wallet, object, user, amount } = event

    const tx = await this.rewards.send('supportMigrate', [object, user], { senderAddress: this.options.senderAddress, value: amount })
    console.log(tx.txid)
  }

  async depositReward(event) {
    const { wallet, object, user, amount, witness } = event

    const tx = await this.rewards.send('depositMigrate', [object, witness, user], { senderAddress: this.options.senderAddress, value: amount })
    console.log(tx.txid)
  }

  async withdrawReward(event) {
    const { wallet, object, amount, witness } = event

    const tx = await this.rewards.send('withdraw', [object, witness], this.options)
    console.log(tx.txid)
  }

  async _write(event, encoding, callback) {
    if (event._eventName) {
      const eventName = event._eventName

      if (this.eventHandlers[eventName]) {
        await this.eventHandlers[eventName](event)
      }

      console.log(eventName)
    }
    callback()
  }
}

module.exports = MigrationApplyStream
