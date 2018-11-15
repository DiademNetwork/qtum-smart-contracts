const { Readable } = require("stream")
const fs = require("fs")

class MigrationDataStream extends Readable {
  constructor(filename) {
    super({ objectMode: true })

    const migration = fs.readFileSync(filename, 'utf8')

    this.events = JSON.parse(migration)
  }

  _read() {
    if (this.events.length > 0) {
      this.push(this.events.shift())
    } else {
      this.push(null)
    }
  }
}

module.exports = MigrationDataStream
