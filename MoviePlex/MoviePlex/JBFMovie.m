//
//  JBFMovieModel.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovie.h"

@implementation JBFMovie

@dynamic title;
@dynamic year;
@dynamic mpaaRating;
@dynamic runtime;
@dynamic synopsis;
@dynamic thumbnailUrl;
@dynamic cast;
@dynamic releaseDate;
@dynamic uploadDate;
@dynamic downloadUrl;

-(NSString*)description{
    NSMutableString *description = [NSMutableString new];
    [description appendString:@"title: "];
    [description appendString:self.title];
    [description appendString:@" year: "];
    [description appendFormat:@"%@",self.year];
    [description appendString:@" release date: "];
    [description appendFormat:@"%@",self.releaseDate];
    [description appendString:@" upload date: "];
    [description appendFormat:@"%@",self.uploadDate];
    [description appendString:@" mpaaRating: "];
    [description appendString:self.mpaaRating];
    [description appendString:@" runtime: "];
    [description appendFormat:@"%@",self.runtime];
    [description appendString:@" synopsis: "];
    [description appendString:self.synopsis];
    [description appendString:@" thumbnailUrl: "];
    [description appendString:self.thumbnailUrl];
    [description appendString:@" downloadUrl: "];
    [description appendString:self.downloadUrl];
    [description appendString:@" cast: "];
    [description appendString:self.cast];
    return description;
}

@end
