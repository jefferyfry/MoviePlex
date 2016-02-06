//
//  JBFMovieModel.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovie.h"

@implementation JBFMovie

-(NSString*)stringFromCast
{
    NSMutableString *castString = [NSMutableString new];
    for(NSString *name in self.cast){
        [castString appendString:name];
        [castString appendString:@", "];
    }
    if(castString.length > 1)
        [castString deleteCharactersInRange:NSMakeRange(castString.length-2, 2)];
    return castString;
}

-(NSString*)description{
    NSMutableString *description = [NSMutableString new];
    [description appendString:@"title: "];
    [description appendString:self.title];
    [description appendString:@" year: "];
    [description appendFormat:@"%@",self.year];
    [description appendString:@" mpaaRating: "];
    [description appendString:self.mpaaRating];
    [description appendString:@" runtime: "];
    [description appendFormat:@"%@",self.runtime];
    [description appendString:@" synopsis: "];
    [description appendString:self.synopsis];
    [description appendString:@" thumbnailUrl: "];
    [description appendString:self.thumbnailUrl];
    [description appendString:@" cast: "];
    for(NSString *name in self.cast){
        [description appendString:name];
        [description appendString:@", "];
    }
    return description;
}

@end
