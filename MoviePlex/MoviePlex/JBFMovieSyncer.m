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

//NSString *const MovieListingUrl = @"http://brentium.sea.i.extrahop.com/movies/";
NSString *const MovieListingUrl = @"https://brentium.sea.i.extrahop.com/movies/";
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
    NSError *error = nil;
    if (![childManagedObjectContext save:&error]) {
        NSLog(@"Error deleting all movies in child MOC: %@", error);
    }
    [self syncMovies];
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
                
                [self.movieSearch searchForMovie:searchString withDownloadUrl:linkString withUploadDate:uploadDateString];
            }
        }
    }
    
}

-(NSString*)convertReleaseDateString:(NSString*)releaseDateString {
    NSArray *array = [releaseDateString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([array count]>2)
        return [NSString stringWithFormat:@"%@-%@-%@",array[2],array[1],array[0]];
    else
        return releaseDateString;
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
    newMovie.genre = result[@"Genre"];
    if([result[@"Poster"] containsString:@"http"])
        newMovie.thumbnailUrl = result[@"Poster"];
    if([result[@"Released"] isEqualToString:@"N/A"])
        newMovie.releaseDate = @" ";
    else
        newMovie.releaseDate = [self convertReleaseDateString:result[@"Released"]];
    newMovie.downloadUrl = result[@"downloadUrl"];
    newMovie.uploadDate = result[@"uploadDate"];
    if([result[@"Metascore"] isEqualToString:@"N/A"])
        newMovie.rating = @" ";
    else
        newMovie.rating = [result[@"Metascore"] stringByAppendingString:@"/100"];
    newMovie.actors = result[@"Actors"];
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

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        //if ([trustedHosts containsObject:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


@end
