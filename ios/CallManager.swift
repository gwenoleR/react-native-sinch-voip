//
//  CallManager.swift
//  RNSinchVoip
//
//  Created by Gwenole on 24/11/2020.
//

import Foundation
import CallKit
import Sinch

class Call: NSObject {
    var sinCall: SINCall?
    var callKitUUID: UUID
    
    init(sinCall: SINCall?, callKitUUID: UUID){
        self.sinCall = sinCall ?? nil
        self.callKitUUID = callKitUUID
        super.init()
    }
}

@available(iOS 10.0, *)
@objc(CallManager)
public final class CallManager: NSObject {
    static let sharedInstance = CallManager()
    
    private override init(){
        super.init()
    }
    
    
    let callController = CXCallController()
    
    // MARK: - Actions

    /// Starts a new call with the specified handle and indication if the call includes video.
    /// - Parameters:
    ///   - handle: The caller's phone number.
    ///   - video: Indicates if the call includes video.
    @objc (startCall:video:)
    func startCall(handle: String, video: Bool = false) {
        print("SinchVoip::Starting call to: \(handle)")
        let handle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        
        print("SinchVoip::CallKit uuid: \(startCallAction.callUUID)")

        startCallAction.isVideo = video
        
        let transaction = CXTransaction()
        transaction.addAction(startCallAction)

        requestTransaction(transaction)
    }
    
    func getUUIDFrom(sinCall: SINCall) -> UUID {
        return UUID.init(uuidString: sinCall.callId!)!
    }
    
    /// Ends the specified call.
    /// - Parameter call: The call to end.
    func end(call: Call) {
        print("SinchVoip::End call uuid \(getUUIDFrom(sinCall: call.sinCall!)) with CallKit id : \(call.callKitUUID)")
        let endCallAction = CXEndCallAction(call:call.callKitUUID)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)

        requestTransaction(transaction)
    }

    /// Sets the specified call's on hold status.
    /// - Parameters:
    ///   - call: The call to update on hold status for.
    ///   - onHold: Specifies whether the call should be placed on hold.
    func setOnHoldStatus(for call: Call, to onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.callKitUUID, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)

        requestTransaction(transaction)
    }
    
    /// Requests that the actions in the specified transaction be asynchronously performed by the telephony provider.
    /// - Parameter transaction: A transaction that contains actions to be performed.
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("SinchVoip::Error requesting transaction:", error.localizedDescription)
            } else {
                print("SinchVoip::Requested transaction successfully")
            }
        }
    }
    
    // MARK: - Call Management
    
    private var currentCall: Call? = nil
    
    func getCurrentCall() -> Call? {
        return currentCall
    }
    
    func setCurrentCall(call: SINCall?, uuid: UUID) {
        print("SinchVoip:: Set current call with SinchId: \(call?.callId!) and CallKit ID: \(uuid.uuidString)")
        currentCall = Call(sinCall: call, callKitUUID: uuid)
    }
    
    func deleteCurrentCall() {
        currentCall = nil
    }
}
