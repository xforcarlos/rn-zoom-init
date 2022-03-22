//
//  ZoomManager.m
//  zsdkNative
//
//  Created by Mahmoud Hamdy on 22/03/2022.
//


#import <Foundation/Foundation.h>

#import "ZoomManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

static ZoomManager *sharedInstance = nil;

@implementation ZoomManager

+ (ZoomManager *)sharedInstance {
  if (sharedInstance == nil) {
    sharedInstance = [[super allocWithZone:NULL] init];
  }
  
  return sharedInstance;
}


- (NSString*) requestZAK:(NSString*)userId
               withJwtAccessToken:(NSString*)jwtAccessToken
               withJwtApiKey:(NSString*)jwtApiKey
{

  NSString* accesstoken = [self createJWTAccessToken:jwtAccessToken withAJwtApiSecret:jwtApiKey];

  NSString * bodyString = [NSString stringWithFormat:@"token?type=%@&access_token=%@", @"zak", accesstoken];
  NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@",@"https://api.zoom.us/v2/users",userId,bodyString];
  urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  NSLog(@"urlString = %@",urlString);

  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
  [mRequest setHTTPMethod:@"GET"];

  NSData *resultData = [NSURLConnection sendSynchronousRequest:mRequest returningResponse:nil error:nil];
  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:nil];

  return [dictionary objectForKey:@"token"];
}


- (NSString*)createJWTAccessToken: (NSString *)jwtApiKey withAJwtApiSecret:(NSString *)jwtApiSecret
{

  NSMutableDictionary * dictHeader = [NSMutableDictionary dictionary];
  [dictHeader setValue:@"HS256" forKey:@"alg"];
  [dictHeader setValue:@"JWT" forKey:@"typ"];
  NSString * base64Header = [self base64Encode:[self dictionaryToJson:dictHeader]];

  NSMutableDictionary * dictPayload = [NSMutableDictionary dictionary];
  [dictPayload setValue:jwtApiKey forKey:@"iss"];
  [dictPayload setValue:@"123456789101" forKey:@"exp"];
  NSString * base64Payload = [self base64Encode:[self dictionaryToJson:dictPayload]];

  NSString * composer = [NSString stringWithFormat:@"%@.%@",base64Header,base64Payload];
  NSString * hashmac = [self hmac:composer withKey:jwtApiSecret];

  NSString * accesstoken = [NSString stringWithFormat:@"%@.%@.%@",base64Header,base64Payload,hashmac];
  return accesstoken;
}


- (NSString *)dictionaryToJson:(NSMutableDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData == nil)
    {
        return nil;
    }
    else
    {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

/*
 * Hmac AlgSHA256 Encryption.
 */
- (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString * hash = [HMAC base64Encoding];
    return hash;
}

- (NSString *)base64Encode:(NSString*)decodeString
{
    NSData *encodeData = [decodeString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];

    NSMutableString *mutStr = [NSMutableString stringWithString:base64String];
    NSRange range = {0,base64String.length};
    [mutStr replaceOccurrencesOfString:@"=" withString:@"" options:NSLiteralSearch range:range];

    return mutStr;
}

@end

