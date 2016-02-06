//
//  JBFWindowController.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFWindowController.h"

@interface JBFWindowController ()

@property JBFRottenTomatoesMovieSearch *rottenTomatoesMovieSearch;
@property JBFMovieSearchListingViewController *movieSearchListingViewController;
@property (weak) IBOutlet NSSearchField *movieSearchField;

@end

@implementation JBFWindowController

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
    self.rottenTomatoesMovieSearch = [JBFRottenTomatoesMovieSearch new];
    self.rottenTomatoesMovieSearch.delegate = self;
    self.movieSearchListingViewController = [JBFMovieSearchListingViewController new];
    [self displayViewController:self.movieSearchListingViewController];
}

-(void)submitSearch:(NSString*)text
{
    self.movieSearchField.stringValue=text;
    [self fireMovieSearch:self];
}

- (IBAction)fireMovieSearch:(id)sender {
    NSUInteger numResults = 1;
    
    [self.rottenTomatoesMovieSearch searchForMovie:self.movieSearchField.stringValue forNumberOfResults:numResults];
}

-(void)startedSearchRequest{
    
}

-(void)updateSearchRequestProgress:(double)progress{
    
}

-(void)finishedSearchRequest:(JBFMovieSearchResult*)results{
    self.movieSearchListingViewController.movies = results.moviesArray;
    [self.movieSearchListingViewController reloadData];
}

-(void)displayViewController:(NSViewController*)viewController
{
    [self removeAllSubViews];
    viewController.view.frame = [self.window.contentView bounds];
    viewController.view.autoresizingMask = NSViewHeightSizable |NSViewWidthSizable;
    [self.window.contentView addSubview:viewController.view];
}

-(void)removeAllSubViews
{
    [self.movieSearchListingViewController.view removeFromSuperview];
}

@end
