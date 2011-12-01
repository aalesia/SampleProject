//
//  URLRequest.m
//  URLRequest
//
//  Created by Anthony Alesia on 9/28/11.
//  Copyright 2011 VOKAL. All rights reserved.
//

#import "URLRequest.h"
#import "JSONKit.h"

#define DEBUG_MODE  DEBUG
#define TIMEOUT     30.0

@implementation URLRequest

@synthesize delegate;
@synthesize successSelector;
@synthesize failureSelector;
@synthesize connection;

- (id)initWithDelegate:(id <URLRequestDelegate>)_delegate successSelector:(SEL)_successSelector failureSelector:(SEL)_failureSelector 
{
    [self setDelegate:_delegate];
    [self setSuccessSelector:_successSelector];
    [self setFailureSelector:_failureSelector];
    return self;
}

- (void)makeRequestWithURL:(NSString *)urlString type:(URLRequestType)requestType parameters:(NSString *)params isJSON:(BOOL)isJSON 
{

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    apiCallDuration = [NSDate timeIntervalSinceReferenceDate];
    isResponseData = NO;
    
    if (requestType == URLRequestGet && [params length] > 0) {
        urlString = [NSString stringWithFormat:@"%@?%@", urlString, params];
    }
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:TIMEOUT];
    [request setHTTPShouldHandleCookies:NO];
#if DEBUG_MODE
    NSLog(@"making request: %@", url);
    NSLog(@"params: %@", params);
#endif
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self setAuthenticationForRequest:request];
    
    switch (requestType) {
        case URLRequestGet:
            break;
        case URLRequestPost:
            [self postRequest:request
               withParameters:params 
                       isJSON:isJSON];
            break;
        case URLRequestPut:
            [self putRequest:request
              withParameters:params 
                      isJSON:isJSON];
            break;
        case URLRequestDelete:
            [self deleteForRequest:request 
                    withParameters:params 
                            isJSON:isJSON];
            break;
    }
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        NSLog(@"No Connection");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [(NSObject *)delegate performSelector:failureSelector withObject:
         [NSDictionary dictionaryWithObjectsAndKeys:URL_ERROR_CODE, @"error_code", URL_ERROR_CONNECTION, @"error_message", nil]];
    } else {
        mutableData = [[NSMutableData alloc] init];
        
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
}

- (void)makeRequestForDataWithUrl:(NSString *)urlString
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    apiCallDuration = [NSDate timeIntervalSinceReferenceDate];
    isResponseData = YES;
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:TIMEOUT];
    [request setHTTPShouldHandleCookies:NO];
#if DEBUG_MODE
    NSLog(@"making request: %@", url);
#endif
    [self setAuthenticationForRequest:request];
    
    mutableData = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        NSLog(@"No Connection");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [(NSObject *)delegate performSelector:failureSelector withObject:
         [NSDictionary dictionaryWithObjectsAndKeys:URL_ERROR_CODE, @"error_code", URL_ERROR_CONNECTION, @"error_message", nil]];
    } else {
        
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
}

- (void)postPictureToUrl:(NSString *)urlString withData:(NSData *)imageData
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    apiCallDuration = [NSDate timeIntervalSinceReferenceDate];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:TIMEOUT];
    [request setHTTPShouldHandleCookies:NO];
#if DEBUG_MODE
    NSLog(@"making request: %@", url);
#endif
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [self setAuthenticationForRequest:request];
    
    NSString *boundary = [NSString stringWithString:@"14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"profile_photo\"; filename=\"ipodfile.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    mutableData = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        NSLog(@"No Connection");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [(NSObject *)delegate performSelector:failureSelector withObject:
         [NSDictionary dictionaryWithObjectsAndKeys:URL_ERROR_CODE, @"error_code", URL_ERROR_CONNECTION, @"error_message", nil]];
    } else {
        
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
}

- (void)postRequest:(NSMutableURLRequest *)request withParameters:(NSString *)params isJSON:(BOOL)isJSON 
{
    [self setRequestParameters:params
                    forRequest:request 
                        isJSON:isJSON];
    [request setHTTPMethod:@"POST"];
}

- (void)putRequest:(NSMutableURLRequest *)request withParameters:(NSString *)params isJSON:(BOOL)isJSON
{
    [self setRequestParameters:params
                    forRequest:request 
                        isJSON:isJSON];
    [request setHTTPMethod:@"PUT"];
}

- (void)deleteForRequest:(NSMutableURLRequest *)request withParameters:(NSString *)params isJSON:(BOOL)isJSON
{
    [self setRequestParameters:params 
                    forRequest:request 
                        isJSON:isJSON];
    [request setHTTPMethod:@"DELETE"];
}

