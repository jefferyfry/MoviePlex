//
//  NSURLConnection+NSURLConnectionAddition.m
//  MoviePlex
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import "NSURLRequest+NSURLRequestAddition.h"
#import <objc/runtime.h>

static const void *DownloadUrlKey = &DownloadUrlKey;
static const void *UploadDateKey = &UploadDateKey;
static const void *SearchTextKey = &SearchTextKey;

@implementation NSURLRequest (NSURLRequestAddition)

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

- (void)setSearchText:(NSString *)searchText
{
    objc_setAssociatedObject(self, SearchTextKey, searchText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)searchText
{
    return objc_getAssociatedObject(self, SearchTextKey);
}

@end
