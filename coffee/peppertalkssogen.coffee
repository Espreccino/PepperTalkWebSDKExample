crypto = require('crypto')
fs = require("fs")
argv = require("minimist")(process.argv.slice(2), {
  string: ["user_id", "client_secret", "client_id", "host", "protocol", "file"] 
  default: {
    host: "hostedpepper.getpeppertalk.com"
    protocol: "https"
    file: "/tmp/pepperkit_sso.json"
  }
})
#
shasum = crypto.createHash('sha1')
timestamp = Date.now()
shasum.update(argv.client_id + ":" + argv.client_secret + ":" + timestamp + ":" + argv.user_id)
sso_token = shasum.digest('hex')
sso_grant = {
  grant_type: 'sso'
  client_id: argv.client_id
  timestamp: timestamp
  username: argv.user_id
  sso_token: sso_token
}
console.log(sso_grant)
fs.writeFileSync(argv.file, JSON.stringify(sso_grant, null, 4))