//
//  JBFGenre.h
//  MoviePlex
//
//  Created by Jeffery Fry on 2/21/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface JBFGenre : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *count;

@end
