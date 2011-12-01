//
//  ImageUtils.m
//  EmFour
//
//  Created by Paul Tiarks on 6/30/10.
//  Copyright 2010 Vokal Interactive. All rights reserved.
//

#import "ImageUtils.h"

#define TMP NSTemporaryDirectory()


@implementation ImageUtils

+ (void)cacheImage:(NSString *)imageURLString
{
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [[imageURLString componentsSeparatedByString:@"/"] lastObject];
    NSString *uniquePath = [TMP stringByAppendingPathComponent:filename];
	
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath:uniquePath])
    {
        // The file doesn't exist, we should get a copy of it
		
        // Fetch image
        NSData *data = [[[NSData alloc] initWithContentsOfURL:imageURL] autorelease];
        UIImage *image = [[[UIImage alloc] initWithData: data] autorelease];
		//TODO: this looks like a leak of image & data ~wfleming
        
        // Do we want to round the corners?
        // image = [self roundCorners:image];
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([imageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [imageURLString rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound || 
                [imageURLString rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
        else if([imageURLString rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
    }
    //[FlurryAnalytics logEvent:EVENT_PHOTO_DOWNLOAD];
}

+ (UIImage *)getCachedImage:(NSString *)imageURLString
{
    NSString *filename = [[imageURLString componentsSeparatedByString:@"/"] lastObject];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    UIImage *image = nil;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
    else
    {
        // get a new one
        [self cacheImage:imageURLString];
        image = [UIImage imageWithContentsOfFile:uniquePath];
    }
	
    return image;
}


/*
static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (UIImage *) roundCorners: (UIImage*) img
{
    int w = img.size.width;
    int h = img.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    addRoundedRectToPath(context, rect, 20, 20);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    [img release];
    
    return [UIImage imageWithCGImage:imageMasked];
}
*/

@end
