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
@property (weak) IBOutlet NSComboBox *movieSortField;
@property (weak) IBOutlet NSTextField *statusField;

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
    
    //load core data movies into array
    [self loadMovies];
}

-(void)loadMovies {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //load movies from core data into array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Movie"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:NO]];
    
    NSError *error = nil;
    NSArray *movies = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.movieSearchListingViewController.movies = movies;
    [self.movieSearchListingViewController reloadData];
}

-(void)submitSearch:(NSString*)text
{
    self.movieSearchField.stringValue=text;
    [self fireMovieSearch:self];
}

- (IBAction)fireMovieSearch:(id)sender {
    // will search core data
    //update array
}

-(void)moviesUpdated {
    [self loadMovies];
}

@end
