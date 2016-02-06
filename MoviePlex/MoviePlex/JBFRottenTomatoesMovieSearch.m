//
//  JBFRottenTomatoesMovieSearch.m
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFRottenTomatoesMovieSearch.h"
#import "JBFJSON2MovieParser.h"

static long long expectedResponseSize;

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


-(void)searchForMovie:(NSString*)searchText forNumberOfResults:(NSUInteger)numResults;
{
    NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *searchMovieUrlString = [NSString stringWithFormat:RottenTomatoesMovieAPIUrl,urlEncodedSearchText,(unsigned long)numResults];
    NSURL *searchMovieUrl = [NSURL URLWithString:searchMovieUrlString];
    NSURLRequest *searchMovieUrlRequest = [NSURLRequest requestWithURL:searchMovieUrl];
    NSURLConnection *movieSearchUrlConnection = [[NSURLConnection alloc] initWithRequest:searchMovieUrlRequest delegate:self];
    [movieSearchUrlConnection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedResponseSize = response.expectedContentLength;
    self.receivedData = [NSMutableData data];
    if([self.delegate respondsToSelector:@selector(startedSearchRequest)])
        [self.delegate startedSearchRequest];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
    if([self.delegate respondsToSelector:@selector(updateSearchRequestProgress:)]){
        double progress = (double)self.receivedData.length/(double)expectedResponseSize;
        [self.delegate updateSearchRequestProgress:progress];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([self.delegate respondsToSelector:@selector(finishedSearchRequest:)]){
        JBFMovieSearchResult *movieSearchResult = [JBFJSON2MovieParser movieSearchResultFromJSONData:self.receivedData];
        [self.delegate finishedSearchRequest:movieSearchResult];
    }
    
}

@end
