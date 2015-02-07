---

layout: default
title: Pepper Talk Sample App

---
# Pepper Talk Sample App

## Introduction
This is a sample app to demonstrate the JS SDK for Pepper Talk. It contains both the server and the client components. Its built as an Express service for the server and Angular app for the client.

## Quick Start
* git clone [repo](https://github.com/Espreccino/PepperTalkWebSDKExample.git)
* npm install
* bower install
* grunt
* Get the client id and client secret from [Pepper Talk console](https://console.getpeppertalk.com/)
* Setup environment variable with client id and client secret
  * export PEPPERTALK_CLIENT_ID = *client id*
  * export PEPPERTALK_SECRET = *client secret*
* grunt server
* Access the app at [http://localhost:8989/app/](http://localhost:8989/app/)

## Pepper Talk 
[*Pepper Talk*](http://getpeppertalk.com/) is a messaging platform built primarily for mobiles. It provides native interfaces for iOS, Android and Web applications via SDK's to enable peer to peer chat for apps. Being mobile ready it has built in support for notifications, delivery indicators, media sharing and others out of the box. The SDK's expose a simple interface to get chat up and running with minimal effort from you the developer. We provide a full fledged chat interface which fits seamlessly into your apps, with customization options. SDK also exposes interfaces to send custom data between users. Callbacks are provided to have tight integration with your app, for incoming messages and unread message counts.

### SDK initialization
To get started sign up for Pepper Talk at the [Pepper Talk Console](https://console.getpeppertalk.com/). You can create a new app for yourself matching the app you are developing. Create or use an existing client id and secret pair for use with the platform of your choice. The JS SDK for web embeds the id and secret in a server component to generate an SSO to the Pepper Talk backend. Detailed explanation of how to generate the SSO token is described lated. The JS SDK has an *onAuthRequired* endpoint which should be provided. The implementation is expected to generate the SSO token and pass back the credentials along with the user id who is logging into the chat. 

    onAuthRequired = function(callback) {
      // fetch authData via an XHR call
      // authData = {
      //   grant_type: 'sso'
      //   client_id: pepperKitClientId
      //   timestamp: timestamp
      //   user_id: <<userid>>
      //   sso_token: sso_token
      //   display_name: <<user's full name>>
      // }
      return callback(null, authData);
    }

We recommend that the SSO token be generated on the server side. You implementation should ideally fetch the auth credentials from an XHR call for the signed in user of the app. The SSO token is generated as follows

    shasum(pepperKitClientId + ":" + pepperKitSecret + ":" + timestamp + ":" + userid)

The user\_id that you pass in the authData will be the identifier for the user on Pepper Talk. You will send and receive messages from this id. Use an identifier which you can easily map to the user on your app. It can be a guid, email, id or whatever you choose. Remember that it should be something that your app can easily discover. For example on a classifieds listing app the userid of the person posting a listing is ideal since all users can easily discover this from the listing and users can use this to start a chat with the person. 


## Walk through
### Server side
#### SSO implementation

### Client side
#### Auth callback
#### Events generated
#### API 
