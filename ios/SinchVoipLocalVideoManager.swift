//
//  SinchVoipLocalVideoManager.swift
//
//  Created by Gwenole ROTON on 16/11/2020.

import Foundation
import Sinch

@available(iOS 10.0, *)
@objc(SinchVoipLocalVideoManager)
class SinchVoipLocalVideoManager: RCTViewManager {
    static let sharedInstance = SinchVoipLocalVideoManager()
    
    // Size will be override by the RN style
    var superView = UIView(frame: CGRect(x: 0, y: 0,width: 1, height: 1))
    var localView: UIView? = nil
    
    override private init() {
        super.init()
    }
    
    override static func requiresMainQueueSetup() -> Bool {
      return true
    }
    
    override func view() -> UIView! {
        let vc = SinchVoip.sharedInstance!.videoController
        
        localView = vc?.localView()
        
        localView?.contentMode = UIView.ContentMode.scaleAspectFill
        localView?.backgroundColor = .darkGray

        superView.addSubview(localView!)
        
        return superView
    }
}
