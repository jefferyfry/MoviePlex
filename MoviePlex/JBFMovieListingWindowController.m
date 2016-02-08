//
//  JBFWindowController.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieListingWindowController.h"

@interface JBFMovieListingWindowController ()

@property JBFRottenTomatoesMovieSearch *rottenTomatoesMovieSearch;
@property JBFMovieListingViewController *movieSearchListingViewController;
@property (weak) IBOutlet NSSearchField *movieSearchField;
@property (weak) IBOutlet NSTextField *movieListingUrlField;
@property (weak) IBOutlet NSComboBox *movieSortField;
@property (weak) IBOutlet NSComboBox *movieFilterField;
@property (weak) IBOutlet NSButton *syncNowButton;

@property (strong,nonatomic) NSMutableData *receivedData;

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
    self.rottenTomatoesMovieSearch = [JBFRottenTomatoesMovieSearch new];
    self.rottenTomatoesMovieSearch.delegate = self;
    self.movieSearchListingViewController = [JBFMovieListingViewController new];
    self.movieSearchListingViewController.view.frame = [self.window.contentView bounds];
    self.movieSearchListingViewController.view.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    [self.window.contentView addSubview:self.movieSearchListingViewController.view];
    
    //load core data movies into array
    [self loadMovies];
}

-(void)loadMovies {
    //load movies from core data into array
}

-(IBAction)syncMovies:(id)sender {
    //read links from directory
    if(self.movieListingUrlField.stringValue!=nil){
        NSURL *movieListingUrl = [NSURL URLWithString:self.movieListingUrlField.stringValue];
        NSURLRequest *movieListingUrlRequest = [NSURLRequest requestWithURL:movieListingUrl];
        NSURLConnection *movieListingUrlConnection = [[NSURLConnection alloc] initWithRequest:movieListingUrlRequest delegate:self];
        [movieListingUrlConnection start];
    }
}

-(void)submitSearch:(NSString*)text
{
    self.movieSearchField.stringValue=text;
    [self fireMovieSearch:self];
}

- (IBAction)fireMovieSearch:(id)sender {
    
    
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedData = [NSMutableData data];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSXMLDocument *document =
    [[NSXMLDocument alloc] initWithData:self.receivedData options:NSXMLDocumentTidyHTML error:&error];
    
    NSXMLElement *rootNode = [document rootElement];
    
    NSString *xpathQueryString = @"//@href";
    NSArray *newItemsNodes = [rootNode nodesForXPath:xpathQueryString error:&error];
    for(NSXMLNode *node in newItemsNodes){
        NSLog(@"%@", node.stringValue );
    }
    //iterate through links and check against core data
    //if link does not exist, query rotten tomatoes and add entry to core data
    //[self.rottenTomatoesMovieSearch searchForMovie:keywords forNumberOfResults:1];
    
    //if updates exist, then reload array from core data
    [self loadMovies];

    
}

-(void)finishedSearchRequest:(JBFMovie*)result{
    //self.movieSearchListingViewController.movies = results.moviesArray;
    //[self.movieSearchListingViewController reloadData];
}

@end
