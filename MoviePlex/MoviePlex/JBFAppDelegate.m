//
//  JBFAppDelegate.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFAppDelegate.h"
#import "JBFMovieSyncer.h"

@interface JBFAppDelegate()

@property NSTimer *syncMovieTimer;

@property JBFMovieSyncer *movieSyncer;


@end

@implementation JBFAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    [NSApp activateIgnoringOtherApps:YES];
    
    //initialize the main viewing window
    self.movieWindowController = [JBFMovieListingWindowController new];
    
    //initilize the movie syncer
    self.movieSyncer = [[JBFMovieSyncer alloc] init];
    self.movieSyncer.delegate = self.movieWindowController;
    
    //add status bar menu
    self.statusMenu = [[NSMenu alloc] init];
    
    //load the status bar icon for this app
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES]; //highlight the item whem clicked
    [self.statusItem setAction:@selector(showMainWindowAndStatusMenuOptions:)];
    NSString *statusIcon = [[NSBundle mainBundle] pathForResource:@"movieplex22x22" ofType:@"png"];
    [self.statusItem setImage:[[NSImage alloc] initWithContentsOfFile:statusIcon]];
    
    //add option for reset DB
    [self.statusMenu addItemWithTitle:@"Reset Movie DB" action:@selector(resetMovieDb) keyEquivalent:@""];
    
    //add option for marking all as downloaded
    [self.statusMenu addItemWithTitle:@"Mark All Downloaded" action:@selector(markAllDownloaded) keyEquivalent:@""];
    
    //add option for marking all as not downloaded
    [self.statusMenu addItemWithTitle:@"Mark All Not Downloaded" action:@selector(markAllNotDownloaded) keyEquivalent:@""];

    //add option for exiting
    [self.statusMenu addItemWithTitle:@"Exit" action:@selector(exit:) keyEquivalent:@""];
    
    //sync on app launch
    [self syncMovies];
    
    //now schedule periodic checks with the web site
    self.syncMovieTimer = [NSTimer scheduledTimerWithTimeInterval:3600.0
                                                           target:self selector:@selector(syncMovies)
                                                         userInfo:nil repeats:YES];
}

- (void)showMainWindowAndStatusMenuOptions:(id)sender {
    [self.statusItem popUpStatusItemMenu:self.statusMenu]; //show menu options
    [self.movieWindowController showWindow:self]; //show main window
    [NSApp activateIgnoringOtherApps:YES]; //bring main window to front
}

- (void)syncMovies {
    [self.movieSyncer syncMovies];
}

- (void)resetMovieDb {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Reset the movie database?"];
    [alert setInformativeText:@"This will take a few moments to delete the movie metadata and re-sync."];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self.movieSyncer resetMoviesDb];
    }
}

-(void)markAllDownloaded {
    [self markAllWithDownloadStatus:YES];
}

-(void)markAllNotDownloaded {
    [self markAllWithDownloadStatus:NO];
}

-(void)markAllWithDownloadStatus:(BOOL)downloaded {
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    
    //now query core data to see if movies already exist
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Movie"];
    
    NSError *error = nil;
    NSArray *array = [childManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array != nil || [array count] > 0) {
        for(JBFMovie *movie in array)
            movie.downloaded = downloaded;
        
        if (![childManagedObjectContext save:&error])
            NSLog(@"Error saving movie download status in child MOC: %@", error);
        
        [self.movieWindowController loadMovies];
    }
}

- (void)exit:(id)sender {
    [NSApp terminate:self];
}

@end
