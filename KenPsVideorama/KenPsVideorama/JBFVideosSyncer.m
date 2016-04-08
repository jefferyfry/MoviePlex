//
//  JBFvideoSyncer.m
//  KenPsVideorama
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import "JBFVideosSyncer.h"
#import "JBFCoreDataStack.h"
#import "JBFVideo.h"
#import "NSString+NSStringAddition.h"
#import "JBFGenre.h"

NSString *const MovieListingUrl = @"https://brentium.sea.i.extrahop.com/movies/Movies";
NSString *const TvListingUrl = @"https://brentium.sea.i.extrahop.com/movies/TV%20Shows";
NSString *const OtherListingUrl = @"https://brentium.sea.i.extrahop.com/movies/Other";
NSString *const XpathRows = @"//tbody/tr";
NSString *const XpathLink = @"td[@class='n']/a/@href";
NSString *const XpathUploadDate = @"td[@class='m']";

@interface JBFVideosSyncer() <NSUserNotificationCenterDelegate>

@property JBFVideoSearch *videoSearch;
@property (strong,nonatomic) NSMutableData *receivedData;
@property (strong,nonatomic) NSImage *notificationImage;

@end

@implementation JBFVideosSyncer

-(id)init {
    if (self = [super init])  {
        self.videoSearch = [[JBFVideoSearch alloc] init];
        self.videoSearch.delegate = self;
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        NSString *iconLoc = [[NSBundle mainBundle] pathForResource:@"videorama22x22" ofType:@"png"];
        _notificationImage = [[NSImage alloc] initWithContentsOfFile:iconLoc];
    }
    return self;
}

-(void)syncVideos {
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self selector:@selector(syncMovies)
                                   userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self selector:@selector(syncTVShows)
                                   userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self selector:@selector(syncOther)
                                   userInfo:nil repeats:NO];
}

-(void)syncMovies{
    [self getListingUrl:MovieListingUrl];
}

-(void)syncTVShows{
    [self getListingUrl:TvListingUrl];
}

-(void)syncOther{
    [self getListingUrl:OtherListingUrl];
}

-(void)getListingUrl:(NSString*)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConnection start];
}


