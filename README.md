# react-native-sinch-voip

## Installation

`$ npm install react-native-sinch-voip --save`

or

`$ yard add react-native-sinch-voip`

### iOS

Your iOS project need a Swift Bridge to work

### Android

You need to add some Android Permissions on your `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
```

## Usage

```javascript
import SinchVoip from 'react-native-sinch-voip';
```

## Methods

### `SinchVoip.initClient(applicationKey: string, applicationSecret: string, environmentHost: string, userId: string) => void`

Init Sich Client with your App credentials and attribute an ID for your user.

This ID is used to call the user

```js
SinchVoip.initClient(
    YOUR_APPLICATION_KEY,
    YOUR_APPLICATION_SECRET,
    HOST, // sandbox.sinch.com or clientapi.sinch.com
    userId
)
```

### `SinchVoip.startListeningOnActiveConnection() => void`

Listening on incoming call.

Automaticaly call during the client initialisation. Usefull if you manualy stop listening connection

### `SinchVoip.stopListeningOnActiveConnection() => void`

Stop listening on incoming call.

### `SinchVoip.callUserWithId(userId: string) => void`

Call user with id **userId**

### `SinchVoip.callUserWithIdUsingVideo(userId: string) => void`

Call user with id **userId** using camera

### `SinchVoip.answer() => void`

Answer on the incoming call

### `SinchVoip.hangup() => void`

Hangup the current call or decline the incoming call

### `SinchVoip.mute() => void`

Mute your mic for the current call

### `SinchVoip.unmute() => void`

Unmute your mic for the current call

### `SinchVoip.enableSpeaker() => void`

Enable the loud speaker for the current call

### `SinchVoip.disableSpeaker() => void`

Disable the loud speaker for the current call

### `SinchVoip.resumeVideo() => void`

Active your video if your are in video call

### `SinchVoip.pauseVideo() => void`

Disactive your video if your are in video call

### `SinchVoip.switchCamera() => void`

Change the current camera from `FRONT` to `BACK` or from `BACK` to `FRONT`

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
