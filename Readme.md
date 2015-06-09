## Pepper Talk Sample App

### Introduction
This is a sample app to demonstrate the JS SDK for Pepper Talk. It contains both the server and the client components. Its built as an Express service for the server and Angular app for the client.

### Quick Start
* git clone *this repo*
* npm install
* bower install
* grunt
* Get the client id and client secret from the Pepper Talk dashboard
* Setup the following environment variables in your shell with client id and client secret

```
    export PEPPERTALK_CLIENT_ID = "client id from console"
    export PEPPERTALK_SECRET = "client secret from console"
```

* grunt server
* Access the app at http://localhost:8989/app/

Please refer to the accompanying [detailed documentation](http://espreccino.github.io/PepperTalkWebSDKExample/)