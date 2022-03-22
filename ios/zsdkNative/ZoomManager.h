//
//  ZoomManager.h
//  zsdkNative
//
//  Created by Mahmoud Hamdy on 22/03/2022.
//
#import <Foundation/Foundation.h>

@interface ZoomManager : NSObject

+ (ZoomManager *)sharedInstance;

- (NSString*) requestZAK: (NSString*)userId withJwtAccessToken:(NSString*)jwtAccessToken withJwtApiKey:(NSString*)jwtApiKey;

@end
