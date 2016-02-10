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
    
    //add option for reset DB
//    [self.statusMenu addItemWithTitle:@"Reset Movie DB" action:@selector(resetMovieDb) keyEquivalent:@""];
//    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
//    [self.statusItem setHighlightMode:YES]; //highlight the item whem clicked
    
    //add option for sync now
//    [self.statusMenu addItemWithTitle:@"Sync Now" action:@selector(syncMovies) keyEquivalent:@""];
//    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
//    [self.statusItem setHighlightMode:YES]; //highlight the item whem clicked
    
    //add option for exiting
    [self.statusMenu addItemWithTitle:@"Exit" action:@selector(exit:) keyEquivalent:@""];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES]; //highlight the item whem clicked
    
    //load the status bar icon for this app
    NSString *statusIcon = [[NSBundle mainBundle] pathForResource:@"movieplex22x22" ofType:@"png"];
    [self.statusItem setImage:[[NSImage alloc] initWithContentsOfFile:statusIcon]];
    //when clicked it will show the main window and the exit option
    [self.statusItem setAction:@selector(showMainWindowAndExitOption:)];
    
    //sync on app launch
    [self syncMovies];
    
    //now schedule periodic checks with the web site
    self.syncMovieTimer = [NSTimer scheduledTimerWithTimeInterval:3600.0
                                                           target:self selector:@selector(syncMovies)
                                                         userInfo:nil repeats:YES];
}

- (void)showMainWindowAndExitOption:(id)sender {
    [self.statusItem popUpStatusItemMenu:self.statusMenu]; //show exit
    [self.movieWindowController showWindow:self]; //show main window
    [NSApp activateIgnoringOtherApps:YES]; //bring main window to front
}

- (void)syncMovies {
    [self.movieSyncer syncMovies];
}
//
//- (void)resetMovieDb {
//    [self.movieSyncer resetMoviesDb];
//}

- (void)exit:(id)sender {
    [NSApp terminate:self];
}

@end