- (void)setRequestParameters:(NSString *)params forRequest:(NSMutableURLRequest *)request isJSON:(BOOL)isJSON
{
    if (isJSON) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    } else {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        params = [params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSData *requestData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *requestLength = [NSString stringWithFormat:@"%d", [requestData length]];
    [request setValue:requestLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:requestData];
}

- (void)setAuthenticationForRequest:(NSMutableURLRequest *)request 
{
    return;
}

- (void)showCallDuration 
{
#if DEBUG_MODE
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - apiCallDuration;
    int seconds = fmod(duration , 60);
    int mseconds = fmod(duration * 10, 10);
    NSLog(@"Call time: %d.%d", seconds, mseconds);
#endif
}

#pragma mark NSURLConnection Delegate methods

/*
 Disable caching so that each time we run this app we are starting with a clean slate. You may not want to do this in your application.
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}
// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [(NSObject *)delegate performSelector:failureSelector withObject:
     [NSDictionary dictionaryWithObjectsAndKeys:URL_ERROR_CODE, @"error_code", URL_ERROR_CONNECTION, @"error_message", nil]];
    done = YES;
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([httpResponse statusCode] >= 400) {
        error = YES;
        
        if ([httpResponse statusCode] == 401) {
            is401 = YES;
        }
        
#if DEBUG_MODE
        NSLog(@"remote url returned error %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
#endif
    } 
    
    [mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    [mutableData appendData:data];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection 
{
    return YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
#if DEBUG_MODE
    NSLog(@"Show completed web call duration");
    [self showCallDuration];
#endif
    
    done = YES;
    
    if (is401) {
        [(NSObject *)delegate performSelector:failureSelector withObject:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return;
    }
    
    id result;
    
    if (!isResponseData) {
        JSONDecoder *decoder  = [JSONDecoder decoder];
        
        result = [decoder objectWithData:mutableData];
    } else if (isResponseData && [mutableData length] > 0) {
        [(NSObject *)delegate performSelector:successSelector withObject:[NSData dataWithData:mutableData]];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [mutableData release];
        return;
    } else {
        [(NSObject *)delegate performSelector:failureSelector withObject:
         [NSDictionary dictionaryWithObjectsAndKeys:URL_ERROR_CODE, @"error_code", URL_ERROR_CONNECTION, @"error_message", nil]];
    }
    
    if ([mutableData length] > 0 && ![result isKindOfClass:[NSNull class]] && !error && !isResponseData) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            if (![result objectForKey:@"error_code"]) {
                [(NSObject *)delegate performSelector:successSelector withObject:result];
            } else {
                [(NSObject *)delegate performSelector:failureSelector withObject:result];
            }
        } else {
            [(NSObject *)delegate performSelector:successSelector withObject:result];
        }
    } else if (!isResponseData) {
        if (!error) {
            [(NSObject *)delegate performSelector:successSelector withObject:result];
        } else {
            if (result != nil) {
                [(NSObject *)delegate performSelector:failureSelector withObject:result];
            } else {
                [(NSObject *)delegate performSelector:failureSelector withObject:
                 [NSDictionary dictionaryWithObjectsAndKeys:URL_ERROR_CODE, @"error_code", URL_ERROR_CONNECTION, @"error_message", nil]];
            }
        }
    }
    
#if DEBUG_MODE
    if (!isResponseData) {
        NSLog(@"Result: %@", result);
    }
    NSLog(@"Data size: %d", [mutableData length]);
    NSLog(@"Show completed web call duration plus JSON parsing");
    [self showCallDuration];
#endif
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [mutableData release];
}

- (void)dealloc 
{
    [connection release];
    [super dealloc];
}

#pragma mark - class methods

+ (NSString *)getStringForParameters:(NSDictionary *)params 
{
    NSMutableString *parameterUrl = [[[NSMutableString alloc]init] autorelease];
    
    for (NSString *key in [params allKeys]) {
        [parameterUrl appendFormat:@"%@=%@", key, [params objectForKey:key]];
        
        if (key != [[params allKeys] lastObject]) {
            [parameterUrl appendFormat:@"&"];
        }
    }
    
    return parameterUrl;
}

+ (NSString *)urlEncodedString:(NSString *)string 
{
    NSString *escaped = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
    escaped = [escaped stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\t" withString:@"%09"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\n" withString:@"%0A"];
    return escaped;
}

+ (NSString *)urlDecodeString:(NSString *)string 
{
    NSString *escaped = string;
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3B" withString:@";"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%40" withString:@"@"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%09" withString:@"\t"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3C" withString:@"<"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%3E" withString:@">"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%22" withString:@"\""];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"%0A" withString:@"\n"];
    return escaped;
}

#pragma mark - Base64 encoding

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
    unsigned triad;
    
    for (triad = 0; triad < s_len; triad += 3)
    {
        unsigned long int sr;
        unsigned byte;
        
        for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
        {
            sr <<= 8;
            sr |= (*(src+triad+byte) & 0xff);
        }
        
        sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
        
        if (d_len < 4) return 1; /* error - dest too short */
        
        *(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
        switch(byte)
        {
            case 3:
                *(dst+3) = base64[sr&0x3f];
                sr >>= 6;
            case 2:
                *(dst+2) = base64[sr&0x3f];
                sr >>= 6;
            case 1:
                *(dst+1) = base64[sr&0x3f];
                sr >>= 6;
                *(dst+0) = base64[sr&0x3f];
        }
        dst += 4; d_len -= 4;
    }
    
    return 0;
    
}

@end
