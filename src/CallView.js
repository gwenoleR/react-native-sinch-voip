import React from 'react';
import { View, StyleSheet, Text, TouchableOpacity } from 'react-native';
import { CallManager } from './call-manager'
import { RemoteCameraView } from './RemoteCameraView'

export const Call = ({
  incoming=true,
  camera=false,
  onCallEnd
}) => {

  let callEstablishListener
  let callEndListener
  let durationInterval

  const [didPickUp, setDidPickUp] = React.useState(false)
  const [isConnectionEstablished, setIsConnectionEstablished] = React.useState(false)
  const [callEnded, setCallEnded] = React.useState(false)
  const [isMuted, setIsMuted] = React.useState(false)
  const [isUsingSpeakers, setIsUsingSpeakers] = React.useState(false)
  const [isUsingVideo, setIsUsingVideo] = React.useState(camera)
  const [duration, setDuration] = React.useState(0)

  React.useEffect(() => {
    callEstablishListener = CallManager.eventEmitter.addListener("callEstablish", () => {
      setIsConnectionEstablished(true)

      durationInterval = setInterval(() => {
        setDuration(count => count + 1)
      }, 1000)
    })

    callEndListener = CallManager.eventEmitter.addListener("callEnd", () => {
      setCallEnded(true)

      clearInterval(durationInterval)
      durationInterval = null
    })

    return () => {

      if (callEstablishListener) {
        callEstablishListener.remove()
      }

      if (callEndListener) {
        callEndListener.remove()
      }
    }
  }, [])

  const answer = () => {
    CallManager.answer()
    setDidPickUp(true)
  }

  const hangup = () => {
    CallManager.hangup()
    onCallEnd()
  }

  const toggleMute = () => {
    setIsMuted(!isMuted)

    if (isMuted) {
      return CallManager.unmute()
    }

    return CallManager.mute()
  }

  const toggleSpeaker = () => {
    setIsUsingSpeakers(!isUsingSpeakers)

    if (isUsingSpeakers) {
      return CallManager.disableSpeaker()
    }

    return CallManager.enableSpeaker()
  }

  const toggleCamera = () => {
    setIsUsingVideo(!isUsingVideo)

    if(isUsingVideo){
      return CallManager.disableCamera()
    }
    return CallManager.enableCamera()
  }

  let closeTimeout

  const renderPhoneBtn = (type) => (
    <TouchableOpacity 
      style={[styles.rounded, {backgroundColor: type === 'answer' ? '#4CD964' : 'red'}]} 
      onPress={type === "answer" ? answer : hangup}>
        <Text>{type}</Text>
    </TouchableOpacity>
  )

  const renderActionBtn = (type, isActive, callback, enabled=true) => (
    <TouchableOpacity 
      style={[styles.rounded, {backgroundColor: isActive ? '#fff' : '#1d1d1d'}]} 
      onPress={callback}
      disabled={!enabled}
      >
        <Text>{type}</Text>
    </TouchableOpacity>
  )

  const callStatus = React.useMemo(() => {
    if (callEnded) {
      closeTimeout = setTimeout(() => {
        console.log('END CALL')
        onCallEnd()
      }, 2000)
      return <Text style={styles.callStatusText} >End call</Text>
    }

    if (isConnectionEstablished) {
      return <Text style={styles.callStatusText} >{duration}</Text>
    }

    let tx = "Calling..."
    if (!didPickUp && incoming && !isUsingVideo) tx = "Incoming voice call"
    if (!didPickUp && incoming && isUsingVideo) tx = "Incoming video call"

  return <Text style={styles.callStatusText}>{tx}</Text>
  }, [didPickUp, incoming, isConnectionEstablished, callEnded, duration, isUsingVideo])

  const actionsBtns = React.useMemo(() => {
    if (!didPickUp && incoming) {
      return (
        <View style={[styles.actions, styles.receiveCallActions]}>
          {renderPhoneBtn("hangup")}
          {renderPhoneBtn("answer")}
        </View>
      )
    }

    return (
      <View style={[styles.actions, styles.receiveCallActions]}>
        {renderActionBtn("micro", isMuted, toggleMute)}
        {renderActionBtn("volume", isUsingSpeakers, toggleSpeaker)}
        {renderPhoneBtn("hangup")}
        {renderActionBtn("camera", isUsingVideo, toggleCamera)}
      </View>
    )
  }, [didPickUp, incoming, isMuted, isUsingSpeakers, isUsingVideo])

  console.log(isUsingVideo)

  return (
    <View style={styles.container}>
      {/* <View style={styles.background}> */}
        {/* {isUsingVideo &&  */}
        <RemoteCameraView 
        style={{
          width: "100%",
          height: "100%",
          position: 'absolute',
          top: 0,
          right: 0,
          overflow: 'hidden'
        }}/>
        {/* } */}
      {/* </View> */}
      <View style={styles.meta}>
        {callStatus}
      </View>
      {actionsBtns}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#181818',
    opacity: 0.8
  },
  callStatusText: {
    color: 'white',
    fontSize: 17,
    lineHeight: 22,
    textAlign: "center",
    marginTop: 4,
  },
  rounded: {
    height: 60,
    width: 60,
    borderRadius: 30,
    alignItems: "center",
    justifyContent: "center",
  },
  actions: {
    position: "absolute",
    bottom: 40,
    left: 0,
    width: "100%",
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
  },
  receiveCallActions: {
    paddingHorizontal: 24,
    justifyContent: "space-between",
  },
  meta: {
    flex:1,
    alignItems: "center",
    justifyContent: "center",
  },
  background: {
    position: "absolute",
    top: 0,
    left: 0,
    width: "100%",
    height: "100%",
  },
});

