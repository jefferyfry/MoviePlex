//
//  JBFMovieSearchListingViewController.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JBFMovieSearchListingViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>

@property (strong,nonatomic) NSArray *movies;

-(void)reloadData;

@end
