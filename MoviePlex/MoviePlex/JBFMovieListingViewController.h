//
//  JBFMovieSearchListingViewController.h
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JBFMovieListingViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>

@property (strong,nonatomic) NSArray *movies;

-(void)reloadData;

@end
