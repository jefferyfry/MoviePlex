//
//  JBFVideoSearch.h
//  KenPsVideorama
//
//  Created by Jeffery Fry on 2/6/2016.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFVideo.h"

@protocol JBFVideoSearchDelegate <NSObject>

-(void)finishedSearchRequest:(NSDictionary*)videoDict;

@end

@interface JBFVideoSearch : NSObject <NSURLConnectionDataDelegate>

@property (weak) id<JBFVideoSearchDelegate> delegate;

-(void)searchForVideo:(NSString*)searchText withDownloadUrl:(NSString*)downloadUrl withUploadDate:(NSString*)uploadDate;

@end
