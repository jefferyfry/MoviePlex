//
//  JBFMovieSearchListingViewController.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieListingViewController.h"
#import "JBFMovie.h"
#import "JBFMovieTableCellView.h"

@interface JBFMovieListingViewController ()
@property (weak) IBOutlet NSTableView *movieSearchResultsTableView;

@end

@implementation JBFMovieListingViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        
    }
    return self;
}

-(void)loadView {
    [super loadView];
    [self.movieSearchResultsTableView setDataSource:self];
    [self.movieSearchResultsTableView setDelegate:self];
}

//datasource interface
-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(!self.movies)
        return 0;
    else
        return [self.movies count];
    
}

//tableview delegate interface
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    JBFMovie *movie = [self.movies objectAtIndex:row];
    JBFMovieTableCellView *result = [tableView makeViewWithIdentifier:@"movieCell" owner:self];
    if(movie.title!=nil)
        result.titleTextField.stringValue = movie.title;
    else
        result.titleTextField.stringValue = @"N/A";
    
    if(movie.mpaaRating!=nil)
        result.mpaaTextField.stringValue = movie.mpaaRating;
    else
        result.mpaaTextField.stringValue = @"N/A";
    
    if(movie.year!=nil)
        result.yearTextField.stringValue = movie.year;
    else
        result.yearTextField.stringValue = @"N/A";
    
    if(movie.runtime!=nil)
        result.runtimeTextField.stringValue = movie.runtime;
    else
        result.runtimeTextField.stringValue = @"N/A";
    
    if(movie.synopsis!=nil)
        result.synopsisTextField.stringValue = movie.synopsis;
    else
        result.synopsisTextField.stringValue = @"N/A";
    
    if(movie.actors!=nil)
        result.castTextField.stringValue = movie.actors;
    else
        result.castTextField.stringValue = @"N/A";
        
    if(movie.uploadDate!=nil)
        result.uploadDateTextField.stringValue = movie.uploadDate;
    else
        result.uploadDateTextField.stringValue = @"N/A";
        
    if(movie.releaseDate!=nil)
        result.releaseDateTextField.stringValue = movie.releaseDate;
    else
        result.releaseDateTextField.stringValue = @"N/A";
    
    if(movie.downloadUrl!=nil)
        result.downloadUrl = movie.downloadUrl;
    else
        result.downloadUrl = @"N/A";
    
    if(movie.downloaded)
        result.downloadedCheckbox.state = NSOnState;
    else
        result.downloadedCheckbox.state = NSOffState;
    
    if(movie.thumbnailUrl!=nil){
        NSURL *imageUrl = [NSURL URLWithString:movie.thumbnailUrl];
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
    [self.movieSearchResultsTableView reloadData];
}

@end
