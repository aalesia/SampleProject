//
//  ImageUtils.h
//  EmFour
//
//  Created by Paul Tiarks on 6/30/10.
//  Copyright 2010 Vokal Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageUtils : NSObject {

}

+ (void)cacheImage:(NSString *)imageURLString;
+ (UIImage *)getCachedImage:(NSString *)imageURLString;
// + (UIImage *)roundCorners:(UIImage*)img;
@end
