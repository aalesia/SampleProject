//
//  URLRequest.h
//  URLRequest
//
//  Created by Anthony Alesia on 9/28/11.
//  Copyright 2011 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define URL_ERROR               @"Error"
#define URL_ERROR_CODE          @"9001"
#define URL_ERROR_CONNECTION    @"No internet connection is available. Please check your network settings and try again."

typedef enum {
    URLRequestGet,
    URLRequestPost,
    URLRequestPut,
    URLRequestDelete,
} URLRequestType;

@protocol URLRequestDelegate
@end

@interface URLRequest : NSObject {
    id<URLRequestDelegate> delegate;
    
    SEL successSelector;
    SEL failureSelector;
    
    NSURLConnection *connection;
    NSMutableData *mutableData;
    BOOL done;
    NSTimeInterval apiCallDuration;
    
    BOOL error;
    BOOL is401;
    BOOL isResponseData;
}

@property (nonatomic) SEL successSelector;
@property (nonatomic) SEL failureSelector;
@property (nonatomic, assign) id<URLRequestDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *connection;

- (id)initWithDelegate:(id <URLRequestDelegate>)_delegate 
       successSelector:(SEL)_successSelector 
       failureSelector:(SEL)_failureSelector;
- (void)makeRequestWithURL:(NSString *)urlString 
                      type:(URLRequestType)requestType 
                parameters:(NSString *)params 
                    isJSON:(BOOL)isJSON;
- (void)postRequest:(NSMutableURLRequest *)request withParameters:(NSString *)params isJSON:(BOOL)isJSON;
- (void)putRequest:(NSMutableURLRequest *)request withParameters:(NSString *)params isJSON:(BOOL)isJSON;
- (void)deleteForRequest:(NSMutableURLRequest *)request withParameters:(NSString *)params isJSON:(BOOL)isJSON;
- (void)setRequestParameters:(NSString *)params forRequest:(NSMutableURLRequest *)request isJSON:(BOOL)isJSON;
- (void)setAuthenticationForRequest:(NSMutableURLRequest *)request;
- (void)postPictureToUrl:(NSString *)urlString withData:(NSData *)imageData;
- (void)showCallDuration;
- (void)makeRequestForDataWithUrl:(NSString *)urlString;

+ (NSString *)getStringForParameters:(NSDictionary *)params;
+ (NSString *)urlEncodedString:(NSString *)string;
+ (NSString *)urlDecodeString:(NSString *)string;

@end
