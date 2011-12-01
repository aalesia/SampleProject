//
//  Contact.h
//  TestProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "URLRequest.h"
#import "SampleProjectAppDelegate.h"

#define CONTACT_NAME        @"name"
#define CONTACT_EMAIL       @"email"
#define CONTACT_IMAGEURL    @"imageUrl"

@interface Contact : NSManagedObject <URLRequestDelegate>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * imageUrl;

- (void)syncContacts;

+ (void)addFromArray:(NSArray *)array forContext:(NSManagedObjectContext *)context;
+ (void)addWithParams:(NSDictionary *)params forContext:(NSManagedObjectContext *)context;
+ (void)editWithParams:(NSDictionary *)params forContext:(NSManagedObjectContext *)context;
+ (void)syncWithParams:(NSDictionary *)params forContext:(NSManagedObjectContext *)context;
+ (void)setInformationFromDictionary:(NSDictionary *)params forContact:(Contact *)contact;
+ (BOOL)existsForEmail:(NSString *)email forContext:(NSManagedObjectContext *)context;
+ (Contact *)fetchForEmail:(NSString *)email context:(NSManagedObjectContext *)context;
+ (NSArray *)fetchArray;

@end
