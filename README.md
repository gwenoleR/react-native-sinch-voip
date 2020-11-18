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

## Run example

On `App.js` add your Sinch Application key

```js
const APPLICATION_KEY = '<YOUR-APPLICATION-KEY';
const APPLICATION_SECRET = '<YOUR-APPLICATION-SECRET>';
const HOST = 'sandbox.sinch.com'; // clientapi.sinch.com for production
```

then

```sh
yarn run start
react-native run-ios
```

## License

[MIT](/LICENSE)
