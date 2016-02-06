//
//  JBFAppDelegate.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFAppDelegate.h"

@interface JBFAppDelegate()

@property NSTimer *syncMovieTimer;


@end

@implementation JBFAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [NSApp activateIgnoringOtherApps:YES];
    
    //initialize the main viewing window
    self.mainWindowController = [JBFWindowController new];
    
    //set up the status bar option for exiting
    self.statusMenu = [[NSMenu alloc] init];
    [self.statusMenu addItemWithTitle:@"Exit" action:@selector(exit:) keyEquivalent:@""];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES]; //highlight the item whem clicked
    
    //load the status bar icon for this app
    NSString *statusIcon = [[NSBundle mainBundle] pathForResource:@"movieplex" ofType:@"png"];
    [self.statusItem setImage:[[NSImage alloc] initWithContentsOfFile:statusIcon]];
    //when clicked it will show the main window and the exit option
    [self.statusItem setAction:@selector(showMainWindowAndExitOption:)];
    
    //now schedule periodic checks with the web site
    self.syncMovieTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                        target:self selector:@selector(syncMovies:)
                                                      userInfo:nil repeats:YES];
}

- (void)showMainWindowAndExitOption:(id)sender {
    [self.statusItem popUpStatusItemMenu:self.statusMenu]; //show exit
    [self.mainWindowController showWindow:self]; //show main window
    [NSApp activateIgnoringOtherApps:YES]; //bring main window to front
}

- (void)syncMovies:(id)sender {
    
}

- (void)exit:(id)sender {
    [NSApp terminate:self];
}

@end
