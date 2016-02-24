//
//  JBFWindowController.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieListingWindowController.h"
#import "JBFCoreDataStack.h"
#import "JBFGenre.h"
@import CoreData;

@interface JBFMovieListingWindowController () <NSSplitViewDelegate,NSOutlineViewDataSource,NSOutlineViewDelegate>

@property JBFMovieListingViewController *movieSearchListingViewController;
@property (weak) IBOutlet NSSearchField *movieSearchField;
@property (weak) IBOutlet NSSegmentedControl *sortField;
@property (weak) IBOutlet NSSegmentedControl *filterField;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *genreSidebarView;
@property (weak) IBOutlet NSOutlineView *downloadSidebarView;
@property NSArray *genres;
@property NSArray *downloadStatus;

-(void)loadMovies;

@end

@implementation JBFMovieListingWindowController

- (id)init
{
    self = [super initWithWindowNibName:NSStringFromClass(self.class)];
    if (self) {
        [self.splitView setDelegate:self];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setTitle:@"MoviePlex 0.5"];
    self.movieSearchListingViewController = [JBFMovieListingViewController new];
    self.movieSearchListingViewController.view.frame = [self.window.contentView bounds];
    self.movieSearchListingViewController.view.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    [self.splitView replaceSubview:[self.splitView subviews][1] with:self.movieSearchListingViewController.view];
    //[self.splitView adjustSubviews];
    [self.splitView setDelegate:self];
    [self loadGenres];
    self.downloadStatus = [NSArray arrayWithObjects:@"Yes",@"No", nil];
   
    
    [self.genreSidebarView setDataSource:self];
    [self.genreSidebarView setDelegate:self];
    [self.downloadSidebarView setDataSource:self];
    [self.downloadSidebarView setDelegate:self];
    
    
    [self.sortField setSelectedSegment:0];
    
    [self.filterField setSelectedSegment:0];
    
    //load core data movies into array
    [self loadMovies];
    
    [self.genreSidebarView expandItem:nil expandChildren:YES];
    [self.genreSidebarView setAllowsMultipleSelection:YES];
    [self.downloadSidebarView expandItem:nil expandChildren:YES];
    [self.downloadSidebarView setAllowsMultipleSelection:NO];
}

-(void)loadGenres {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //load movies from core data into array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Genre"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error = nil;
    self.genres = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

-(void)loadMovies {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //load movies from core data into array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Movie"];
    
    NSString *searchText = [self.movieSearchField.stringValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    if(([searchText length] > 2) && (self.filterField.selectedSegment==1)){ //search query plus filter downloaded==NO
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@ OR synopsis CONTAINS[cd] %@ OR actors CONTAINS[cd] %@) AND downloaded == 0 OR downloaded==nil", searchText,searchText,searchText];
        [fetchRequest setPredicate:predicate];
    }
    else if(([searchText length] > 2) && (self.filterField.selectedSegment==2)){ //search query plus filter downloaded==YES
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@ OR synopsis CONTAINS[cd] %@ OR actors CONTAINS[cd] %@) AND downloaded == 1", searchText,searchText,searchText];
        [fetchRequest setPredicate:predicate];
    }
    else if([searchText length] > 2){ //search query and no filter
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ OR synopsis CONTAINS[cd] %@ OR actors CONTAINS[cd] %@", searchText,searchText,searchText];
        [fetchRequest setPredicate:predicate];
    }
    else if(self.filterField.selectedSegment==1){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded == 0 OR downloaded==nil"];
        [fetchRequest setPredicate:predicate];
    }
    else if(self.filterField.selectedSegment==2){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded == 1"];
        [fetchRequest setPredicate:predicate];
    }
    
    //handle sorting
    if(self.sortField.selectedSegment==0)
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    else if(self.sortField.selectedSegment==1)
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:NO]];
    else if(self.sortField.selectedSegment==2)
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uploadDate" ascending:NO]];
    else if(self.sortField.selectedSegment==3)
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO]];
    
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

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(outlineView == self.genreSidebarView){
        if(item==nil&&index==0)
            return @"Genres";
        else
            return self.genres[index];
    }
    else {
        if(item==nil&&index==0)
            return @"Downloaded";
        else
            return self.downloadStatus[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if(item==nil)
        return YES;
    else if([item isKindOfClass:[NSString class]]){
        if([item isEqualToString:@"Downloaded"]||[item isEqualToString:@"Genres"])
            return YES;
        else
            return NO;
    }
    else
        return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(item==nil)
        return 1;
    else if(outlineView == self.genreSidebarView)
        return [self.genres count];
    else
        return [self.downloadStatus count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if(item==nil)
        return @"-";
    else if ([item isKindOfClass:[NSString class]])
        return item;
    else { //genre
        JBFGenre *genre = (JBFGenre*)item;
        return [NSString stringWithFormat:@"%@ (%@)",genre.name,genre.count];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   shouldSelectItem:(id)item {
    if([item isKindOfClass:[NSString class]]&&([item isEqualToString:@"Downloaded"]||[item isEqualToString:@"Genres"]))
        return NO;
    else
        return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView
    willDisplayCell:(id)cell
     forTableColumn:(NSTableColumn *)tableColumn
               item:(id)item {

}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    
}

- (NSRect)splitView:(NSSplitView *)splitView
      effectiveRect:(NSRect)proposedEffectiveRect
       forDrawnRect:(NSRect)drawnRect
   ofDividerAtIndex:(NSInteger)dividerIndex{
    return NSZeroRect;
}

@end
