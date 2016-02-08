//
//  JBFRottenTomatoesMovieSearch.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFRottenTomatoesMovieSearch.h"
#import "JBFJSON2MovieParser.h"

NSString *const RottenTomatoesMovieAPIUrl = @"http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=8pmwpbz6jmxepyrmgkryr46u&q=%@&page_limit=%lu&page=1";

@interface JBFRottenTomatoesMovieSearch()

@property (strong,nonatomic) NSMutableData *receivedData;

@end

@implementation JBFRottenTomatoesMovieSearch

-(id)init {
    if (self = [super init])  {
        //init here
    }
    return self;
}


-(void)searchForMovie:(NSString*)searchText;
{
    NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *searchMovieUrlString = [NSString stringWithFormat:RottenTomatoesMovieAPIUrl,urlEncodedSearchText,(unsigned long)1];
    NSURL *searchMovieUrl = [NSURL URLWithString:searchMovieUrlString];
    NSURLRequest *searchMovieUrlRequest = [NSURLRequest requestWithURL:searchMovieUrl];
    NSURLConnection *movieSearchUrlConnection = [[NSURLConnection alloc] initWithRequest:searchMovieUrlRequest delegate:self];
    [movieSearchUrlConnection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedData = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([self.delegate respondsToSelector:@selector(finishedSearchRequest:)]){
        JBFMovie *movieSearchResult = [JBFJSON2MovieParser movieSearchResultFromJSONData:self.receivedData];
        [self.delegate finishedSearchRequest:movieSearchResult];
    }
    
}

@end
