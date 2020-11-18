//
//  SinchVoipLocalVideoManager.swift
//
//  Created by Gwenole ROTON on 16/11/2020.

import Foundation
import Sinch

@objc(SinchVoipLocalVideoManager)
class SinchVoipLocalVideoManager: RCTViewManager {
    override static func requiresMainQueueSetup() -> Bool {
      return true
    }
    
    override func view() -> UIView! {
        let videoView: UIView = (SinchVoip.sharedInstance.client!.videoController()?.localView())!
        videoView.backgroundColor = .black
        videoView.contentMode = UIView.ContentMode.scaleAspectFit
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 156))
        view.addSubview(videoView)
        
        return view
    }
}
