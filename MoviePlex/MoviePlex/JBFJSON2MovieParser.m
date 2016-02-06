//
//  JBFJSON2MovieParser.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/19/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFJSON2MovieParser.h"
#import "JBFMovie.h"

@implementation JBFJSON2MovieParser

+(JBFMovieSearchResult*)movieSearchResultFromJSONData:(NSData*)jsonData {
    JBFMovieSearchResult *movieSearchResult = [JBFMovieSearchResult new];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    movieSearchResult.jsonString = [jsonString stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    NSDictionary *movieDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSArray *moviesArray = movieDict[@"movies"];
    
    for(NSDictionary *thisMovieDict in moviesArray){
        JBFMovie *movie = [JBFMovie new];
        movie.title = thisMovieDict[@"title"];
        movie.year = thisMovieDict[@"year"] ;
        movie.mpaaRating = thisMovieDict[@"mpaa_rating"];
        movie.runtime = thisMovieDict[@"runtime"];
        movie.synopsis = thisMovieDict[@"synopsis"];
        movie.thumbnailUrl = thisMovieDict[@"posters"][@"thumbnail"];
        
        NSMutableArray *cast = [NSMutableArray new];
        for(NSDictionary *thisCastDict in thisMovieDict[@"abridged_cast"]){
            [cast addObject:thisCastDict[@"name"]];
        }
        movie.cast = cast;
        
        [movieSearchResult.moviesArray addObject:movie];
    }
    
    return movieSearchResult;
}

@end
