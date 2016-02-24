//
//  JBFWindowController.h
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JBFMovieSyncer.h"
#import "JBFMovieListingViewController.h"

@interface JBFMovieListingWindowController : NSWindowController <JBFMovieSyncerDelegate>

-(void)loadMovies;

@end
