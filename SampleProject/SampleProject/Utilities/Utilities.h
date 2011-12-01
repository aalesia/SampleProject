//
//  Utilities.h
//  TestProject
//
//  Created by Anthony Alesia on 12/1/11.
//  Copyright (c) 2011 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (void)makeCallInBackgroundForBlock:(void (^)(void))block;

@end
