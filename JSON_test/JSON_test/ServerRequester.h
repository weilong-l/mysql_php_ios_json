//
//  ServerRequester.h
//  JSON_test
//
//  Created by Liu Weilong on 2/2/14.
//  Copyright (c) 2014 Liu Weilong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerRequester : NSObject

@property(nonatomic, strong) NSString * result;

+(id)serverRequestWithURLString:(NSString*)urlString	postVariables:(NSMutableDictionary*)postDictionary timeOutInterval:(float)timeOutInterval retries:(int)retries;
+(id)serverRequestWithURLString:(NSString*)urlString	postVariables:(NSMutableDictionary*)postDictionary timeOutInterval:(float)timeOutInterval;
-(void)setOnFailSelector:(id)target				selector:(SEL)selector;
-(void)setOnLoadedSelector:(id)target			selector:(SEL)selector;
-(void)setOnServerDidReceiveSelector:(id)target selector:(SEL)selector;
-(void)makeRequest;
-(void)kill;
-(void)stopRequest;
@end
