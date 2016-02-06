//
//  JBFJSON2MovieParser.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFMovieSearchResult.h"

@interface JBFJSON2MovieParser : NSObject

+(JBFMovieSearchResult*)movieSearchResultFromJSONData:(NSData*)data;

@end


