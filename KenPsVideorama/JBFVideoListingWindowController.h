//
//  JBFWindowController.h
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JBFVideosSyncer.h"
#import "JBFVideoListingViewController.h"

@interface JBFVideoListingWindowController : NSWindowController <JBFVideosSyncerDelegate>

-(void)loadVideos;

@end
