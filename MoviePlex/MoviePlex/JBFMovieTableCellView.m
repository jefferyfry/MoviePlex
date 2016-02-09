//
//  JBFMovieTableCellView.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieTableCellView.h"

@implementation JBFMovieTableCellView

-(IBAction)doDownloadNow:(id)sender {
    if(self.downloadUrl!=nil){
        NSURL *url = [NSURL URLWithString:self.downloadUrl];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}


@end