-(void)resetVideosDb {
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Video"];
    NSArray *result = [childManagedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (id video in result)
        [childManagedObjectContext deleteObject:video];
    NSError *error = nil;
    if (![childManagedObjectContext save:&error]) {
        NSLog(@"Error deleting all videos in child MOC: %@", error);
    }
    [self syncVideos];
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
        //convert the directory listing to html
        NSError *error;
        NSXMLDocument *document =
        [[NSXMLDocument alloc] initWithData:self.receivedData options:NSXMLDocumentTidyHTML error:&error];
        
        NSXMLElement *rootNode = [document rootElement];
      
        //get the listing rows
        NSArray *rowNodes = [rootNode nodesForXPath:XpathRows error:&error];
        NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
        
        //now query core data to see if videos already exist
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Video"];
        for(NSXMLNode *rowNode in rowNodes){
            NSArray *linkNodes = [rowNode nodesForXPath:XpathLink error:&error];
            NSXMLNode *linkNode = linkNodes[0];
            if([linkNode.stringValue hasSuffix:@".mkv"]||[linkNode.stringValue hasSuffix:@".mp4"]){
                NSString *fullPath = [[[[connection currentRequest] URL].absoluteString stringByAppendingString:@"/"] stringByAppendingString:linkNode.stringValue];
                //see if this video exists in core data already
                //if it does skip else add it
                NSPredicate *predicate =[NSPredicate predicateWithFormat:@"downloadUrl==%@",fullPath];
                fetchRequest.predicate=predicate;
                NSError *error = nil;
                NSArray *array = [childManagedObjectContext executeFetchRequest:fetchRequest error:&error];
                if (array == nil || [array count] == 0) {
                    NSArray *uploadNodes = [rowNode nodesForXPath:XpathUploadDate error:&error];
                    NSString *searchString = [[linkNode.stringValue stringByDeletingPathExtension] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSXMLNode *updateDateNode = uploadNodes[0];
                    NSString *uploadDateString = [self convertDateString:[updateDateNode.stringValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0]];
                    NSLog(@"%@",fullPath);
                    [self.videoSearch searchForVideo:searchString withDownloadUrl:fullPath withUploadDate:uploadDateString];
                }
            }
            else if([linkNode.stringValue hasSuffix:@"/"] && ![linkNode.stringValue hasSuffix:@"../"]){ //go into a directory
                NSString *fullPath = [[[[connection currentRequest] URL].absoluteString stringByAppendingString:@"/"] stringByAppendingString:linkNode.stringValue];
                NSURL *dirListingUrl = [NSURL URLWithString:fullPath];
                NSURLRequest *dirListingUrlRequest = [NSURLRequest requestWithURL:dirListingUrl];
                NSURLConnection *dirListingUrlConnection = [[NSURLConnection alloc] initWithRequest:dirListingUrlRequest delegate:self];
                [dirListingUrlConnection start];
            }
        }
    }
}

-(NSString*)convertReleaseDateString:(NSString*)releaseDateString {
    NSArray *array = [releaseDateString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([array count]>2)
        return [self convertDateString:[NSString stringWithFormat:@"%@-%@-%@",array[2],array[1],array[0]]];
    else
        return [self convertDateString:releaseDateString];
}

-(NSString*)convertDateString:(NSString*)dateString {
    if([dateString rangeOfString:@"Jan"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Jan" withString:@"01"];
    else if([dateString rangeOfString:@"Feb"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Feb" withString:@"02"];
    else if([dateString rangeOfString:@"Mar"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Mar" withString:@"03"];
    else if([dateString rangeOfString:@"Apr"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Apr" withString:@"04"];
    else if([dateString rangeOfString:@"May"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"May" withString:@"05"];
    else if([dateString rangeOfString:@"Jun"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Jun" withString:@"06"];
    else if([dateString rangeOfString:@"Jul"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Jul" withString:@"07"];
    else if([dateString rangeOfString:@"Aug"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Aug" withString:@"08"];
    else if([dateString rangeOfString:@"Sep"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Sep" withString:@"09"];
    else if([dateString rangeOfString:@"Oct"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Oct" withString:@"10"];
    else if([dateString rangeOfString:@"Nov"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Nov" withString:@"11"];
    else //if([dateString rangeOfString:@"Jan"].location != NSNotFound)
        return [dateString stringByReplacingOccurrencesOfString:@"Dec" withString:@"12"];
}


-(void)finishedSearchRequest:(NSMutableDictionary*)result{
    //we have an update
    //therefore persist it and then notify
    NSManagedObjectContext* childManagedObjectContext = [[JBFCoreDataStack sharedStack] newChildManagedObjectContext];
    if(result[@"downloadUrl"]!=nil){
        JBFVideo *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:childManagedObjectContext];
        
        newVideo.title = result[@"Title"];
        newVideo.year = result[@"Year"] ;
        newVideo.mpaaRating = result[@"Rated"];
        newVideo.runtime = result[@"Runtime"];
        newVideo.synopsis = result[@"Plot"];
        if(result[@"Genre"]!=nil){
            newVideo.genre = result[@"Genre"];
            [self addGenres:result[@"Genre"]];
        }
        if([result[@"Poster"] containsString:@"http"])
            newVideo.thumbnailUrl = result[@"Poster"];
        if([result[@"Released"] isEqualToString:@"N/A"])
            newVideo.releaseDate = @" ";
        else
            newVideo.releaseDate = [self convertReleaseDateString:result[@"Released"]];
        newVideo.downloadUrl = result[@"downloadUrl"];
        newVideo.uploadDate = result[@"uploadDate"];
        if([result[@"Metascore"] isEqualToString:@"N/A"])
            newVideo.rating = @" ";
        else
            newVideo.rating = result[@"Metascore"];
        newVideo.actors = result[@"Actors"];
        newVideo.downloaded = NO;
        
        //movie, tv or other
        if([newVideo.downloadUrl rangeOfString:@"Movies/"].location != NSNotFound)
            newVideo.type = @"Movie";
        else if([newVideo.downloadUrl rangeOfString:@"Shows/"].location != NSNotFound)
            newVideo.type = @"TV";
        else //if([newVideo.downloadUrl rangeOfString:@"Other/"].location != NSNotFound)
            newVideo.type = @"Other";
        
        NSError *error = nil;
        if (![childManagedObjectContext save:&error]) {
            NSLog(@"Error saving inserting new video in child MOC: %@", error);
        }
        
        if([self.delegate respondsToSelector:@selector(videosUpdated)])
            [self.delegate videosUpdated];
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"New Video!";
        notification.informativeText = [NSString stringWithFormat:@"%@ was uploaded!",newVideo.title];
        notification.soundName = NSUserNotificationDefaultSoundName;
        //[notification setValue:self.notificationImage forKey:@"_identityImage"];
        if(newVideo.thumbnailUrl!=nil){
            NSURL *imageUrl = [NSURL URLWithString:newVideo.thumbnailUrl];
            NSImage *thumbnailImage = [[NSImage alloc] initWithContentsOfURL:imageUrl];
            [notification setValue:thumbnailImage forKey:@"contentImage"];
        }
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
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

-(void)addGenres:(NSString*)genres {
    NSManagedObjectContext* managedObjectContext = [[JBFCoreDataStack sharedStack] rootManagedObjectContext];
    NSArray *names = [genres componentsSeparatedByString:@","];
    for(id name in names){
        NSString *nameTrim = [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        //query for genre, if it doesn't exist then add it
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Genre"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", nameTrim];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *queryArr = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if([queryArr count]==0){
            JBFGenre *newGenre = [NSEntityDescription insertNewObjectForEntityForName:@"Genre" inManagedObjectContext:managedObjectContext];
            newGenre.name = nameTrim;
            newGenre.count = [NSNumber numberWithInt:1];
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Error saving inserting new genre in child MOC: %@", error);
            }
        }
        else {
            JBFGenre *genre = queryArr[0];
            int value = [genre.count intValue];
            genre.count = [NSNumber numberWithInt:value + 1];
            
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Error saving genre in child MOC: %@", error);
            }
        }
    }
}


@end
