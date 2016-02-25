//
//  JBFCoreDataStack.h
//  KenPsVideorama
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBFCoreDataStack : NSObject

+(JBFCoreDataStack*)sharedStack;

-(NSManagedObjectContext *)rootManagedObjectContext;

-(NSManagedObjectContext *)newChildManagedObjectContext;

@end
