//
//  JBFMovieTableCellView.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieTableCellView.h"
#import "JBFCoreDataStack.h"
#import "JBFMovie.h"

@interface JBFMovieTableCellView()

@property (nonatomic, assign) long bytesReceived;
@property (nonatomic, retain) NSURLResponse *downloadResponse;
@property (nonatomic, retain) NSURLDownload *movieDownload;

@end

@implementation JBFMovieTableCellView

-(IBAction)doDownloadNow:(id)sender {
    if(self.downloadUrl!=nil){
        NSURL *downloadUrl = [NSURL URLWithString:self.downloadUrl];
        [self.downloadNowButton setHidden:YES];
        [self.downloadLabelField setHidden:NO];
        [self.downloadProgressIndicator setHidden:NO];
        [self.downloadCancelButton setHidden:NO];
        [self.downloadCancelButton setTitle:@"X"];
        
        //start downoad
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:downloadUrl
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:6000.0];
        
        // Create the download with the request and start loading the data.
        self.movieDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
        if (!self.movieDownload) {
            [self failedDownload];
        }
    }
}

-(IBAction)doDownloadCancel:(id)sender{
    [self.movieDownload cancel];
    self.downloadedCheckbox.state = NSOffState;
    [self setDownloaded:NSOffState];
    [self.downloadNowButton setHidden:NO];
    [self.downloadLabelField setStringValue:@"Download cancelled."];
    [self.downloadProgressIndicator setHidden:YES];
    [self.downloadCancelButton setHidden:YES];
    [self.downloadCancelButton setTitle:@""];
}

-(IBAction)doDownloadedCheck:(id)sender {
    [self setDownloaded:self.downloadedCheckbox.state];
}

-(void)setDownloaded:(NSInteger)state {
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"downloadUrl==%@",self.downloadUrl];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Movie"];
    fetchRequest.predicate=predicate;
    NSError *error = nil;
    NSArray *array = [childManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if([array count]>0){
        JBFMovie *movie = array[0];
        if(state==NSOnState)
            movie.downloaded = YES;
        else
            movie.downloaded = NO;
        NSError *error = nil;
        if (![childManagedObjectContext save:&error]) {
            NSLog(@"Error saving movie download status in child MOC: %@", error);
        }
    }
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    [self failedDownload];
}

- (void) failedDownload {
    self.downloadedCheckbox.state = NSOffState;
    [self setDownloaded:NSOffState];
    [self.downloadNowButton setHidden:NO];
    [self.downloadLabelField setStringValue:@"Download failed."];
    [self.downloadProgressIndicator setHidden:YES];
    [self.downloadCancelButton setHidden:YES];
    [self.downloadCancelButton setTitle:@""];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    //reset the counter
    self.bytesReceived = 0;
    [self setDownloadResponse:response];
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *destinationFilename;
    NSString *homeDirectory = NSHomeDirectory();
    destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Desktop"]
                           stringByAppendingPathComponent:filename];
    [self.downloadLabelField setStringValue:@"Downloading to Desktop..."];
    [download setDestination:destinationFilename allowOverwrite:NO];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length
{
    long long expectedLength = [[self downloadResponse] expectedContentLength];
    self.bytesReceived = self.bytesReceived + length;
    
    if (expectedLength != NSURLResponseUnknownLength) {
        double percentComplete = (self.bytesReceived/(float)expectedLength)*100.0;
        NSLog(@"%.2f",percentComplete);
        [self.downloadProgressIndicator setDoubleValue:percentComplete];
        //[self.downloadLabelField setStringValue:[NSString stringWithFormat:@"%ld of %lld bytes",self.bytesReceived,expectedLength]];
    }
    else {
        NSLog(@"Bytes received - %ld",self.bytesReceived);
    }
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    self.downloadedCheckbox.state = NSOnState;
    [self setDownloaded:NSOnState];
    [self.downloadLabelField setStringValue:@"Download complete."];
}


@end