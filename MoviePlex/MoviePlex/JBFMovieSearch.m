//
//  JBFRottenTomatoesMovieSearch.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFMovieSearch.h"
#import "NSURLRequest+NSURLRequestAddition.h"

NSString *const MovieTitleAPIUrl = @"http://www.omdbapi.com/?t=%@&plot=full&r=json";
NSString *const MovieTitleYearAPIUrl = @"http://www.omdbapi.com/?t=%@&y=%@plot=full&r=json";

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
    NSURL *searchMovieUrl;
    if([searchText containsString:@"("]&&[searchText containsString:@")"]){ //search by string and year
        NSInteger start = [searchText rangeOfString:@"("].location+1;
        NSString *yearString = [[searchText substringFromIndex:start] substringToIndex:5];
        searchText = [searchText substringToIndex:start-1];
        NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *searchMovieUrlString = [NSString stringWithFormat:MovieTitleYearAPIUrl,urlEncodedSearchText,yearString];
        searchMovieUrl = [NSURL URLWithString:searchMovieUrlString];
    }
    else { //search by string only
        NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *searchMovieUrlString = [NSString stringWithFormat:MovieTitleAPIUrl,urlEncodedSearchText];
        searchMovieUrl = [NSURL URLWithString:searchMovieUrlString];
    }
    
    NSURLRequest *searchMovieUrlRequest = [NSURLRequest requestWithURL:searchMovieUrl];
    searchMovieUrlRequest.downloadUrl = downloadUrl;
    searchMovieUrlRequest.uploadDate = uploadDate;
    searchMovieUrlRequest.searchText = searchText;
    double delay = self.requestIndex.doubleValue * 0.05;
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
