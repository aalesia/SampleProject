//
//  SampleProjectAppDelegate.h
//  SampleProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright 2011 VOKAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMCoreDataManager.h"

#define NOTIFICATION_DATA_UPDATED   @"data_updated"
#define NOTIFICATION_FAILURE        @"failure"

@class FMCoreDataManager;

@interface SampleProjectAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) FMCoreDataManager *coreDataManager;

@end
