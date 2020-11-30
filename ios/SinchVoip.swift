//
//  SinchVoip.swift
//
//  Created by Gwenole ROTON on 16/11/2020.


import Foundation
import Sinch

@available(iOS 10.0, *)
@objc(SinchVoip)
class SinchVoip: RCTEventEmitter {
    static var sharedInstance: SinchVoip?
    var client: SINClient? = nil
    var call: SINCall? = nil
    var videoController: SINVideoController? = nil
    var audioController: SINAudioController? = nil
    var callManager: CallManager? = CallManager.sharedInstance
    
    override init() {
        super.init()
        SinchVoip.sharedInstance = self
    }

     @objc open override func supportedEvents() -> [String] {
         return ["receiveIncomingCall", "callEstablish", "callEnd", "hasCurrentCall"]
     }
    
    @objc(initClient:applicationSecret:environmentHost:userId:userDisplayName:)
    func initClient(applicationKey: String, applicationSecret: String, environmentHost: String, userId: String, userDisplayName: String) -> SINClient {
        print("SinchVoip::Init Client with id => \(userId) and displayName => \(userDisplayName)")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(userDisplayName, forKey: "userDisplayName")
        
        let sinchClient = Sinch.client(withApplicationKey: applicationKey, applicationSecret: applicationSecret, environmentHost: environmentHost, userId: userId)
        sinchClient?.setPushNotificationDisplayName(userDisplayName)
        sinchClient?.enableManagedPushNotifications()
        sinchClient?.setSupportCalling(true)
        sinchClient?.setSupportPushNotifications(true)
        sinchClient?.delegate = self
        sinchClient?.call()?.delegate = self

        sinchClient?.startListeningOnActiveConnection()
        sinchClient?.start()
    
        SinchVoip.sharedInstance!.client = sinchClient!
        SinchVoip.sharedInstance!.videoController = sinchClient!.videoController()
        SinchVoip.sharedInstance!.audioController = sinchClient!.audioController()
        
        return sinchClient!
    }
    
    @objc(startListeningOnActiveConnection)
    func startListeningOnActiveConnection() {
        SinchVoip.sharedInstance!.client?.startListeningOnActiveConnection()
    }
    
    @objc(stopListeningOnActiveConnection)
    func stopListeningOnActiveConnection() {
        SinchVoip.sharedInstance!.client?.stopListeningOnActiveConnection()
    }
    
    @objc(terminate)
    func terminate() {
        SinchVoip.sharedInstance!.client?.stopListeningOnActiveConnection()
        SinchVoip.sharedInstance!.client?.terminate()
        SinchVoip.sharedInstance!.client = nil
    }
    
    @objc(callUserWithId:)
    func callUserWithId(userId: String) {
        let headers: [AnyHashable: Any] = [
            AnyHashable("userName"): UserDefaults.standard.string(forKey: "userDisplayName")!,
            ]
        let call: SINCall = (SinchVoip.sharedInstance!.client?.call().callUser(withId: userId, headers: headers))!
        call.delegate = self
        SinchVoip.sharedInstance!.call = call
    }
    
    @objc(callUserWithIdUsingVideo:)
    func callUserWithIdUsingVideo(userId: String) {
        let headers: [AnyHashable: Any] = [
            AnyHashable("userName"): UserDefaults.standard.string(forKey: "userDisplayName")!,
            ]
        let call: SINCall = (SinchVoip.sharedInstance!.client?.call()?.callUserVideo(withId: userId, headers: headers))!
        call.delegate = self
        SinchVoip.sharedInstance!.call = call
    }
    
    @objc(answer)
    func answer() {
        print("SinchVoip:: Call answered")
        SinchVoip.sharedInstance!.call?.answer()
    }
    
    @objc(hangup)
    func hangup() {
        print("SinchVoip::Hangup call")
        SinchVoip.sharedInstance!.call?.hangup()
        SinchVoip.sharedInstance!.call = nil
        SinchVoipRemoteVideoManager.sharedInstance.remoteView?.removeFromSuperview()
        SinchVoipLocalVideoManager.sharedInstance.localView?.removeFromSuperview()
    }
    
    @objc(mute)
    func mute() {
        SinchVoip.sharedInstance!.client?.audioController()?.mute()
    }
    
