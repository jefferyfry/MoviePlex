//
//  JBFMovieArray.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieSearchResult.h"
#import "JBFMovie.h"

@implementation JBFMovieSearchResult

-(id)init {
    if (self = [super init])  {
        self.moviesArray = [NSMutableArray new];
    }
    return self;
}

-(NSString*)description{
    NSMutableString *description = [NSMutableString new];
    for(JBFMovie *thisMovie in self.moviesArray){
        [description appendString:[thisMovie description]];
        [description appendString:@"\r\n"];
    }
    return description;
}


@end
