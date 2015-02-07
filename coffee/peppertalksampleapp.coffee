express = require 'express'
errorHandler = require('errorhandler')
crypto = require('crypto')
#
#
app = express()
app.use(errorHandler())
app.use('/app', express.static(__dirname + '/../www/'))
app.use('/bower_components', express.static(__dirname + '/../bower_components'))
#
app.get '/', (req, res) ->
  res.redirect("/app")
#
app.get('/api/v1/user', (req, res, next) ->
  return res.status(200).json(req.user)
)
#
#
# SSO redirect to PepperTalk
#
pepperTalkClientId = process.env.PEPPERTALK_CLIENT_ID 
pepperTalkSecret = process.env.PEPPERTALK_SECRET 
app.get('/api/v1/peppertalk_sso', (req, res, next) ->
  shasum = crypto.createHash('sha1')
  timestamp = Date.now()
  shasum.update(pepperTalkClientId + ":" + pepperTalkSecret + ":" + timestamp + ":" + req.query.email)
  sso_token = shasum.digest('hex')
  return res.status(200).json({
    grant_type: 'sso'
    client_id: pepperTalkClientId
    timestamp: timestamp
    username: req.query.email
    sso_token: sso_token
  })
)
#
server = app.listen process.env.PORT || 8282, ->
  host = server.address().address
  port = server.address().port
  