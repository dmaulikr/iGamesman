//
//  GCConnectionsView.h
//  iGamesman
//
//  Created by Kevin Jorgensen on 1/20/12.
//  Copyright (c) 2012 GamesCrafters. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GCConnectionsViewDelegate;

@interface GCConnectionsView : UIView
{
    id<GCConnectionsViewDelegate> delegate;
    CGPoint backgroundCenter;
    
    BOOL acceptingTouches;
}

@property (nonatomic, assign) id<GCConnectionsViewDelegate> delegate;
@property (nonatomic, assign) CGPoint backgroundCenter;

- (void) startReceivingTouches;
- (void) stopReceivingTouches;

@end



@class GCConnectionsPosition;

@protocol GCConnectionsViewDelegate

- (GCConnectionsPosition *) position;
- (NSArray *) generateMoves;
- (void) userChoseMove: (NSNumber *) slot;

@end