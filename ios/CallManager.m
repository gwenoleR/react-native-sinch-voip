//
//  CallManager.m
//  RNSinchVoip
//
//  Created by Gwenole on 24/11/2020.
//
#import <React/RCTBridgeModule.h>
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(CallManager, NSObject)

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXTERN_METHOD(startCall:(NSString*)handle video:(BOOL)video)

@end
