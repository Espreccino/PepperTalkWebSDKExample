---

layout: default
title: Pepper Talk Sample App

---
# Pepper Talk Sample App

<!-- doctoc index.md --github -->
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
  - [PepperTalk.init()](#peppertalkinit)
  - [PepperTalk.chatWithParticipant: (participant, topicId, topicTitle)](#peppertalkchatwithparticipant-participant-topicid-topictitle)
  - [PepperTalk.showParticipantsForTopic: (topicId, topicTitle)](#peppertalkshowparticipantsfortopic-topicid-topictitle)
  - [PepperTalk.showTopicsForParticipant: (participant)](#peppertalkshowtopicsforparticipant-participant)
  - [PepperTalk.sendCustomData: (participant, topicId, topicTitle, text, data)](#peppertalksendcustomdata-participant-topicid-topictitle-text-data)
  - [PepperTalk.getMessageStats: (callback)](#peppertalkgetmessagestats-callback)
  - [PepperTalk.getMessageSummary: (groupBy, callback)](#peppertalkgetmessagesummary-groupby-callback)
  - [PepperTalk.getTopicUnreadCount: (topicId, callback)](#peppertalkgettopicunreadcount-topicid-callback)
  - [PepperTalk.getParticipantUnreadCount: (participant, callback)](#peppertalkgetparticipantunreadcount-participant-callback)
  - [PepperTalk.updateUser: (userName, userPic, callback)](#peppertalkupdateuser-username-userpic-callback)
  - [PepperTalk.createGroup: (groupId, groupName, groupPic, members, callback)](#peppertalkcreategroup-groupid-groupname-grouppic-members-callback)
  - [PepperTalk.updateGroup: (groupId, groupName, groupPic, callback)](#peppertalkupdategroup-groupid-groupname-grouppic-callback)
  - [PepperTalk.joinGroup: (groupId, members, callback)](#peppertalkjoingroup-groupid-members-callback)
  - [PepperTalk.leaveGroup: (groupId, members, callback)](#peppertalkleavegroup-groupid-members-callback)
  - [PepperTalk.deleteGroup: (groupId, callback)](#peppertalkdeletegroup-groupid-callback)
  - [PepperTalk.onAuthRequired: (callback)](#peppertalkonauthrequired-callback)
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
  //   profile_photo: <<users profile picture>>
    
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
### PepperTalk.init()
Initializes the SDK. Please ensure that you have the _onAuthRequired_ method provided. During the initialization cycle authorization would be requested, so ideally call the init only after you have a logged in user or trigger the login during the auth call.

### PepperTalk.chatWithParticipant: (participant, topicId, topicTitle)
Opens up the chat window with the requested participant. 
Parameters

* participant - required (String), user or group id with whom the chat is to be instantiated.
* topicId - optional (String), an id for the topic
* topicTitle - optional (String), a title for the topic, this will be displayed on the chat window, so ensure it contains a meaningful text representation of the topic.

### PepperTalk.showParticipantsForTopic: (topicId, topicTitle)
Opens up the lists of participants for a particular topic. 
Parameters

* topicId - required (String), topic id for which the participant list should be shown
* topicTitle - required (String), title for the topic

### PepperTalk.showTopicsForParticipant: (participant)
Opens up the list of topics for a particular participant.
Parameters

* participant - required (String), user or group id for which the list of topics should be shown

### PepperTalk.sendCustomData: (participant, topicId, topicTitle, text, data)
Sends any data, with some restrictions, to the requested participant, under the topic. The data should be JSON serializable, and be under 2Kb in size after serialization. 
Parameters

* participant - required (String), user or group id to whom the data should be sent.
* topicId - optional (String), an id for the topic
* topicTitle - optional (String), a title for the topic.
* text - a textual representation for this data, this is used as a fallback in case the other end could not display the message and for remote notification messages over GCM and APNS.

### PepperTalk.getMessageStats: (callback)
Returns the current message count statistics. 
Parameters

* callback - required (function(err, object)) the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is of the form
{% highlight coffee%}
{
 count: # total number of messages
 unread: # total number of unread messages
}
{% endhighlight %}

### PepperTalk.getMessageSummary: (groupBy, callback)
Returns a summary of the messages grouped either by participants or topics.
Parameters

* groupBy - required (String) either "users" or "topics",
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is of the form
  
  * for user based grouping 
{% highlight coffee%}
{
 user_id : { # keyed on user_id or group_id
   topics : {
     topic_id : { # keyed on topic_id
       count   : # total messages in this topic for this user
       unread  : # total unread messages within those messages
       last_message_timestamp: # unix timestamp in millis for the last message in them
       topic_title : # description of the topic
       topic_id    : # id of the topic
     }
   }
   user_name : # user name
   user_id   : # id of the user
 }
}
{% endhighlight %}

  * for topic based grouping
{% highlight coffee%}
{
 topic_id : { # keyed on topic_id
   users : {
     user_id : { # keyed on user_id or group_id
       count   : # total messages in this topic for this user
       unread  : # total unread messages within those messages
       last_message_timestamp: # unix timestamp in millis for the last message in them
       user_name : # user name
       user_id   : # id of the user
     }
   }
   topic_title : # description of the topic
   topic_id    : # id of the topic
 }
}
{% endhighlight %}
  
### PepperTalk.getTopicUnreadCount: (topicId, callback)
Returns the unread count in a particular topic.
Parameters

* topicId - required (String), id for the topic
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is of the form
{% highlight coffee%}
{
 count: # count of unread messages
}
{% endhighlight %}

### PepperTalk.getParticipantUnreadCount: (participant, callback)
Returns the unread count for a particular participant.
Parameters

* participant - required (String), user or group id to whom the data should be sent.
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is of the form
{% highlight coffee%}
{
 count: # count of unread messages
}
{% endhighlight %}

### PepperTalk.updateUser: (userName, userPic, callback)
Update the profile information for the currently logged in user. 
Parameters

* userName - optional(String) Display name for the user.
* userPid - optional(String) display picture for the user.
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is the updated profile of the user

### PepperTalk.createGroup: (groupId, groupName, groupPic, members, callback)
Create a new group. 
Parameters

* groupId - required(String) id for the group, group ids are of the form grp:<< group identifier >> . The prefix "grp:" is required and the group identifier can be any string, the identifier string should be unique.
* groupName - optional(String) a description for the group
* groupPic - optional(String) display picture for the group
* members - required(Array[String]) list of user ids who should be part of the group. The user creating the group is the admin of the group and will be added by default.
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is the profile of the group

### PepperTalk.updateGroup: (groupId, groupName, groupPic, callback)
Update the profile of a group. Any member of the group can update the group profile.
Parameters

* groupId - required(String) id for the group to be updated.
* groupName - optional(String) a description for the group
* groupPic - optional(String) display picture for the group
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is the profile of the group

### PepperTalk.joinGroup: (groupId, members, callback)
Add users to a group. This can be called only by the admin of the group.
Parameters

* groupId - required(String) id for the group to which users are to be added.
* members - required(Array[String]) list of user ids to be added to the group, the users must exist.
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is the profile of the group

### PepperTalk.leaveGroup: (groupId, members, callback)
Remove users from a group. This can be called only by the admin of the group, or by a member of the group to remove self.
Parameters

* groupId - required(String) id for the group to which users are to be added.
* members - required(Array[String]) list of user ids to be removed from the group.
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is the profile of the group

### PepperTalk.deleteGroup: (groupId, callback)
Remove a group. This can be called only by the admin of the group.
Parameters

* groupId - required(String) id for the group to which users are to be added.
* callback - required (function(err, object))the callback function to be invoked when the data is fetched. Its a standard 2 arg function and the object is the profile of the group

### PepperTalk.onAuthRequired: (callback)
This function is called during initial connection or a reconnect in case of a network loss. Please invoke the callback function with the credentials as described

{% highlight coffee %}
{
  grant_type: 'sso'
  client_id: # your client id
  timestamp: # unix timestamp in millis
  user_id: # user id for the user logging in
  sso_token: # sso token as described previously
  display_name: # Full name for the user
  profile_photo: # Profile photo for the user
}
{% endhighlight %}

## Events generated
The following jQuery events are triggered on the PepperTalk object

### incoming_message
Triggered when a new chat message comes in. 

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
Triggered when a new custom data message comes in. 

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
Triggered when a click on the topic id is detected. Treat this as a request to display the topic details. 

{% highlight coffee linenos %}
topic_id
{% endhighlight %}

### show\_user\_profile
Triggered when a click on the users profile pic on name is detected. Treat this as a request to display the user profile. 

{% highlight coffee linenos %}
user_id
{% endhighlight %}

