//
//  SinchVoipLocalVideoManager.swift
//
//  Created by Gwenole ROTON on 16/11/2020.

import Foundation
import Sinch

@available(iOS 10.0, *)
@objc(SinchVoipRemoteVideoManager)
class SinchVoipRemoteVideoManager: RCTViewManager {
    static let sharedInstance = SinchVoipRemoteVideoManager()
    
    // Size will be override by the RN style
    var superView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var remoteView: UIView? = nil
    
    override private init() {
        super.init()
    }
    
    override static func requiresMainQueueSetup() -> Bool {
      return true
    }
    
    override func view() -> UIView! {
        let vc = SinchVoip.sharedInstance!.videoController
        
        remoteView = vc?.remoteView()
        
        remoteView?.contentMode = UIView.ContentMode.scaleAspectFill
        remoteView?.backgroundColor = .darkGray

        superView.addSubview(remoteView!)
        
        return superView
    }
}