    @objc(unmute)
    func unmute() {
        SinchVoip.sharedInstance!.client?.audioController()?.unmute()
    }
    
    @objc(enableSpeaker)
    func enableSpeaker() {
        SinchVoip.sharedInstance!.client?.audioController()?.enableSpeaker()
    }
    
    @objc(disableSpeaker)
    func disableSpeaker() {
        SinchVoip.sharedInstance!.client?.audioController()?.disableSpeaker()
    }
    
    @objc(pauseVideo)
    func pauseVideo() {
        SinchVoip.sharedInstance!.call?.pauseVideo()
    }
    
    @objc(resumeVideo)
    func resumeVideo() {
        SinchVoip.sharedInstance!.call?.resumeVideo()
    }
    
    @objc(switchCamera)
    func switchCamera() {
        let current = SinchVoip.sharedInstance!.videoController?.captureDevicePosition;
        SinchVoip.sharedInstance!.videoController?.captureDevicePosition = SINToggleCaptureDevicePosition(current!);
    }
    
    @objc(hasCurrentEstablishedCall)
    func hasCurrentEstablishedCall() {
        var inCall = false
        
        let call = CallManager.sharedInstance.getCurrentCall()
        
        if call != nil {
            inCall = true
            return self.sendEvent(withName: "hasCurrentCall", body: [
                "inCall": inCall,
                "useVideo":call!.sinCall.details.isVideoOffered,
                "headers": call!.sinCall.headers!,
                "remoteUserId": call!.sinCall.remoteUserId!
            ])
        }
       
        return self.sendEvent(withName: "hasCurrentCall", body: inCall)
    }
}

@available(iOS 10.0, *)
extension SinchVoip: SINClientDelegate {
    func clientDidStart(_ client: SINClient!) {}
    
    func clientDidFail(_ client: SINClient!, error: Error!) {}
    
    func clientDidStop(_ client: SINClient!) {}
    
    func client(_ client: SINClient!, requiresRegistrationCredentials registrationCallback: SINClientRegistration!) {}
}

@available(iOS 10.0, *)
extension SinchVoip: SINCallClientDelegate {
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        print("SinchVoip:: Will received incoming call !")
        call.delegate = self
        SinchVoip.sharedInstance!.call = call
        CallProviderDelegate.sharedInstance.receivedCall(call: call)
    }
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("SinchVoip::Use video ?", call.details.isVideoOffered)
        self.sendEvent(withName: "receiveIncomingCall", body: [
            "callId": call.callId!,
            "userId": call.remoteUserId!,
            "camera": call.details.isVideoOffered
        ])
        // Check if call not already trigger by the willReceived method
        if SinchVoip.sharedInstance!.call == nil {
            call.delegate = self
            SinchVoip.sharedInstance!.call = call
            CallProviderDelegate.sharedInstance.receivedCall(call: call)
        }
    }
}

@available(iOS 10.0, *)
extension SinchVoip: SINCallDelegate {
    func callDidProgress(_ call: SINCall!) {}
    
    func callDidEstablish(_ call: SINCall!) {
        print("RNSinch : callEstablish")
        self.sendEvent(withName: "callEstablish", body: [
            "callId": call.callId
        ])
    }
    
    func callDidEnd(_ call: SINCall!) {
        print("RNSinch : callDidEnd", call.details.endCause, call.details.error ?? "")

        self.sendEvent(withName: "callEnd", body: [
            "callId": call.callId
        ])
        if callManager != nil {
            if let call = callManager!.getCurrentCall(){
                callManager!.end(call: call)
            }
        }
        SinchVoip.sharedInstance!.call = nil
        SinchVoipRemoteVideoManager.sharedInstance.remoteView?.removeFromSuperview()
        SinchVoipLocalVideoManager.sharedInstance.localView?.removeFromSuperview()
        
    }
    
    func callDidAddVideoTrack(_ call: SINCall!) {
        print("SinchVoip::Video track added")
    }
    
    func callDidPauseVideoTrack(_ call: SINCall!) {
        print("SinchVoip::Video paused")
    }
    
     func callDidResumeVideoTrack(_ call: SINCall!) {
        print("SinchVoip::Video resumed")
    }
}
