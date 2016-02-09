//
//  JBFMovieSyncer.m
//  MoviePlex
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import "JBFMovieSyncer.h"
#import "JBFCoreDataStack.h"
#import "JBFMovie.h"
#import "NSString+NSStringAddition.h"

NSString *const MovieListingUrl = @"http://brentium.sea.i.extrahop.com/movies/";
NSString *const XpathRows = @"//tbody/tr";
NSString *const XpathLink = @"td[1]/a/@href";
NSString *const XpathUploadDate = @"td[@class='m']";

@interface JBFMovieSyncer()

@property JBFRottenTomatoesMovieSearch *rottenTomatoesMovieSearch;
@property (strong,nonatomic) NSMutableData *receivedData;

@end

@implementation JBFMovieSyncer

-(id)init {
    if (self = [super init])  {
        self.rottenTomatoesMovieSearch = [[JBFRottenTomatoesMovieSearch alloc] init];
        self.rottenTomatoesMovieSearch.delegate = self;
    }
    return self;
}

-(void)syncMovies {
    //read links from directory
    NSURL *movieListingUrl = [NSURL URLWithString:MovieListingUrl];
    NSURLRequest *movieListingUrlRequest = [NSURLRequest requestWithURL:movieListingUrl];
    NSURLConnection *movieListingUrlConnection = [[NSURLConnection alloc] initWithRequest:movieListingUrlRequest delegate:self];
    [movieListingUrlConnection start];
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
    //convert the directory listing to html
    NSError *error;
    NSXMLDocument *document =
    [[NSXMLDocument alloc] initWithData:self.receivedData options:NSXMLDocumentTidyHTML error:&error];
    
    NSXMLElement *rootNode = [document rootElement];
  
    //get the listing rows
    NSArray *rowNodes = [rootNode nodesForXPath:XpathRows error:&error];
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    
    //now query core data to see if movies already exist
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Movie"];
    for(NSXMLNode *rowNode in rowNodes){
        NSArray *linkNodes = [rowNode nodesForXPath:XpathLink error:&error];
        NSXMLNode *linkNode = linkNodes[0];
        if([linkNode.stringValue containsString:@".mkv"]){
            NSString *linkString = [NSString stringWithFormat:@"%@%@",MovieListingUrl,linkNode.stringValue];
            //see if this movie exists in core data already
            //if it does skip else add it
            NSPredicate *predicate =[NSPredicate predicateWithFormat:@"downloadUrl==%@",linkString];
            fetchRequest.predicate=predicate;
            NSError *error = nil;
            NSArray *array = [childManagedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (array == nil || [array count] == 0) {
                NSArray *uploadNodes = [rowNode nodesForXPath:XpathUploadDate error:&error];
                NSString *searchString = [[linkNode.stringValue stringByDeletingPathExtension] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSXMLNode *updateDateNode = uploadNodes[0];
                NSString *uploadDateString = [updateDateNode.stringValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0];
                
                [self.rottenTomatoesMovieSearch searchForMovie:searchString withDownloadUrl:linkString withUploadDate:uploadDateString];
            }
        }
    }
    
}

-(void)finishedSearchRequest:(NSMutableDictionary*)result{
    //we have an update
    //therefore persist it and then notify
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    
    JBFMovie *newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:childManagedObjectContext];
    
    newMovie.title = result[@"title"];
    newMovie.year = result[@"year"] ;
    newMovie.mpaaRating = result[@"mpaa_rating"];
    newMovie.runtime = [NSNumber numberWithInteger: [result[@"runtime"] integerValue]];
    newMovie.synopsis = result[@"synopsis"];
    newMovie.thumbnailUrl = result[@"posters"][@"thumbnail"];
    newMovie.releaseDate = result[@"release_dates"][@"theater"];
    newMovie.downloadUrl = result[@"downloadUrl"];
    newMovie.uploadDate = result[@"uploadDate"];

    NSMutableArray *castArr = [NSMutableArray new];
    for(NSDictionary *thisCastDict in result[@"abridged_cast"]){
        [castArr addObject:thisCastDict[@"name"]];
    }
    newMovie.cast = [NSString stringFromArray:castArr];
    
    NSError *error = nil;
    if (![childManagedObjectContext save:&error]) {
        NSLog(@"Error saving inserting new movie in child MOC: %@", error);
    }
    
    if([self.delegate respondsToSelector:@selector(moviesUpdated)])
        [self.delegate moviesUpdated];
}


@end
