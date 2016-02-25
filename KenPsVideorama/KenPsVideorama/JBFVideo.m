//
//  JBFVideoModel.m
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFVideo.h"

@implementation JBFVideo

@dynamic title;
@dynamic type;
@dynamic year;
@dynamic mpaaRating;
@dynamic runtime;
@dynamic synopsis;
@dynamic thumbnailUrl;
@dynamic actors;
@dynamic releaseDate;
@dynamic uploadDate;
@dynamic rating;
@dynamic downloadUrl;
@dynamic downloaded;
@dynamic genre;

-(NSString*)description{
    NSMutableString *description = [NSMutableString new];
    [description appendString:@"title: "];
    [description appendString:self.title];
    [description appendString:@"type: "];
    [description appendString:self.type];
    [description appendString:@" year: "];
    [description appendFormat:@"%@",self.year];
    [description appendString:@" release date: "];
    [description appendFormat:@"%@",self.releaseDate];
    [description appendString:@" upload date: "];
    [description appendFormat:@"%@",self.uploadDate];
    [description appendString:@" rating: "];
    [description appendFormat:@"%@",self.rating];
    [description appendString:@" genre: "];
    [description appendFormat:@"%@",self.genre];
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
    [description appendString:self.actors];
    [description appendString:@" downloaded: "];
    if(self.downloaded)
        [description appendString:@"YES"];
    else
        [description appendString:@"NO"];
    return description;
}

@end
