//
//  JBFVideoSearchListingViewController.h
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JBFVideoListingViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>

@property (strong,nonatomic) NSArray *videos;

-(void)reloadData;

@end
