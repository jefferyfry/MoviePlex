//
//  JBFMovieSyncer.h
//  MoviePlex
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFRottenTomatoesMovieSearch.h"
#import "JBFMovie.h"
#import "JBFCoreDataStack.h"

@protocol JBFMovieSyncerDelegate <NSObject>

-(void)moviesUpdated;

@end

@interface JBFMovieSyncer : NSObject <NSURLConnectionDataDelegate,JBFRottenTomatoesMovieSearchDelegate>

@property (weak) id<JBFMovieSyncerDelegate> delegate;

-(void)syncMovies;

@end
