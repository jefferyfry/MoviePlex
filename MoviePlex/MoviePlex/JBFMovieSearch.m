//
//  JBFRottenTomatoesMovieSearch.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieSearch.h"
#import "NSURLRequest+NSURLRequestAddition.h"

NSString *const MovieAPIUrl = @"http://www.omdbapi.com/?t=%@&plot=short&r=json";

@interface JBFMovieSearch()

@property (strong,nonatomic) NSMutableData *receivedData;
@property (nonatomic, assign) NSNumber *requestIndex;

@end

@implementation JBFMovieSearch

-(id)init {
    if (self = [super init])  {
        _requestIndex = [NSNumber numberWithInt:0];
    }
    return self;
}

-(void)searchForMovie:(NSString*)searchText withDownloadUrl:(NSString*)downloadUrl withUploadDate:(NSString*)uploadDate
{
    NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    //[searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *searchMovieUrlString = [NSString stringWithFormat:MovieAPIUrl,urlEncodedSearchText];
    NSURL *searchMovieUrl = [NSURL URLWithString:searchMovieUrlString];
    NSURLRequest *searchMovieUrlRequest = [NSURLRequest requestWithURL:searchMovieUrl];
    searchMovieUrlRequest.downloadUrl = downloadUrl;
    searchMovieUrlRequest.uploadDate = uploadDate;
    searchMovieUrlRequest.searchText = searchText;
    double delay = self.requestIndex.doubleValue * 0.1;
    self.requestIndex = [NSNumber numberWithInt:((self.requestIndex.intValue+1)%1000)];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURLConnection *movieSearchUrlConnection = [[NSURLConnection alloc] initWithRequest:searchMovieUrlRequest delegate:self];
        [movieSearchUrlConnection start];
    });
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
        NSMutableDictionary *movieSearchResult = [[NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:nil] mutableCopy];
        
        if([movieSearchResult objectForKey:@"Error"]!=nil){
            movieSearchResult = [[NSMutableDictionary alloc] init];
            [movieSearchResult setValue:connection.originalRequest.searchText forKey:@"Title"];
        }
        
        [movieSearchResult setValue:connection.originalRequest.downloadUrl forKey:@"downloadUrl"];
        [movieSearchResult setValue:connection.originalRequest.uploadDate forKey:@"uploadDate"];
        //NSLog(@"%@", movieSearchResult);
        [self.delegate finishedSearchRequest:movieSearchResult];
    }
    
}

@end
