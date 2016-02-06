//
//  JBFMovieTableCellView.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JBFMovieTableCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *yearTextField;
@property (weak) IBOutlet NSTextField *mpaaTextField;
@property (weak) IBOutlet NSTextField *runtimeTextField;
@property (weak) IBOutlet NSTextField *castTextField;
@property (weak) IBOutlet NSImageView *thumbnailImage;
@property IBOutlet NSTextView *synopsisTextView;

@end
