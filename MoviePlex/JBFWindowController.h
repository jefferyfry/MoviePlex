//
//  JBFWindowController.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JBFRottenTomatoesMovieSearch.h"
#import "JBFMovieSearchListingViewController.h"

@interface JBFWindowController : NSWindowController <JBFRottenTomatoesMovieSearchDelegate>

-(void)submitSearch:(NSString*)text;

@end
