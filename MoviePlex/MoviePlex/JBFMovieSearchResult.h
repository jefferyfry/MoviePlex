//
//  JBFMovieArray.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBFMovieSearchResult : NSObject

@property (strong,nonatomic) NSMutableArray *moviesArray;
@property (strong,nonatomic) NSString *jsonString;

@end
