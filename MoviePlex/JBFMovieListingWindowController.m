//
//  JBFWindowController.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieListingWindowController.h"
#import "JBFCoreDataStack.h"
@import CoreData;

@interface JBFMovieListingWindowController ()

@property JBFMovieListingViewController *movieSearchListingViewController;
@property (weak) IBOutlet NSSearchField *movieSearchField;
@property (weak) IBOutlet NSSegmentedControl *sortField;
@property (weak) IBOutlet NSSegmentedControl *filterField;

-(void)loadMovies;

@end

@implementation JBFMovieListingWindowController

- (id)init
{
    self = [super initWithWindowNibName:NSStringFromClass(self.class)];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setTitle:@"MoviePlex"];
    self.movieSearchListingViewController = [JBFMovieListingViewController new];
    self.movieSearchListingViewController.view.frame = [self.window.contentView bounds];
    self.movieSearchListingViewController.view.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    [self.window.contentView addSubview:self.movieSearchListingViewController.view];
    
    [self.sortField setSelectedSegment:0];
    
    [self.filterField setSelectedSegment:0];
    
    //load core data movies into array
    [self loadMovies];
}

-(void)loadMovies {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //load movies from core data into array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Movie"];
    
    NSString *searchText = [self.movieSearchField.stringValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    if(([searchText length] > 2) && (self.filterField.selectedSegment==1)){ //search query plus filter downloaded==NO
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[c] %@ OR synopsis CONTAINS[c] %@ OR cast CONTAINS[c] %@) AND downloaded == NO", searchText,searchText,searchText];
        [fetchRequest setPredicate:predicate];
    }
    else if(([searchText length] > 2) && (self.filterField.selectedSegment==2)){ //search query plus filter downloaded==YES
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[c] %@ OR synopsis CONTAINS[c] %@ OR cast CONTAINS[c] %@) AND downloaded == YES", searchText,searchText,searchText];
        [fetchRequest setPredicate:predicate];
    }
    else if([searchText length] > 2){ //search query and no filter
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@ OR synopsis CONTAINS[c] %@ OR cast CONTAINS[c] %@", searchText,searchText,searchText];
        [fetchRequest setPredicate:predicate];
    }
    else if(self.filterField.selectedSegment==1){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded == NO"];
        [fetchRequest setPredicate:predicate];
    }
    else if(self.filterField.selectedSegment==2){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded == YES"];
        [fetchRequest setPredicate:predicate];
    }
    
    //handle sorting
    if(self.sortField.selectedSegment==0)
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    else if(self.sortField.selectedSegment==1)
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:NO]];
    else //if(self.sortField.selectedSegment==2)
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uploadDate" ascending:NO]];
    
    NSError *error = nil;
    NSArray *movies = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.movieSearchListingViewController.movies = movies;
    [self.movieSearchListingViewController reloadData];
}

- (IBAction)fireMovieSearch:(id)sender {
    [self loadMovies];
}

- (IBAction)fireMovieSort:(id)sender {
    [self loadMovies];
}

- (IBAction)fireMovieFilter:(id)sender {
    [self loadMovies];
}

-(void)moviesUpdated {
    [self loadMovies];
}

@end
