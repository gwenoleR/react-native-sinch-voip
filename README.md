# react-native-sinch-voip

## Installation

`$ npm install react-native-sinch-voip --save`

or

`$ yard add react-native-sinch-voip`

### iOS

Your iOS project need a Swift Bridge to work

Edit your `Info.plsit` to have **Micro** and **Camera** Permissions

```xml
<dict>
    <key>NSCameraUsageDescription</key>
    <string>We need your camera for visio call</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>We need your micro for phone call</string>
</dict>
```

### Android

You need to add some Android Permissions on your `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
```

## Example

```js
import React, {useEffect, useState} from 'React'
import {StyleSheet, View, Button, TextInput} from 'react-native'
import SinchVoip, {hasPermissions, SinchVoipEvents} from 'react-native-sinch-voip'

const App = () => {

    const [myId, setMyId] = useState('')
    const [myDisplayName, setMyDisplayName] = useState('')
    const [userIdToCall, setUserIdToCall] = useState('')
    const [isSinchSetup, setIsSinchSetup] = useState(false)

    useEffect(() => {
        // Listen for incoming call
        SinchVoipEvents.addListener('receiveIncomingCall', (call) => {
            const hasPermissions = hasPermissions()
            if(hasPermissions){
                // Do someting with the call
                // ex: navigate to a custom Call Screen
                console.log(`Incoming call from userId: ${call.userId}, is using camera: ${call.camera}`)
            }
        })
    }, [])

    const initSinch = (userId, userDisplayName) => {
        SinchVoip.initClient(
            'sinchAppKey',
            'sinchAppSecret',
            'sinchHostName',
            userId,
            userName,
            false // use push notification
          )
    }

    const callUser = (userId) => {
        SinchVoip.callUserWithId(userId)
    }

    return(
        <View style={styles.container}>
            <TextInput
              style={{height: 40}}
              placeholder={'User ID'}
              onChangeText={(e) => {
                setMyId(e)
              }}
            />
            <TextInput
              style={{height: 40}}
              placeholder={'User display name'}
              onChangeText={(e) => {
                setMyDisplayName(e)
              }}
            />
            <TextInput
              style={{height: 40}}
              placeholder={'User ID to call'}
              onChangeText={(e) => {
                setUserIdToCall(e)
              }}
            />
            <Button
                title="Listen for call"
                onPress={() => {
                    initSinch(myId, myDisplayName)
                    setIsSinchSetup(true)
                    }
                }
            />
            <Button
                title="Call user !"
                disabled={!(isSinchSetup && userIdToCall)}
                onPress={() => callUser(userIdToCall)}
            />
        </View>
    )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    paddingTop: Constants.statusBarHeight,
    backgroundColor: "#ecf0f1",
    padding: 8
  },
})

export defautl App
```

## Usage

```javascript
import SinchVoip, { SinchVoipEvents, hasPermissions } from 'react-native-sinch-voip';
```

## Methods

### hasPermissions

#### `hasPermissions() => boolean`

*Android Only* :
Check if app has CAMERA and RECORD_AUDIO permissions

If you haven't the permissions you **must not**  call `SinchVoip.callUserWithId` or `SinchVoip.callUserWithIdUsingVideo`

### SinchVoip

#### `SinchVoip.initClient(applicationKey: string, applicationSecret: string, environmentHost: string, userId: string, userDisplayName: string, usePushNotification: boolean) => void`

Init Sich Client with your App credentials and attribute an ID for your user.

This ID is used to call the user

```js
SinchVoip.initClient(
    YOUR_APPLICATION_KEY,
    YOUR_APPLICATION_SECRET,
    HOST, // sandbox.sinch.com or clientapi.sinch.com
    userId,
    userDisplayName,
    false // use push notification
)
```

#### `SinchVoip.startListeningOnActiveConnection() => void`

Listening on incoming call.

Automaticaly call during the client initialisation. Usefull if you manualy stop listening connection

#### `SinchVoip.stopListeningOnActiveConnection() => void`

Stop listening on incoming call.

#### `SinchVoip.callUserWithId(userId: string) => void`

Call user with id **userId**

#### `SinchVoip.callUserWithIdUsingVideo(userId: string) => void`

Call user with id **userId** using camera

#### `SinchVoip.answer() => void`

Answer on the incoming call

#### `SinchVoip.hangup() => void`

Hangup the current call or decline the incoming call

#### `SinchVoip.mute() => void`

Mute your mic for the current call

#### `SinchVoip.unmute() => void`

Unmute your mic for the current call

#### `SinchVoip.enableSpeaker() => void`

Enable the loud speaker for the current call

#### `SinchVoip.disableSpeaker() => void`

Disable the loud speaker for the current call

#### `SinchVoip.resumeVideo() => void`

Active your video if your are in video call

#### `SinchVoip.pauseVideo() => void`

Disactive your video if your are in video call

#### `SinchVoip.switchCamera() => void`

Change the current camera from `FRONT` to `BACK` or from `BACK` to `FRONT`

#### `SinchVoip.isStarted() => boolean`

Return `true` if the client is started

### SinchVoipEvents

Available events :

* receiveIncomingCall
* callEstablish
* callEnd
  
## Run example

On `App.js` add your Sinch Application key

```js
const APPLICATION_KEY = '<YOUR-APPLICATION-KEY';
const APPLICATION_SECRET = '<YOUR-APPLICATION-SECRET>';
const HOST = 'sandbox.sinch.com'; // clientapi.sinch.com for production
```

then

```sh
yarn
yarn run start
react-native run-ios
```

## License

[MIT](/LICENSE)
