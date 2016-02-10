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

@implementation JBFMovieTableCellView

-(IBAction)doDownloadNow:(id)sender {
    if(self.downloadUrl!=nil){
        NSURL *url = [NSURL URLWithString:self.downloadUrl];
        [[NSWorkspace sharedWorkspace] openURL:url];
        self.downloadedCheckbox.state = NSOnState;
        [self setDownloaded:NSOnState];
    }
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


@end