//
//  FMCoreDataManager.h
//  Fooda
//
//  Created by Anthony Alesia on 5/9/11.
//  Copyright 2011 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SampleProjectAppDelegate.h"

#define CORE_DATA_CRASH             @"CDCrash"

typedef enum {
    CDContact,
} CDType;

@interface FMCoreDataManager : NSObject {
    NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext; 
    
    id newObject;
    NSArray *objectArray;
    dispatch_queue_t coreDataQueue;
    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)saveContext:(NSManagedObjectContext *)managedObjectContex;
- (void)resetCoreData;

- (id)addObjectForType:(CDType)cdType context:(NSManagedObjectContext *)context;
- (void)deleteObject:(id)object;
- (NSArray *)arrayForType:(CDType)cdType;
- (NSArray *)arrayForType:(CDType)cdType forContext:(NSManagedObjectContext *)context;
- (NSArray *)arrayForType:(CDType)cdType withPredicate:(NSPredicate *)predicate forContext:(NSManagedObjectContext *)context;
- (NSArray *)arrayForSet:(NSSet *)set sortKey:(NSString *)sortKey ascending:(BOOL)ascending;
- (NSString *)getEntityNameForType:(CDType)cdType;
- (NSManagedObjectContext *)tempManagedObjectContext;
- (void)saveTempContext:(NSManagedObjectContext *)tempContext;
- (void)tempContextSaved:(NSNotification *)notification;
- (NSManagedObjectContext *)startTransaction;
- (void)endTransactionForContext:(NSManagedObjectContext *)context;

@end
