//
//  CallManager.m
//  RNSinchVoip
//
//  Created by Gwenole on 24/11/2020.
//
#import <React/RCTBridgeModule.h>
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(CallManager, NSObject)

//RCT_EXTERN_METHOD(supportedEvents)

RCT_EXTERN_METHOD(startCall:(NSString*)handle video:(BOOL)video)

@end
