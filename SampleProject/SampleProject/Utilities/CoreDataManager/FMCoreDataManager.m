//
//  FMCoreDataManager.m
//  Fooda
//
//  Created by Anthony Alesia on 5/9/11.
//  Copyright 2011 VOKAL. All rights reserved.
//

#import "FMCoreDataManager.h"

#define CD_DEBUG    0

@implementation FMCoreDataManager

@dynamic managedObjectModel;
@dynamic persistentStoreCoordinator;
@dynamic managedObjectContext;

- (id)init
{
	if ((self = [super init])) {
        coreDataQueue = dispatch_queue_create( "com.coredata.vokal.sample", NULL );
	}
	return self;
}

- (void)dealloc {
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    
    dispatch_release(coreDataQueue);
    
    [super dealloc];
}

#pragma mark - CDMethods

- (id)addObjectForType:(CDType)cdType context:(NSManagedObjectContext *)context 
{
    //dispatch_sync(coreDataQueue, ^{
    newObject = [NSEntityDescription insertNewObjectForEntityForName:[self getEntityNameForType:cdType] 
                                              inManagedObjectContext:context];;
    //}); 
    
    return newObject;
}

- (NSArray *)arrayForType:(CDType)cdType 
{
    return [self arrayForType:cdType forContext:self.managedObjectContext];
}

- (NSArray *)arrayForType:(CDType)cdType forContext:(NSManagedObjectContext *)context
{
    dispatch_sync(coreDataQueue, ^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:[self getEntityNameForType:cdType]
                                                  inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:entity];
        
        objectArray = [context executeFetchRequest:fetchRequest error:nil];
    });
    
    return objectArray;
}

- (NSArray *)arrayForType:(CDType)cdType withPredicate:(NSPredicate *)predicate forContext:(NSManagedObjectContext *)context
{
    //dispatch_sync(coreDataQueue, ^{
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self getEntityNameForType:cdType]
                                              inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    objectArray = [context executeFetchRequest:fetchRequest error:nil];
    //});
    
    return objectArray;
}

- (NSArray *)arrayForSet:(NSSet *)set sortKey:(NSString *)sortKey ascending:(BOOL)ascending 
{
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortKey
                                                                                      ascending:ascending]];
    return [set sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)deleteObject:(id)object 
{
    //dispatch_sync(coreDataQueue, ^{
    [[(NSManagedObject *)object managedObjectContext] deleteObject:(NSManagedObject *)object];
    //});
}

- (NSString *)getEntityNameForType:(CDType)cdType
{
    switch (cdType) {
        case CDContact:
            return @"Contact";
    }
    
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)saveContext
{
    UIApplication*    app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_sync(coreDataQueue, ^{
        
        [self saveContext:self.managedObjectContext];
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}   

- (void)saveContext:(NSManagedObjectContext *)managedObjectContex
{
    NSError *error = nil;
    if (managedObjectContex != nil)
    {
#if CD_DEBUG        
        NSLog(@"Has Context");
#endif
        if ([managedObjectContex hasChanges] && ![managedObjectContex save:&error])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CORE_DATA_CRASH];
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
#if CD_DEBUG 
    NSLog(@"Context Saved");
#endif
}

- (void)saveTempContext:(NSManagedObjectContext *)tempContext
{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tempContextSaved:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:tempContext];
        
        [self saveContext:tempContext];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:tempContext];
        
}

- (void)tempContextSaved:(NSNotification *)notification 
{
    /* Merge the changes into the original managed object context */
    UIApplication*    app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_sync(coreDataQueue, ^{
        id mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        [self.managedObjectContext setMergePolicy:mergePolicy];
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        
         if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
             [mergePolicy release];
         }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DATA_UPDATED
                                                            object:nil];
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)resetCoreData 
{
#if CD_DEBUG
    NSLog(@"Clearing Core Data");
#endif
    NSArray *stores = [persistentStoreCoordinator persistentStores];
    
    for(NSPersistentStore *store in stores) {
        [persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
}

- (NSManagedObjectContext *)startTransaction
{
    return [self tempManagedObjectContext];
}

- (void)endTransactionForContext:(NSManagedObjectContext *)context
{
    if ([context hasChanges]) {
        [self saveTempContext:context];
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    }
    return managedObjectContext;
}

- (NSManagedObjectContext *)tempManagedObjectContext 
{
    NSManagedObjectContext *tempManagedObjectContext = nil;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        tempManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
        [tempManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return tempManagedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TestProject" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TestProject.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:CORE_DATA_CRASH];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
