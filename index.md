---

layout: default
title: Pepper Talk Sample App

---
# Pepper Talk Sample App

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Introduction](#introduction)
- [Quick Start](#quick-start)
- [Pepper Talk](#pepper-talk)
  - [Dependencies](#dependencies)
  - [SDK initialization](#sdk-initialization)
- [Topic](#topic)
- [Initiating a Chat](#initiating-a-chat)
- [API](#api)
- [Events generated](#events-generated)
  - [incoming_message](#incoming_message)
  - [incoming_data](#incoming_data)
  - [show_topic](#show_topic)
  - [show\_user\_profile](#show\_user\_profile)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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

### Dependencies
Pepper Talk Web SDK uses jQuery for some operations and to trigger [events] when some activity happens.

### SDK initialization
To get started sign up for Pepper Talk at the [Pepper Talk Console](https://console.getpeppertalk.com/). You can create a new app for yourself matching the app you are developing. Create or use an existing client id and secret pair for use with the platform of your choice. The JS SDK for web embeds the id and secret in a server component to generate an SSO to the Pepper Talk backend. Detailed explanation of how to generate the SSO token is described lated. The JS SDK has an *onAuthRequired* endpoint which should be provided. The implementation is expected to generate the SSO token and pass back the credentials along with the user id who is logging into the chat. 

{% highlight javascript linenos %}
onAuthRequired = function(callback) {
  // fetch authData via an XHR call
  // authData = {
  //   grant_type: 'sso'
  //   client_id: pepperKitClientId
  //   timestamp: timestamp
  //   user_id: <<userid>>
  //   sso_token: sso_token
  //   display_name: <<users full name>>
  // }
  return callback(null, authData);
}
{% endhighlight %}

We recommend that the SSO token be generated on the server side. Your implementation should ideally fetch the auth credentials from an XHR call for the signed in user of the app. The SSO token is generated as follows

{% highlight javascript linenos %}
shasum(pepperKitClientId + ":" + pepperKitSecret + ":" + timestamp + ":" + userid)
{% endhighlight %}

The user\_id that you pass in the authData will be the identifier for the user on Pepper Talk. You will send and receive messages from this id. Use an identifier which you can easily map to the user on your app. It can be a guid, email, id or whatever you choose. Remember that it should be something that your app can easily discover. For example on a classifieds listing app the userid of the person posting a listing is ideal since all users can easily discover this from the listing and users can use this to start a chat with the person. 

Here's how the sample app does the PepperTalk initialization.

{% highlight coffee linenos %}
app.run(($rootScope, $state, $stateParams, loginService) ->
  $rootScope.$on('login_success', ->
    PepperTalk.onAuthRequired = (callback) ->
      loginService.getPepperTalkSSO(callback)
      return
    PepperTalk.init()
    $(PepperTalk).on('incoming_message', (event, data) ->
      $rootScope.$evalAsync(->
        $rootScope.$broadcast('incoming_message', data)
      )
      return
    )
    return  
  )
)
{% endhighlight %}

## Topic
Pepper Talk exposes a *topic* for having multiple threads of conversations with the same user. A topic id can be any string that you choose. For example a listing app could use the id of the listing as the topic id. This would help the app to organize the chats among the same set of participants with a logical entity in the app. A description is also supported to give a descriptive value for the topic id.

## Initiating a Chat
Here's how a chat is initated in the sample app

{% highlight coffee linenos %}
@chat = (user) ->
  return PepperTalk.showParticipantsForTopic('NoTopic', 'No Topic') if loginService.userName is user
  return PepperTalk.chatWithParticipant(user, 'NoTopic', 'No Topic')
{% endhighlight %}

We use two of the Pepper Talk calls here. If the current logged in user is the same as the one with whom the users is trying to iniate a chat we bring up the list of people with whom the user is already having a chat session. Else we start off a chat session with the passed in user with a dummy topic id and topic title.

## API 
* PepperTalk.init()
* PepperTalk.chatWithParticipant: (participant, topic\_id, topic\_title)
* PepperTalk.showParticipantsForTopic: (topic\_id, topic\_title)
* PepperTalk.showTopicsForParticipant: (participant)
* PepperTalk.sendCustomData: (participant, topic\_id, topic\_title, text, data)
* PepperTalk.getMessageStats: (callback)
* PepperTalk.getTopicUnreadCount: (topic\_id, callback)
* PepperTalk.getParticipantUnreadCount: (participant, callback)
* PepperTalk.updateUser: (userName, userPic, callback)
* PepperTalk.createGroup: (groupId, groupName, groupPic, members, callback)
* PepperTalk.updateGroup: (groupId, groupName, groupPic, callback)
* PepperTalk.joinGroup: (groupId, members, callback)
* PepperTalk.leaveGroup: (groupId, members, callback)
* PepperTalk.deleteGroup: (groupId, callback)
* PepperTalk.onAuthRequired: (callback)

## Events generated
The following jQuery events are triggered on the PepperTalk object

### incoming_message
{% highlight coffee linenos %}
metadata: {
  participant: participant
  from: from
  to: to
  topic_id: topic_id 
  topic_title: topic_title 
  unread: count
}
{% endhighlight %}

### incoming_data
{% highlight coffee linenos %}
metadata: {
  participant: participant
  uuid: uuid
  timestamp: timestamp
  from: from
  to: to
  topic_id: topic_id 
  topic_title: topic_title 
},
data: data
{% endhighlight %}

### show_topic
{% highlight coffee linenos %}
topic_id
{% endhighlight %}

### show\_user\_profile
{% highlight coffee linenos %}
user_id
{% endhighlight %}

