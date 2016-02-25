//
//  JBFvideoTableCellView.h
//  KenPsVideorama
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JBFVideoTableCellView : NSTableCellView <NSURLDownloadDelegate>
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *yearTextField;
@property (weak) IBOutlet NSTextField *mpaaTextField;
@property (weak) IBOutlet NSTextField *runtimeTextField;
@property (weak) IBOutlet NSTextField *castTextField;
@property (weak) IBOutlet NSImageView *thumbnailImage;
@property (weak) IBOutlet NSTextField *releaseDateTextField;
@property (weak) IBOutlet NSTextField *uploadDateTextField;
@property (weak) IBOutlet NSButton *downloadNowButton;
@property (weak) IBOutlet NSButton *downloadedCheckbox;
@property (weak) IBOutlet NSTextField *synopsisTextField;
@property (weak) IBOutlet NSProgressIndicator *downloadProgressIndicator;
@property (weak) IBOutlet NSTextField *downloadLabelField;
@property (nonatomic,strong) NSString *downloadUrl;
@property (weak) IBOutlet NSButton *downloadCancelButton;
@property (weak) IBOutlet NSTextField *ratingTextField;

@end
