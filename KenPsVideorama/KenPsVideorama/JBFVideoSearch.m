//
//  JBFVideoSearch.m
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFVideoSearch.h"
#import "NSURLRequest+NSURLRequestAddition.h"

NSString *const videoTitleAPIUrl = @"http://www.omdbapi.com/?t=%@&plot=full&r=json";
NSString *const videoTitleYearAPIUrl = @"http://www.omdbapi.com/?t=%@&y=%@plot=full&r=json";

@interface JBFVideoSearch()

@property (strong,nonatomic) NSMutableData *receivedData;
@property (nonatomic, assign) NSNumber *requestIndex;

@end

@implementation JBFVideoSearch

-(id)init {
    if (self = [super init])  {
        _requestIndex = [NSNumber numberWithInt:0];
    }
    return self;
}

-(void)searchForVideo:(NSString*)searchText withDownloadUrl:(NSString*)downloadUrl withUploadDate:(NSString*)uploadDate
{
    NSURL *searchVideoUrl;
    if([searchText containsString:@"("]&&[searchText containsString:@")"]){ //search by string and year
        NSInteger start = [searchText rangeOfString:@"("].location+1;
        NSString *yearString = [[searchText substringFromIndex:start] substringToIndex:5];
        searchText = [searchText substringToIndex:start-1];
        NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *searchVideoUrlString = [NSString stringWithFormat:videoTitleYearAPIUrl,urlEncodedSearchText,yearString];
        searchVideoUrl = [NSURL URLWithString:searchVideoUrlString];
    }
    else { //search by string only
        NSString *urlEncodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *searchVideoUrlString = [NSString stringWithFormat:videoTitleAPIUrl,urlEncodedSearchText];
        searchVideoUrl = [NSURL URLWithString:searchVideoUrlString];
    }
    
    NSURLRequest *searchVideoUrlRequest = [NSURLRequest requestWithURL:searchVideoUrl];
    searchVideoUrlRequest.downloadUrl = downloadUrl;
    searchVideoUrlRequest.uploadDate = uploadDate;
    searchVideoUrlRequest.searchText = searchText;
    double delay = self.requestIndex.doubleValue * 0.05;
    self.requestIndex = [NSNumber numberWithInt:((self.requestIndex.intValue+1)%1000)];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSURLConnection *videoSearchUrlConnection = [[NSURLConnection alloc] initWithRequest:searchVideoUrlRequest delegate:self];
        [videoSearchUrlConnection start];
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
    @synchronized(self){ //multiple threads are accessing need sync
        if([self.delegate respondsToSelector:@selector(finishedSearchRequest:)]){
            NSMutableDictionary *videoSearchResult = [[NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:nil] mutableCopy];
            
            if([videoSearchResult objectForKey:@"Error"]!=nil){
                videoSearchResult = [[NSMutableDictionary alloc] init];
                [videoSearchResult setValue:connection.originalRequest.searchText forKey:@"Title"];
            }
            
            [videoSearchResult setValue:connection.originalRequest.downloadUrl forKey:@"downloadUrl"];
            [videoSearchResult setValue:connection.originalRequest.uploadDate forKey:@"uploadDate"];
            //NSLog(@"%@", videoSearchResult);
            [self.delegate finishedSearchRequest:videoSearchResult];
        }
    }
    
}

@end
