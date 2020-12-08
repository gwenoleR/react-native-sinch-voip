import { NativeModules, NativeEventEmitter, PermissionsAndroid, Platform } from "react-native"

const { SinchVoip } = NativeModules

export const hasCameraPermission = async () => {
  if(Platform.OS === 'android'){
    try {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.CAMERA
      );
      if (granted === PermissionsAndroid.RESULTS.GRANTED) {
        console.log("You can use the camera");
        return true
      } else {
        console.log("Camera permission denied");
        return false
      }
    } catch (err) {
      console.warn(err);
    }
  }
  return true
}

export const hasAudioPermission = async () => {
  if(Platform.OS === 'android'){
    try {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.RECORD_AUDIO
      );
      if (granted === PermissionsAndroid.RESULTS.GRANTED) {
        console.log("You can record audio");
        return true
      } else {
        console.log("Audio record permission denied");
        return false
      }
    } catch (err) {
      console.warn(err);
    }
  } 
  return true
}

export const hasPermissions = async () => {
  if(Platform.OS === 'android'){
    const granted = await PermissionsAndroid.requestMultiple(
      [PermissionsAndroid.PERMISSIONS.RECORD_AUDIO, PermissionsAndroid.PERMISSIONS.CAMERA, PermissionsAndroid.PERMISSIONS.READ_PHONE_STATE]
    );
    if(granted["android.permission.RECORD_AUDIO"] === PermissionsAndroid.RESULTS.GRANTED &&
     granted["android.permission.CAMERA"] === PermissionsAndroid.RESULTS.GRANTED &&
     granted["android.permission.READ_PHONE_STATE"] === PermissionsAndroid.RESULTS.GRANTED
     ){
      return true
    }
    return false
  }
  return true
  
}

export const SinchVoipEvents = new NativeEventEmitter(SinchVoip)

export const CallManager = (() => {

    // let sound: Sound
  
    return {
      eventEmitter: SinchVoipEvents,
      isStarted: false,
      hasPermissions,
      setupClient(sinchAppKey,
        sinchAppSecret,
        sinchHostName,
        userId) {
        if (!CallManager.isStarted) {
          SinchVoip.initClient(
            sinchAppKey,
            sinchAppSecret,
            sinchHostName,
            userId,
          )
  
          CallManager.isStarted = true
        }
      },
      callUserId(userId) {
        SinchVoip.callUserWithId(userId)
      },
      videoCallUserId(userId) {
        SinchVoip.callUserWithIdUsingVideo(userId)
      },
      startListeningIncomingCalls() {
        SinchVoip.startListeningOnActiveConnection()
      },
      stopListeningIncomingCalls() {
        SinchVoip.stopListeningOnActiveConnection()
      },
      terminate() {
        SinchVoip.terminate()
        CallManager.isStarted = false
      },
      answer() {
        // CallManager.stopPlayingSoundFile()
        SinchVoip.answer()
      },
      hangup() {
        // CallManager.stopPlayingSoundFile()
        SinchVoip.hangup()
      },
      mute() {
        SinchVoip.mute()
      },
      unmute() {
        SinchVoip.unmute()
      },
      enableSpeaker() {
        SinchVoip.enableSpeaker()
      },
      disableSpeaker() {
        SinchVoip.disableSpeaker()
      },
      enableCamera(){
        SinchVoip.resumeVideo()
      },
      disableCamera(){
        SinchVoip.pauseVideo()
      }
    //   startPlayingSoundFile(file: string, loop: boolean) {
    //     Sound.setCategory("Playback")
  
    //     sound = new Sound(file, Sound.MAIN_BUNDLE, error => {
    //       if (error) {
    //         return
    //       }
  
    //       sound.setVolume(1)
    //       sound.setNumberOfLoops(loop ? -1 : 1)
    //       sound.play()
    //     })
    //   },
    //   stopPlayingSoundFile() {
    //     if (sound) {
    //       sound.stop()
    //       sound.release()
    //     }
    //   },
    }
  })()
