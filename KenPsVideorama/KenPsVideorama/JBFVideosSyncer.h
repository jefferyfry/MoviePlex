//
//  JBFvideoSyncer.h
//  KenPsVideorama
//
//  Created by Jeff Fry on 2/8/16.
//  Copyright © 2016 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFVideoSearch.h"
#import "JBFVideo.h"
#import "JBFCoreDataStack.h"

@protocol JBFVideosSyncerDelegate <NSObject>

-(void)videosUpdated;

@end

@interface JBFVideosSyncer : NSObject <NSURLConnectionDataDelegate,JBFVideoSearchDelegate>

@property (weak) id<JBFVideosSyncerDelegate> delegate;

-(void)syncVideos;

-(void)resetVideosDb;

@end
