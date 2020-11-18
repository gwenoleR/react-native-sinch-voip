//
//  SinchVoipLocalVideoManager.swift
//
//  Created by Gwenole ROTON on 16/11/2020.

import Foundation
import Sinch

@objc(SinchVoipRemoteVideoManager)
class SinchVoipRemoteVideoManager: RCTViewManager {
    override static func requiresMainQueueSetup() -> Bool {
      return true
    }
    
    override func view() -> UIView! {
        print(SinchVoip.sharedInstance.client?.videoController()?.remoteView()! ?? "NOTHING TO SHOW")
        let videoView: UIView = (SinchVoip.sharedInstance.client!.videoController()?.remoteView())!
//        videoView.backgroundColor = .blue
        videoView.contentMode = UIView.ContentMode.scaleAspectFit
        
        // Size and position will be override by React Native Style
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 98, height: 130))
        view.addSubview(videoView)
        
        return view
    }
}
