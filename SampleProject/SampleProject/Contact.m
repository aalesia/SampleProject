//
//  Contact.m
//  TestProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@dynamic name;
@dynamic email;
@dynamic imageUrl;

- (void)syncContacts
{
    NSString *url = @"http://192.168.0.143:3000/api/contact";
    
    URLRequest *request = [[URLRequest alloc] initWithDelegate:self
                                               successSelector:@selector(onSyncContactsSuccess:)
                                               failureSelector:@selector(onFailure:)];
    
    [request makeRequestWithURL:url
                           type:URLRequestGet
                     parameters:nil
                         isJSON:NO];
    
    [request release];
}

- (void)onSyncContactsSuccess:(id)response
{
    SampleProjectAppDelegate *appDelegate = (SampleProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate.coreDataManager startTransaction];
    
    [Contact addFromArray:(NSArray *)response forContext:context];
    
    [appDelegate.coreDataManager endTransactionForContext:context];
}

- (void)onFailure:(id)response
{
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (NSDictionary *)response, NOTIFICATION_FAILURE, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAILURE 
                                                            object:nil 
                                                          userInfo:userInfo];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAILURE
                                                            object:nil];
    }
}

#pragma mark - Class Methods

+ (void)addFromArray:(NSArray *)array forContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *dictionary in array) {
        [Contact addWithParams:dictionary forContext:context];
    }
}

+ (void)addWithParams:(NSDictionary *)params forContext:(NSManagedObjectContext *)context
{
    NSString *email = [params objectForKey:CONTACT_EMAIL];
    
    if ([Contact existsForEmail:email forContext:context]) {
        [Contact editWithParams:params forContext:context];
    } else {
        [Contact syncWithParams:params forContext:context];
    }
}

+ (void)editWithParams:(NSDictionary *)params forContext:(NSManagedObjectContext *)context
{
    NSString *email = [params objectForKey:CONTACT_EMAIL];
    Contact *contact = [Contact fetchForEmail:email context:context];
    
    [Contact setInformationFromDictionary:params forContact:contact];
}

+ (void)syncWithParams:(NSDictionary *)params forContext:(NSManagedObjectContext *)context
{
    SampleProjectAppDelegate *appDelegate = (SampleProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Contact *newContact = [appDelegate.coreDataManager addObjectForType:CDContact
                                                                context:context];
    [Contact setInformationFromDictionary:params forContact:newContact];
}

+ (void)setInformationFromDictionary:(NSDictionary *)params forContact:(Contact *)contact
{
    contact.name = [[params objectForKey:CONTACT_NAME] isKindOfClass:[NSNull class]] ? contact.name :
    [params objectForKey:CONTACT_NAME];
    contact.email = [[params objectForKey:CONTACT_EMAIL] isKindOfClass:[NSNull class]] ? contact.email :
    [params objectForKey:CONTACT_EMAIL];
    contact.imageUrl = [[params objectForKey:CONTACT_IMAGEURL] isKindOfClass:[NSNull class]] ? contact.imageUrl :
    [params objectForKey:CONTACT_IMAGEURL];
}

+ (BOOL)existsForEmail:(NSString *)email forContext:(NSManagedObjectContext *)context
{
    return [Contact fetchForEmail:email context:context] != nil;
}

+ (Contact *)fetchForEmail:(NSString *)email context:(NSManagedObjectContext *)context
{
    SampleProjectAppDelegate *appDelegate = (SampleProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
    NSArray *contactArray = [appDelegate.coreDataManager arrayForType:CDContact
                                                        withPredicate:predicate 
                                                           forContext:context];
    
    if ([contactArray count] == 1) {
        return (Contact *)[contactArray lastObject];
    }
    
    return nil;
}

+ (NSArray *)fetchArray
{
    SampleProjectAppDelegate *appDelegate = (SampleProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *contactsArray = [appDelegate.coreDataManager arrayForType:CDContact];
    NSSet *set = [NSSet setWithArray:contactsArray];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    
    return [set sortedArrayUsingDescriptors:sortDescriptors];
}

@end
