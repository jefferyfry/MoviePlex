//
//  JBFMovieModel.h
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface JBFMovie : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *mpaaRating;
@property (nonatomic, retain) NSString *runtime;
@property (nonatomic, retain) NSString *synopsis;
@property (nonatomic, retain) NSString *thumbnailUrl;
@property (nonatomic, retain) NSString *cast;
@property (nonatomic, retain) NSString *releaseDate;
@property (nonatomic, retain) NSString *uploadDate;
@property (nonatomic, retain) NSString *downloadUrl;
@property (nonatomic) BOOL downloaded;

@end
