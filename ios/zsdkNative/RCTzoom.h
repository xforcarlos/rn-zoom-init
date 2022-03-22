//
//  RCTzoom.h
//  zsdkNative
//
//  Created by Mahmoud Hamdy on 22/03/2022.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <MobileRTC/MobileRTC.h>

//@interface RCTzoom : NSObject <RCTBridgeModule,MobileRTCMeetingServiceDelegate>

@interface RCTzoom : NSObject <RCTBridgeModule,MobileRTCMeetingServiceDelegate>

@property (nonatomic, copy) RCTPromiseResolveBlock initializePromiseResolve;
@property (nonatomic, copy) RCTPromiseRejectBlock initializePromiseReject;

@end
