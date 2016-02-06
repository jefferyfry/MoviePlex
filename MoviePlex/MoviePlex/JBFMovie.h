//
//  JBFMovieModel.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
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

-(NSString*)stringFromCast;

@end
