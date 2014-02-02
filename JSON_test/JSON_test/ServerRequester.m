//
//  ServerRequester.m
//  JSON_test
//
//  Created by Liu Weilong on 2/2/14.
//  Copyright (c) 2014 Liu Weilong. All rights reserved.
//

#import "ServerRequester.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import "ServerRequester.h"
@interface ServerRequester() {
	float timeOutInterval;
	bool canceled;
	int selfIndex;
	int retries;
}
@property (nonatomic, strong) NSURLConnection*		conn;
@property (nonatomic, strong) NSMutableData*		receivedData;
@property (nonatomic, strong) NSString*				pageURLString;
@property (nonatomic, strong) NSMutableDictionary*	postVariables;

@property (nonatomic, readwrite, assign)	id		failureTarget;
@property (nonatomic, readwrite, assign)	SEL		failureSelector;

@property (nonatomic, readwrite, assign)	id		loadedTarget;
@property (nonatomic, readwrite, assign)	SEL		loadedSelector;

@property (nonatomic, readwrite, assign)	id		serverDidReceiveTarget;
@property (nonatomic, readwrite, assign)	SEL		serverDidReceiveSelector;

@property (nonatomic, strong) ServerRequester* selfReference;

@end

@implementation ServerRequester

@synthesize conn, receivedData, pageURLString, postVariables, result, failureTarget, failureSelector, loadedTarget, loadedSelector, serverDidReceiveTarget, serverDidReceiveSelector, selfReference;

+(id)serverRequestWithURLString:(NSString *)urlString postVariables:(NSMutableDictionary *)postDictionary timeOutInterval:(float)timeOutInterval retries:(int)retries {
	return [[self alloc]initServerRequestWithURLString:urlString postVariables:postDictionary timeOutInterval:timeOutInterval retries:retries];
}
+(id)serverRequestWithURLString:(NSString *)urlString postVariables:(NSMutableDictionary *)postDictionary timeOutInterval:(float)timeOutInterval {
	return [[self alloc]initServerRequestWithURLString:urlString postVariables:postDictionary timeOutInterval:timeOutInterval retries:0];
}
-(id)initServerRequestWithURLString:(NSString *)urlString postVariables:(NSMutableDictionary *)postDictionary timeOutInterval:(float)t retries:(int)r {
	if (self=[super init]) {
		pageURLString = urlString;
		postVariables = postDictionary;
		timeOutInterval = t;
		canceled = FALSE;
		selfReference = self;
		retries = r;
	}
	return self;
}
-(void)setOnFailSelector:(id)target selector:(SEL)selector {
	failureTarget = target;
	failureSelector = selector;
}
-(void)setOnLoadedSelector:(id)target selector:(SEL)selector {
	loadedTarget = target;
	loadedSelector = selector;
}
-(void)setOnServerDidReceiveSelector:(id)target selector:(SEL)selector {
	serverDidReceiveTarget = target;
	serverDidReceiveSelector = selector;
}
- (void) makeRequest
{
	//NSLog(@"Making Server Request");
	
	NSURL *url = [NSURL URLWithString:pageURLString];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:timeOutInterval];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"]; //add gzip-encoding to HTTP header
	
	NSMutableString* postString = [NSMutableString string];
	BOOL first = TRUE;
	for (NSString * aKey in postVariables)
	{
		if (first) first = FALSE;
		else [postString appendString:@"&"];
		[postString appendFormat:@"%@=%@",
		 [self URLEncodedString_ch: aKey], [self URLEncodedString_ch :(NSString* )[postVariables objectForKey:aKey]]
		 ];
	}
	NSData *postData = [ NSData dataWithBytes: [postString UTF8String] length: [postString length] ];
	[req setHTTPMethod: @"POST" ];
	[req setHTTPBody: postData ];
	
	
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	if (conn) {
		receivedData = [NSMutableData data];
	} else {
		// inform the user that the download could not be made
		if(!canceled) {
			SuppressPerformSelectorLeakWarning( [failureTarget performSelector:failureSelector withObject:self]; );
		}
	}
	
}
- (void)connection :(NSURLConnection *)connection didReceiveResponse :(NSURLResponse *)response
{
	// this method is called when the server has determined that it
	// has enough information to create the NSURLResponse
	
	// it can be called multiple times, for example in the case of a
	// redirect, so each time we reset the data.
	// receivedData is declared as a method instance elsewhere
	SuppressPerformSelectorLeakWarning( [serverDidReceiveTarget performSelector:serverDidReceiveSelector withObject:self]; );
	[receivedData setLength:0];
}

- (void)connection :(NSURLConnection *)connection didReceiveData :(NSData *)data
{
	// append the new data to the receivedData
	// receivedData is declared as a method instance elsewhere
	[receivedData appendData:data];
}

- (void)connection :(NSURLConnection *)connection didFailWithError :(NSError *)error
{
	if(!canceled) {
		SuppressPerformSelectorLeakWarning( [failureTarget performSelector:failureSelector withObject:self]; );
	}
	// inform the user
	//NSLog(@"Connection Failed!");
	
	if (retries>0) {
		retries--;
		[self makeRequest];
	} else {
		[self kill];
	}
}

- (void) connectionDidFinishLoading :(NSURLConnection *)connection
{
	// do something with the data
	// receivedData is declared as a method instance elsewhere
	//NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	//HERE IS WHERE YOU CAN USE THE MAGIC ON THE DATA... remember to check if the interface is stil there!!
	result = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	if(!canceled) {
		SuppressPerformSelectorLeakWarning( [loadedTarget performSelector:loadedSelector withObject:self]; );
	}
    
	[self kill];
}
-(void)stopRequest {
	[conn cancel];
	canceled = TRUE;
	
	[self kill];
}
-(void)kill{
	selfReference = nil;
}


- (NSString *) URLEncodedString_ch :(NSString*) sourceString {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[sourceString UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"%20"]; // should be + sometimes
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
