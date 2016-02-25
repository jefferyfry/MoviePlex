//
//  NSString+NSStringAddition.m
//  KenPsVideorama
//
//  Created by Jeff Fry on 2/9/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import "NSString+NSStringAddition.h"

@implementation NSString (NSStringAddition)

+(NSString*)stringFromArray:(NSArray*)array
{
    NSMutableString *castString = [NSMutableString new];
    for(NSString *name in array){
        [castString appendString:name];
        [castString appendString:@", "];
    }
    if(castString.length > 1)
        [castString deleteCharactersInRange:NSMakeRange(castString.length-2, 2)];
    return castString;
}

@end
