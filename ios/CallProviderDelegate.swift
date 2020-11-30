//
//  SinchVoipCallKitProvider.swift
//  react-native-sinch-voip
//
//  Created by Gwenole on 23/11/2020.
//

import Foundation
import CallKit
import Sinch

@available(iOS 10.0, *)
@objc public final class CallProviderDelegate: NSObject {
    @objc public static let sharedInstance = CallProviderDelegate()
    
    /// The app's provider configuration, representing its CallKit capabilities.
    static let providerConfiguration: CXProviderConfiguration = {
        let localizedName = NSLocalizedString(Bundle.main.infoDictionary!["CFBundleName"] as! String, comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)

        // Prevents multiple calls from being grouped.
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        
        providerConfiguration.supportsVideo = true
        providerConfiguration.supportedHandleTypes = [.generic]


        return providerConfiguration
    }()
    
    let callManager : CallManager
    private let provider: CXProvider
    
    @objc private override init() {
        self.callManager = CallManager.sharedInstance
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }

    // MARK: - Handle Incoming Calls

    /// Use CXProvider to report the incoming call to the system.
    /// - Parameters:
    ///   - uuid: The unique identifier of the call.
    ///   - handle: The handle for the caller.
    ///   - hasVideo: If `true`, the call can include video.
    ///   - completion: A closure that is executed once the call is allowed or disallowed by the system.
    @objc public func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((Error?) -> Void)? = nil) {
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = hasVideo

        // Report the incoming call to the system.
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            /*
             Only add an incoming call to an app's list of calls if it's allowed, i.e., there is no error.
             Calls may be denied for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                let call = SinchVoip.sharedInstance!.call

                self.callManager.setCurrentCall(call: call!, uuid: uuid)
            }

            completion?(error)
        }
    }
    
    
    @objc public func receivedCall(call: SINCall){
        print("SinchVoip:: received call with SinchId: \(call.callId!) and set with CallKit id: \(UUID.init(uuidString: call.callId)!.uuidString)")
        self.callManager.setCurrentCall(call: call, uuid: UUID.init(uuidString: call.callId)!)
    }
    
    @objc public func didReceivedEndCall(call: SINCall){
        self.provider.reportCall(with: callManager.getCurrentCall()!.callKitUUID, endedAt: call.details.endedTime, reason: CXCallEndedReason.remoteEnded)
        call.hangup()
        callManager.deleteCurrentCall()
    }

    @objc public func reportIncomingCallFromPush(uuid: UUID, handle: String, hasVideo: Bool = false, userDisplayName: String ,completion: ((Error?) -> Void)? = nil){
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: userDisplayName)
        update.hasVideo = hasVideo

        // Report the incoming call to the system.
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            /*
             Only add an incoming call to an app's list of calls if it's allowed, i.e., there is no error.
             Calls may be denied for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                if let call = SinchVoip.sharedInstance?.call {
                    self.callManager.setCurrentCall(call: call, uuid: uuid)
                } else {
                    print("SinchVoip:: No call to set :(")
                }
            }

            completion?(error)
        }
    }
    
}


// MARK: - CXProviderDelegate
@available(iOS 10.0, *)
extension CallProviderDelegate: CXProviderDelegate {
    public func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
         
        // stopAudio()
        
        callManager.getCurrentCall()?.sinCall.hangup()
        callManager.deleteCurrentCall()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Create and configure an instance of SpeakerboxCall to represent the new outgoing call.
        print("SinchVoip:: Callkit start action trigger with callkit id: \(action.callUUID)")
        SinchVoip.sharedInstance!.callUserWithIdUsingVideo(userId: action.handle.value)
        let call = SinchVoip.sharedInstance!.call
        
        if call != nil {
//            call!.delegate = SinchVoip.sharedInstance
            action.fulfill()
            callManager.setCurrentCall(call: call!, uuid: action.callUUID)
        } else {
            action.fail()
        }
    }
    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("SinchVoip:: Callkit answer trigger with callkit id: \(action.callUUID)")
        guard let call = callManager.getCurrentCall() else {
            action.fail()
            return
        }
        action.fulfill()
        call.sinCall.answer()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("SinchVoip:: Callkit end trigger for id: \(action.callUUID)")
        guard let call = callManager.getCurrentCall() else {
            action.fail()
            return
        }
        
        call.sinCall.hangup()
        action.fulfill()
        callManager.deleteCurrentCall()
    }
    
    public func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out", #function)

        // React to the action timeout if necessary, such as showing an error UI.
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Mute the sinch client
        SinchVoip.sharedInstance!.audioController?.mute()
        action.fulfill()
    }
    
    
}
