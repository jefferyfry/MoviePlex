//
//  JBFAppDelegate.m
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFAppDelegate.h"
#import "JBFVideosSyncer.h"

@interface JBFAppDelegate()

@property NSTimer *syncVideoTimer;

@property JBFVideosSyncer *videoSyncer;


@end

@implementation JBFAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    [NSApp activateIgnoringOtherApps:YES];
    
    //initialize the main viewing window
    self.videoWindowController = [JBFVideoListingWindowController new];
    
    //initilize the video syncer
    self.videoSyncer = [[JBFVideosSyncer alloc] init];
    self.videoSyncer.delegate = self.videoWindowController;
    
    //add status bar menu
    self.statusMenu = [[NSMenu alloc] init];
    
    //load the status bar icon for this app
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES]; //highlight the item whem clicked
    [self.statusItem setAction:@selector(showMainWindowAndStatusMenuOptions:)];
    NSString *statusIcon = [[NSBundle mainBundle] pathForResource:@"videorama22x22" ofType:@"png"];
    [self.statusItem setImage:[[NSImage alloc] initWithContentsOfFile:statusIcon]];
    
    //add option for reset DB
    [self.statusMenu addItemWithTitle:@"Reset video DB" action:@selector(resetVideoDb) keyEquivalent:@""];
    
    //add option for marking all as downloaded
    [self.statusMenu addItemWithTitle:@"Mark All Downloaded" action:@selector(markAllDownloaded) keyEquivalent:@""];
    
    //add option for marking all as not downloaded
    [self.statusMenu addItemWithTitle:@"Mark All Not Downloaded" action:@selector(markAllNotDownloaded) keyEquivalent:@""];

    //add option for exiting
    [self.statusMenu addItemWithTitle:@"Exit" action:@selector(exit:) keyEquivalent:@""];
    
    //sync on app launch
    [self syncVideos];
    
    //now schedule periodic checks with the web site
    self.syncVideoTimer = [NSTimer scheduledTimerWithTimeInterval:3600.0
                                                           target:self selector:@selector(syncVideos)
                                                         userInfo:nil repeats:YES];
}

- (void)showMainWindowAndStatusMenuOptions:(id)sender {
    [self.statusItem popUpStatusItemMenu:self.statusMenu]; //show menu options
    [self.videoWindowController showWindow:self]; //show main window
    [NSApp activateIgnoringOtherApps:YES]; //bring main window to front
}

- (void)syncVideos {
    [self.videoSyncer syncVideos];
}

- (void)resetVideoDb {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Reset the Video database?"];
    [alert setInformativeText:@"This will take a few moments to delete the video metadata and re-sync."];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self.videoSyncer resetVideosDb];
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
    
    //now query core data to see if videos already exist
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Video"];
    
    NSError *error = nil;
    NSArray *array = [childManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array != nil || [array count] > 0) {
        for(JBFVideo *video in array)
            video.downloaded = downloaded;
        
        if (![childManagedObjectContext save:&error])
            NSLog(@"Error saving video download status in child MOC: %@", error);
        
        [self.videoWindowController loadVideos];
    }
}

- (void)exit:(id)sender {
    [NSApp terminate:self];
}

@end
