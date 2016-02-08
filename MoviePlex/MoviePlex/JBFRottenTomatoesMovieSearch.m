//
//  JBFRottenTomatoesMovieSearch.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFRottenTomatoesMovieSearch.h"
#import "JBFJSON2MovieParser.h"
#import "NSURLConnection+NSURLConnectionAddition.h"

NSString *const RottenTomatoesMovieAPIUrl = @"http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=8pmwpbz6jmxepyrmgkryr46u&q=%@&page_limit=%lu&page=1";

@interface JBFRottenTomatoesMovieSearch()

@property (strong,nonatomic) NSMutableData *receivedData;

@end

@implementation JBFRottenTomatoesMovieSearch

-(id)init {
    if (self = [super init])  {
        //does nothing
    }
    return self;
}

-(void)executeRequestWithDelay:(NSURLConnection*)movieSearchUrlConnection {
    [NSThread sleepForTimeInterval:0.4];
    [movieSearchUrlConnection start];
}

-(void)searchForMovie:(NSString*)searchText withDownloadUrl:(NSString*)downloadUrl withUploadDate:(NSString*)uploadDate
{
    NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *searchMovieUrlString = [NSString stringWithFormat:RottenTomatoesMovieAPIUrl,urlEncodedSearchText,(unsigned long)1];
    NSURL *searchMovieUrl = [NSURL URLWithString:searchMovieUrlString];
    NSURLRequest *searchMovieUrlRequest = [NSURLRequest requestWithURL:searchMovieUrl];
    NSURLConnection *movieSearchUrlConnection = [[NSURLConnection alloc] initWithRequest:searchMovieUrlRequest delegate:self];
    movieSearchUrlConnection.downloadUrl = downloadUrl;
    movieSearchUrlConnection.uploadDate = uploadDate;
    [self performSelectorInBackground:@selector(executeRequestWithDelay:) withObject:movieSearchUrlConnection];
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
        NSString* jsonString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonString: %@", jsonString);
        JBFMovie *movieSearchResult = [JBFJSON2MovieParser movieSearchResultFromJSONData:self.receivedData];
        movieSearchResult.downloadUrl = connection.downloadUrl;
        movieSearchResult.uploadDate = connection.uploadDate;
        [self.delegate finishedSearchRequest:movieSearchResult];
    }
    
}

@end
