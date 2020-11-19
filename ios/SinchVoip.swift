//
//  SinchVoip.swift
//
//  Created by Gwenole ROTON on 16/11/2020.


import Foundation
import Sinch

@objc(SinchVoip)
class SinchVoip: RCTEventEmitter {
    static let sharedInstance = SinchVoip()
    var client: SINClient? = nil
    var call: SINCall? = nil
    var videoController: SINVideoController? = nil
    var audioController: SINAudioController? = nil
    
    
    private override init() {
        super.init()
    }

     @objc open override func supportedEvents() -> [String] {
         return ["receiveIncomingCall", "callEstablish", "callEnd"]
     }
    
    @objc(initClient:applicationSecret:environmentHost:userId:)
    func initClient(applicationKey: String, applicationSecret: String, environmentHost: String, userId: String) -> SINClient {
        print("SinchVoip::Init Client with id => \(userId)")
        
        let sinchClient = Sinch.client(withApplicationKey: applicationKey, applicationSecret: applicationSecret, environmentHost: environmentHost, userId: userId)
        sinchClient?.setSupportCalling(true)
        sinchClient?.delegate = self
        sinchClient?.call()?.delegate = self

        sinchClient?.startListeningOnActiveConnection()
        sinchClient?.start()
    
        SinchVoip.sharedInstance.client = sinchClient!
        SinchVoip.sharedInstance.videoController = sinchClient!.videoController()
        SinchVoip.sharedInstance.audioController = sinchClient!.audioController()
        
        return sinchClient!
    }
    
    @objc(startListeningOnActiveConnection)
    func startListeningOnActiveConnection() {
        SinchVoip.sharedInstance.client?.startListeningOnActiveConnection()
    }
    
    @objc(stopListeningOnActiveConnection)
    func stopListeningOnActiveConnection() {
        SinchVoip.sharedInstance.client?.stopListeningOnActiveConnection()
    }
    
    @objc(terminate)
    func terminate() {
        SinchVoip.sharedInstance.client?.stopListeningOnActiveConnection()
        SinchVoip.sharedInstance.client?.terminate()
        SinchVoip.sharedInstance.client = nil
    }
    
    @objc(callUserWithId:)
    func callUserWithId(userId: String) {
        let call: SINCall = (SinchVoip.sharedInstance.client?.call().callUser(withId: userId))!
        call.delegate = self
        SinchVoip.sharedInstance.call = call
    }
    
    @objc(callUserWithIdUsingVideo:)
    func callUserWithIdUsingVideo(userId: String) {
        let call: SINCall = (SinchVoip.sharedInstance.client?.call().callUserVideo(withId: userId))!
        call.delegate = self
        SinchVoip.sharedInstance.call = call
    }
    
    @objc(answer)
    func answer() {
        SinchVoip.sharedInstance.call?.answer()
    }
    
    @objc(hangup)
    func hangup() {
        SinchVoip.sharedInstance.call?.hangup()
        SinchVoip.sharedInstance.call = nil
        SinchVoipRemoteVideoManager.sharedInstance.remoteView?.removeFromSuperview()
        SinchVoipLocalVideoManager.sharedInstance.localView?.removeFromSuperview()
    }
    
    @objc(mute)
    func mute() {
        SinchVoip.sharedInstance.client?.audioController()?.mute()
    }
    
    @objc(unmute)
    func unmute() {
        SinchVoip.sharedInstance.client?.audioController()?.unmute()
    }
    
    @objc(enableSpeaker)
    func enableSpeaker() {
        SinchVoip.sharedInstance.client?.audioController()?.enableSpeaker()
    }
    
    @objc(disableSpeaker)
    func disableSpeaker() {
        SinchVoip.sharedInstance.client?.audioController()?.disableSpeaker()
    }
    
    @objc(pauseVideo)
    func pauseVideo() {
        SinchVoip.sharedInstance.call?.pauseVideo()
    }
    
    @objc(resumeVideo)
    func resumeVideo() {
        SinchVoip.sharedInstance.call?.resumeVideo()
    }
    
    @objc(switchCamera)
    func switchCamera() {
        let current = SinchVoip.sharedInstance.videoController?.captureDevicePosition;
        SinchVoip.sharedInstance.videoController?.captureDevicePosition = SINToggleCaptureDevicePosition(current!);
    }
}

extension SinchVoip: SINClientDelegate {
    func clientDidStart(_ client: SINClient!) {}
    
    func clientDidFail(_ client: SINClient!, error: Error!) {}
    
    func clientDidStop(_ client: SINClient!) {}
    
    func client(_ client: SINClient!, requiresRegistrationCredentials registrationCallback: SINClientRegistration!) {}
}

extension SinchVoip: SINCallClientDelegate {
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {}
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("SinchVoip::Use video ?", call.details.isVideoOffered)
        self.sendEvent(withName: "receiveIncomingCall", body: [
            "callId": call.callId!,
            "userId": call.remoteUserId!,
            "camera": call.details.isVideoOffered
        ])
        call.delegate = self
        SinchVoip.sharedInstance.call = call
    }
}

extension SinchVoip: SINCallDelegate {
    func callDidProgress(_ call: SINCall!) {}
    
    func callDidEstablish(_ call: SINCall!) {
        self.sendEvent(withName: "callEstablish", body: [
            "callId": call.callId
        ])
    }
    
    func callDidEnd(_ call: SINCall!) {
        print("RNSinch : callDidEnd", call.details.endCause, call.details.error ?? "")

        self.sendEvent(withName: "callEnd", body: [
            "callId": call.callId
        ])
        SinchVoip.sharedInstance.call = nil
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
