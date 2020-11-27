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
@objc(SinchVoipCallKitProvider)
public final class SinchVoipCallKitProvider: NSObject, CXProviderDelegate {
    
    let sinchClient: SINClient? = SinchVoip.sharedInstance.client;
    private let provider: CXProvider;
    var reportedCallKitCallIds: Set<String> = Set<String>();
    var sinCallIdsToCallKitIds: Dictionary<String, UUID> = Dictionary.init();
    var calls: Dictionary<String, SINCall> = Dictionary.init();
    
    @objc override init() {
        self.provider = CXProvider(configuration: type(of: self).providerConfiguration);
        super.init()
        
        provider.setDelegate(self, queue: nil)
  
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "BackStage")
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        
        return providerConfiguration
    }
    
    func hasReportedCall(callUUID: String) -> Bool {
        return reportedCallKitCallIds.contains(callUUID)
    }
    
    func addReportedCall(callUUID: String){
        reportedCallKitCallIds.insert(callUUID)
    }
    
    // MARK: CXProviderDelegate
    
     public func providerDidReset(_ provider: CXProvider) {
         //
     }
    
    func reportNewIncomingCallWithNotification(notification: SINCallNotificationResult){
        let callId = UUID.init()
        
        self.addReportedCall(callUUID: callId.uuidString)
        sinCallIdsToCallKitIds[notification.callId] = callId
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: notification.remoteUserId)
        update.hasVideo = notification.isVideoOffered
        
        provider.reportNewIncomingCall(with: callId, update: update) { error in
            if error != nil {
                self.hangupCallWithId(uuid: notification.callId)
                print("Error")
            }
        }
    }
    
    func callWithId(uuid: String) -> SINCall{
        return calls[uuid]!
    }
    
    func hangupCallWithId(uuid: String){
        callWithId(uuid: uuid).hangup()
    }
    
    // MARK: Incoming call
    @objc public func didReceivedPush(payload: [AnyHashable : Any]){
        let notification = SINPushHelper.queryPushNotificationPayload(payload)

        if notification!.isCall() {
            let callNotification = notification!.call()
            
            if !hasReportedCall(callUUID: callNotification!.callId){
                self.reportNewIncomingCallWithNotification(notification: callNotification!)
            }
        }
    }
    
    
}

