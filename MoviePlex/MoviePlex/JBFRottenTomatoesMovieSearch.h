//
//  JBFRottenTomatoesMovieSearch.h
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFMovie.h"

@protocol JBFRottenTomatoesMovieSearchDelegate <NSObject>

-(void)finishedSearchRequest:(JBFMovie*)movie;

@end

@interface JBFRottenTomatoesMovieSearch : NSObject <NSURLConnectionDataDelegate>

@property (weak) id<JBFRottenTomatoesMovieSearchDelegate> delegate;

-(void)searchForMovie:(NSString*)searchText withDownloadUrl:(NSString*)downloadUrl withUploadDate:(NSString*)uploadDate;

@end
