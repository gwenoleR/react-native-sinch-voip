import { NativeModules, NativeEventEmitter, requireNativeComponent } from "react-native"

const { SinchVoip } = NativeModules

export const CallManager = (() => {
    const eventEmitter = new NativeEventEmitter(SinchVoip)

    // let sound: Sound
  
    return {
      eventEmitter,
      isStarted: false,
    //   hasPermissions: AudioRecorder.requestAuthorization,
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
