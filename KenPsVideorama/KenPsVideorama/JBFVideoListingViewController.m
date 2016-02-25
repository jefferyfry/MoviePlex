//
//  JBFVideoSearchListingViewController.m
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFVideoListingViewController.h"
#import "JBFVideo.h"
#import "JBFVideoTableCellView.h"

@interface JBFVideoListingViewController ()
@property (weak) IBOutlet NSTableView *videoSearchResultsTableView;

@end

@implementation JBFVideoListingViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        
    }
    return self;
}

-(void)loadView {
    [super loadView];
    [self.videoSearchResultsTableView setDataSource:self];
    [self.videoSearchResultsTableView setDelegate:self];
}

//datasource interface
-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(!self.videos)
        return 0;
    else
        return [self.videos count];
    
}

//tableview delegate interface
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    JBFVideo *video = [self.videos objectAtIndex:row];
    JBFVideoTableCellView *result = [tableView makeViewWithIdentifier:@"videoCell" owner:self];
    
    if(video.title!=nil)
        result.titleTextField.stringValue = video.title;
    else
        result.titleTextField.stringValue = @" ";
    
    if(video.mpaaRating!=nil)
        result.mpaaTextField.stringValue = video.mpaaRating;
    else
        result.mpaaTextField.stringValue = @" ";
    
    if(video.year!=nil)
        result.yearTextField.stringValue = video.year;
    else
        result.yearTextField.stringValue = @" ";
    
    if(video.runtime!=nil)
        result.runtimeTextField.stringValue = video.runtime;
    else
        result.runtimeTextField.stringValue = @" ";
    
    if(video.synopsis!=nil)
        result.synopsisTextField.stringValue = video.synopsis;
    else
        result.synopsisTextField.stringValue = @" ";
    
    if(video.actors!=nil)
        result.castTextField.stringValue = video.actors;
    else
        result.castTextField.stringValue = @" ";
        
    if(video.uploadDate!=nil)
        result.uploadDateTextField.stringValue = video.uploadDate;
    else
        result.uploadDateTextField.stringValue = @" ";
        
    if(video.releaseDate!=nil)
        result.releaseDateTextField.stringValue = video.releaseDate;
    else
        result.releaseDateTextField.stringValue = @" ";
    
    if(video.rating!=nil)
        result.ratingTextField.stringValue = [video.rating stringByAppendingString:@"/100"];
    else
        result.ratingTextField.stringValue = @" ";
    
    if(video.downloadUrl!=nil)
        result.downloadUrl = video.downloadUrl;
    else
        result.downloadUrl = @" ";
    
    if(video.downloaded)
        result.downloadedCheckbox.state = NSOnState;
    else
        result.downloadedCheckbox.state = NSOffState;
    
    if(video.thumbnailUrl!=nil){
        NSURL *imageUrl = [NSURL URLWithString:video.thumbnailUrl];
        result.imageView.image = [[NSImage alloc] initWithContentsOfURL:imageUrl];
    }
    else {
        NSString *blankPoster = [[NSBundle mainBundle] pathForResource:@"blank_poster" ofType:@"jpg"];
        result.imageView.image = [[NSImage alloc] initWithContentsOfFile:blankPoster];
    }
    
    [result.imageView setImageFrameStyle:NSImageFrameNone];
    
    
    //NSLog(@"Created table row %ld",(long)row);
    return result;
}

-(void)reloadData {
    [self.videoSearchResultsTableView reloadData];
}

@end
