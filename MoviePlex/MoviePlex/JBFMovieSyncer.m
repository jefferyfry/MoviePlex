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

@interface JBFMovieSyncer() <NSUserNotificationCenterDelegate>

@property JBFMovieSearch *movieSearch;
@property (strong,nonatomic) NSMutableData *receivedData;
@property (strong,nonatomic) NSImage *notificationImage;

@end

@implementation JBFMovieSyncer

-(id)init {
    if (self = [super init])  {
        self.movieSearch = [[JBFMovieSearch alloc] init];
        self.movieSearch.delegate = self;
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        NSString *iconLoc = [[NSBundle mainBundle] pathForResource:@"movieplex22x22" ofType:@"png"];
        _notificationImage = [[NSImage alloc] initWithContentsOfFile:iconLoc];
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


-(void)resetMoviesDb {
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Movie"];
    NSArray *result = [childManagedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (id movie in result)
        [childManagedObjectContext deleteObject:movie];
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
                NSString *uploadDateString = [self convertUploadDateString:[updateDateNode.stringValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0]];
                
                [self.movieSearch searchForMovie:searchString withDownloadUrl:linkString withUploadDate:uploadDateString];
            }
        }
    }
    
}

-(NSString*)convertUploadDateString:(NSString*)uploadDateString {
    if([uploadDateString containsString:@"Jan"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Jan"
                                                           withString:@"01"];
    else if([uploadDateString containsString:@"Feb"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Feb"
                                                           withString:@"02"];
    else if([uploadDateString containsString:@"Mar"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Mar"
                                                           withString:@"03"];
    else if([uploadDateString containsString:@"Apr"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Apr"
                                                           withString:@"04"];
    else if([uploadDateString containsString:@"May"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"May"
                                                           withString:@"05"];
    else if([uploadDateString containsString:@"Jun"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Jun"
                                                           withString:@"06"];
    else if([uploadDateString containsString:@"Jul"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Jul"
                                                           withString:@"07"];
    else if([uploadDateString containsString:@"Aug"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Aug"
                                                           withString:@"08"];
    else if([uploadDateString containsString:@"Sep"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Sep"
                                                           withString:@"09"];
    else if([uploadDateString containsString:@"Oct"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Oct"
                                                           withString:@"10"];
    else if([uploadDateString containsString:@"Nov"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Nov"
                                                           withString:@"11"];
    else //if([uploadDateString containsString:@"Dec"])
        return [uploadDateString stringByReplacingOccurrencesOfString:@"Dec"
                                                           withString:@"12"];
}

-(void)finishedSearchRequest:(NSMutableDictionary*)result{
    //we have an update
    //therefore persist it and then notify
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    
    JBFMovie *newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:childManagedObjectContext];
    
    newMovie.title = result[@"Title"];
    newMovie.year = result[@"Year"] ;
    newMovie.mpaaRating = result[@"Rated"];
    newMovie.runtime = result[@"Runtime"];
    newMovie.synopsis = result[@"Plot"];
    if([result[@"Poster"] containsString:@"http"])
        newMovie.thumbnailUrl = result[@"Poster"];
    newMovie.releaseDate = result[@"Released"];
    newMovie.downloadUrl = result[@"downloadUrl"];
    newMovie.uploadDate = result[@"uploadDate"];
    newMovie.cast = result[@"Actors"];
    newMovie.downloaded = NO;
    
    NSError *error = nil;
    if (![childManagedObjectContext save:&error]) {
        NSLog(@"Error saving inserting new movie in child MOC: %@", error);
    }
    
    if([self.delegate respondsToSelector:@selector(moviesUpdated)])
        [self.delegate moviesUpdated];
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"New Movie!";
    notification.informativeText = [NSString stringWithFormat:@"%@ was uploaded!",newMovie.title];
    notification.soundName = NSUserNotificationDefaultSoundName;
    //[notification setValue:self.notificationImage forKey:@"_identityImage"];
    if(newMovie.thumbnailUrl!=nil){
        NSURL *imageUrl = [NSURL URLWithString:newMovie.thumbnailUrl];
        NSImage *thumbnailImage = [[NSImage alloc] initWithContentsOfURL:imageUrl];
        [notification setValue:thumbnailImage forKey:@"contentImage"];
    }
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


@end
