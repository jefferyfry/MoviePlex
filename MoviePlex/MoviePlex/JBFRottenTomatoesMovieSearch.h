//
//  JBFRottenTomatoesMovieSearch.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFMovieSearchResult.h"

@protocol JBFRottenTomatoesMovieSearchDelegate <NSObject>

-(void)startedSearchRequest;

-(void)updateSearchRequestProgress:(double)progress;

-(void)finishedSearchRequest:(JBFMovieSearchResult*)results;

@end

@interface JBFRottenTomatoesMovieSearch : NSObject <NSURLConnectionDataDelegate>

@property (weak) id<JBFRottenTomatoesMovieSearchDelegate> delegate;

-(void)searchForMovie:(NSString*)searchText forNumberOfResults:(NSUInteger)numResults;

@end
