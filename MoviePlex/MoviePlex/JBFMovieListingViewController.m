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
    if(movie.mpaaRating!=nil)
        result.mpaaTextField.stringValue = movie.mpaaRating;
    
    result.yearTextField.stringValue = [NSString stringWithFormat:@"%@",movie.year];
    result.runtimeTextField.stringValue = [NSString stringWithFormat:@"%@ mins",movie.runtime];
    
    if(movie.synopsis!=nil)
        result.synopsisTextView.textContainer.textView.string = movie.synopsis;
    [result.synopsisTextView.textContainer.textView setEditable:NO];
    
    if(movie.cast!=nil)
        result.castTextField.stringValue = movie.cast;
    if(movie.uploadDate!=nil)
        result.uploadDateTextField.stringValue = movie.uploadDate;
    if(movie.releaseDate!=nil)
        result.releaseDateTextField.stringValue = movie.releaseDate;
    
    if(movie.downloadUrl!=nil)
        result.downloadUrl = movie.downloadUrl;
    
    if(movie.thumbnailUrl!=nil){
        NSURL *imageUrl = [NSURL URLWithString:movie.thumbnailUrl];
        result.imageView.image = [[NSImage alloc] initWithContentsOfURL:imageUrl];
    }
    
    [result.imageView setImageFrameStyle:NSImageFrameNone];
    
    
    //NSLog(@"Created table row %ld",(long)row);
    return result;
}

-(void)reloadData {
    [self.movieSearchResultsTableView reloadData];
}

@end
