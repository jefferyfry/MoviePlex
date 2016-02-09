//
//  JBFRottenTomatoesMovieSearch.m
//  MoviePlex
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFRottenTomatoesMovieSearch.h"
#import "JBFJSON2MovieParser.h"
#import "NSURLRequest+NSURLRequestAddition.h"

NSString *const RottenTomatoesMovieAPIUrl = @"http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=8pmwpbz6jmxepyrmgkryr46u&q=%@&page_limit=%lu&page=1";

@interface JBFRottenTomatoesMovieSearch()

@property (strong,nonatomic) NSMutableData *receivedData;
@property (nonatomic, assign) NSNumber *requestIndex;

@end

@implementation JBFRottenTomatoesMovieSearch

-(id)init {
    if (self = [super init])  {
        _requestIndex = [NSNumber numberWithInt:0];
    }
    return self;
}

-(void)searchForMovie:(NSString*)searchText withDownloadUrl:(NSString*)downloadUrl withUploadDate:(NSString*)uploadDate
{
    NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *searchMovieUrlString = [NSString stringWithFormat:RottenTomatoesMovieAPIUrl,urlEncodedSearchText,(unsigned long)1];
    NSURL *searchMovieUrl = [NSURL URLWithString:searchMovieUrlString];
    NSURLRequest *searchMovieUrlRequest = [NSURLRequest requestWithURL:searchMovieUrl];
    searchMovieUrlRequest.downloadUrl = downloadUrl;
    searchMovieUrlRequest.uploadDate = uploadDate;
    searchMovieUrlRequest.searchText = searchText;
    double delay = self.requestIndex.doubleValue * 0.4;
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
        //NSString* jsonString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        //NSLog(@"jsonString: %@", jsonString);
        JBFMovie *movieSearchResult = [JBFJSON2MovieParser movieSearchResultFromJSONData:self.receivedData];
        if(movieSearchResult==nil){
            JBFMovie *movieSearchResult = [[JBFMovie alloc] init];
            movieSearchResult.title = connection.originalRequest.searchText;
            NSLog(@"No Rotten Tomatoes result for: %@",movieSearchResult.title);
        }
            
        movieSearchResult.downloadUrl = connection.originalRequest.downloadUrl;
        movieSearchResult.uploadDate = connection.originalRequest.uploadDate;
        [self.delegate finishedSearchRequest:movieSearchResult];
    }
    
}

@end
