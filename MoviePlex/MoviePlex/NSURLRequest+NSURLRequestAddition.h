//
//  NSURLConnection+NSURLConnectionAddition.h
//  MoviePlex
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (NSURLRequestAddition)

@property (strong, nonatomic) NSString *uploadDate;
@property (strong, nonatomic) NSString *downloadUrl;
@property (strong, nonatomic) NSString *searchText;

@end
