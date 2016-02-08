//
//  NSURLConnection+NSURLConnectionAddition.m
//  MoviePlex
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import "NSURLConnection+NSURLConnectionAddition.h"
#import <objc/runtime.h>

static const void *DownloadUrlKey = &DownloadUrlKey;
static const void *UploadDateKey = &UploadDateKey;

@implementation NSURLConnection (NSURLConnectionAddition)

- (void)setDownloadUrl:(NSString *)downloadUrl
{
    objc_setAssociatedObject(self, DownloadUrlKey, downloadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)downloadUrl
{
    return objc_getAssociatedObject(self, DownloadUrlKey);
}

- (void)setUploadDate:(NSString *)uploadDate
{
    objc_setAssociatedObject(self, UploadDateKey, uploadDate, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)uploadDate
{
    return objc_getAssociatedObject(self, UploadDateKey);
}

@end
