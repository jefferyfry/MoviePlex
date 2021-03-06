//
//  JBFWindowController.m
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFVideoListingWindowController.h"
#import "JBFCoreDataStack.h"
#import "JBFGenre.h"
@import CoreData;

@interface JBFVideoListingWindowController () <NSSplitViewDelegate,NSOutlineViewDataSource,NSOutlineViewDelegate>

@property JBFVideoListingViewController *videoListingViewController;
@property (weak) IBOutlet NSSearchField *videoSearchField;
@property (weak) IBOutlet NSSegmentedControl *sortField;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *genreSidebarView;
@property (weak) IBOutlet NSOutlineView *downloadSidebarView;
@property (weak) IBOutlet NSTextField *numMoviesLabel;
@property (weak) IBOutlet NSTextField *numTvLabel;
@property (weak) IBOutlet NSTextField *numOtherLabel;
@property NSArray *genres;
@property NSArray *downloadStatus;

@end

@implementation JBFVideoListingWindowController

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
    [self.window setTitle:@"Ken Pickle's Videorama 1.0"];
    self.videoListingViewController = [JBFVideoListingViewController new];
    self.videoListingViewController.view.frame = [self.window.contentView bounds];
    self.videoListingViewController.view.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    [self.splitView replaceSubview:[self.splitView subviews][1] with:self.videoListingViewController.view];
    [self.splitView adjustSubviews];
    [self.splitView setDelegate:self];
    [self loadGenres];
    self.downloadStatus = [NSArray arrayWithObjects:@"All",@"Yes",@"No", nil];
   
    
    [self.genreSidebarView setDataSource:self];
    [self.genreSidebarView setDelegate:self];
    [self.downloadSidebarView setDataSource:self];
    [self.downloadSidebarView setDelegate:self];
    
    
    [self.sortField setSelectedSegment:0];
    
    //load core data videos into array
    [self loadVideos];
    
    //set sidebar selection option
    [self.genreSidebarView setAllowsMultipleSelection:YES];
    [self.downloadSidebarView setAllowsMultipleSelection:NO];
    
    //expand sidebars
    [self.genreSidebarView expandItem:nil expandChildren:YES];
    [self.downloadSidebarView expandItem:nil expandChildren:YES];
    
    //set initial selection
    [self.genreSidebarView selectRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] byExtendingSelection:NO];
    [self.downloadSidebarView selectRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] byExtendingSelection:NO];
    
    //counts
    [self countMovies];
    [self countTVShows];
    [self countOther];
}

-(void)loadGenres {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //load videos from core data into array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Genre"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error = nil;
    NSArray *genresDb = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *genresList = [NSMutableArray new];
    [genresList addObject:@"All"];
    for(id genre in genresDb)
        [genresList addObject:genre];
    self.genres = genresList;
}

-(void)countMovies {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //count
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Video"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type CONTAINS[cd] 'Movie'"];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [self.numMoviesLabel setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)result.count]];
}

-(void)countTVShows {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //count
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Video"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type CONTAINS[cd] 'TV'"];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [self.numTvLabel setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)result.count]];
}

-(void)countOther {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //count
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Video"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type CONTAINS[cd] 'Other'"];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [self.numOtherLabel setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)result.count]];
}

-(void)loadVideos {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    
    //load videos from core data into array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Video"];
    
    //determine selected downloads
    NSIndexSet *selectedDownloadIndexes = [self.downloadSidebarView selectedRowIndexes];
    
    //determine selected genres
    NSIndexSet *selectedGenreIndexes = [self.genreSidebarView selectedRowIndexes];
    
    NSMutableString *predicateString = [NSMutableString new];
    
    NSString *searchText = [self.videoSearchField.stringValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    //handle search text
    if([searchText length] > 2)
        [predicateString appendFormat:@"(title CONTAINS[cd] '%@' OR synopsis CONTAINS[cd] '%@' OR actors CONTAINS[cd] '%@')",searchText,searchText,searchText];
    
    //handle download
    if([selectedDownloadIndexes count] > 0 && ![selectedDownloadIndexes containsIndex:1]){
        if([predicateString length] > 0)
           [predicateString appendString:@" AND "];
        if([selectedDownloadIndexes containsIndex:3]) //not downloaded
            [predicateString appendString:@"(downloaded == 0 OR downloaded==nil)"];
        else if([selectedDownloadIndexes containsIndex:2]) //downloaded
            [predicateString appendString:@"(downloaded == 1)"];
        
    }

    //handle genres
    if([selectedGenreIndexes count] > 0 && ![selectedGenreIndexes containsIndex:1]){
        if([predicateString length] > 0)
            [predicateString appendString:@" AND "];
        [predicateString appendString:@"("];
        __block int count = 0;
        [selectedGenreIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            JBFGenre *genre = self.genres[idx-1]; //skip all
            
            count+=1;
            if(count == [selectedGenreIndexes count]){
                [predicateString appendFormat:@"genre CONTAINS[cd] '%@'",genre.name];
                *stop = YES;
            }
            else
                [predicateString appendFormat:@"genre CONTAINS[cd] '%@' OR",genre.name];
        }];
        [predicateString appendString:@")"];
    }
    //NSLog(@"Predicate %@",predicateString);
    
    if ([predicateString length] > 0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
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
    NSArray *videos = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.videoListingViewController.videos = videos;
    [self.videoListingViewController reloadData];
}

- (IBAction)fireVideoSearch:(id)sender {
    [self loadVideos];
}

- (IBAction)fireVideoSort:(id)sender {
    [self loadVideos];
}

-(void)videosUpdated {
    [self loadVideos];
    [self countMovies];
    [self countTVShows];
    [self countOther];
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

- (BOOL)outlineView:(NSOutlineView *)outlineView
 shouldCollapseItem:(id)item {
    return NO;
}

- (void)outlineView:(NSOutlineView *)outlineView
    willDisplayCell:(id)cell
     forTableColumn:(NSTableColumn *)tableColumn
               item:(id)item {

}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [self loadVideos];
}

- (NSRect)splitView:(NSSplitView *)splitView
      effectiveRect:(NSRect)proposedEffectiveRect
       forDrawnRect:(NSRect)drawnRect
   ofDividerAtIndex:(NSInteger)dividerIndex{
    return NSZeroRect;
}

@end
