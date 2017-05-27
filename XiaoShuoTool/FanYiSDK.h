//
//  FanYiSDK.h
//  FanYiSDK
//
//  Created by 白静 on 11/18/16.
//  Copyright © 2016 网易有道. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YDTranslate;
@class YDTranslateRequest;
@class YDTranslateParameters;

typedef void(^YDTranslateRequestHandler)(YDTranslateRequest *request,
                                         YDTranslate *translte,
                                         NSError *error) ;

@interface YDTranslateRequest : NSObject

@property (nonatomic, strong) YDTranslateParameters *translateParameters;
@property (nonatomic, strong) NSArray *supportLanguages;

+ (YDTranslateRequest *)request;

//查句子
- (void)lookup:(NSString *) input WithCompletionHandler:(YDTranslateRequestHandler)handler;
- (void) initOffline;
- (void) initOfflineWithPath:(NSString *)path;
@end

@class CLLocation;

/**
 * The `YDTranslateParameters` class is used to attach targeting information to
 * `YDTranslateRequest` objects.
 */

@interface YDTranslateParameters : NSObject

/** @name Creating a Targeting Object */

/**
 * Creates and returns an empty YDTranslateParameters object.
 *
 * @return A newly initialized YDTranslateParameters object.
 */
+ (YDTranslateParameters *)targeting;

@property (nonatomic, copy) NSString *source;

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, strong) NSString *from;

@property (nonatomic, strong) NSString *to;

@property (nonatomic, assign) BOOL offLine;

@end

@interface YDTranslate : NSObject

@property (retain,nonatomic)NSString *query;
@property (retain,nonatomic)NSString *usPhonetic;
@property (retain,nonatomic)NSString *ukPhonetic;
@property (retain,nonatomic)NSString *phonetic;

@property (retain,nonatomic)NSArray *translation;
@property (retain,nonatomic)NSArray *explains;
@property (retain,nonatomic)NSArray *webExplains;
@property (retain,nonatomic)NSString *speakurl;
@property (retain,nonatomic)NSString *resultSpeakurl;

@property (assign,atomic)int errorCodes;

- (void)formData;

@end

@interface YDWebExplain : NSObject

@property (retain,nonatomic)NSArray *value;
@property (retain,nonatomic)NSString *key;

- (void)formData:(NSDictionary *) dict;
@end




