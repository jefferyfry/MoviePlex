//
//  JBFMovieModel.h
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBFMovie : NSObject

@property (strong, nonatomic) NSString *title;
@property NSNumber *year;
@property (strong, nonatomic) NSString *mpaaRating;
@property NSNumber *runtime;
@property (strong, nonatomic) NSString *synopsis;
@property (strong, nonatomic) NSString *thumbnailUrl;
@property (strong, nonatomic) NSMutableArray *cast;
@property (strong, nonatomic) NSString *releaseDate;
@property (strong, nonatomic) NSString *uploadDate;
@property (strong, nonatomic) NSString *downloadUrl;

-(NSString*)stringFromCast;

@end
