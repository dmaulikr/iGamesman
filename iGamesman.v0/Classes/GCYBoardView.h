//
//  GCYBoardView.h
//  GamesmanMobile
//
//  Created by Class Account on 4/29/10.
//  Copyright 2010 GamesCrafters. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCYBoardConnectionsView;

@interface PositionDistance : NSObject {
	NSNumber * myPosition;
	CGFloat myDistance;
}

@property (nonatomic, retain) NSNumber * myPosition;
@property (nonatomic, assign) CGFloat myDistance;

- (id) initWithPosition: (NSNumber *) pos Distance: (CGFloat) dist;
@end


@interface GCYBoardView : UIView {
	int							layers;
	int							innerTriangleLength;
	NSMutableArray				*centers;
	GCYBoardConnectionsView		*connectionsView;
	NSMutableDictionary			*neighborsForPosition;
	NSMutableArray				*outsideCorners;
	CGFloat						circleRadius;
	CGFloat						padding;
	CGPoint						upperCorner;
	CGPoint						rightCorner;
	CGPoint						leftCorner;
	
}

@property (nonatomic, assign) int layers;
@property (nonatomic, assign) int innerTriangleLength;
@property (nonatomic, retain) NSMutableArray  *centers;
@property (nonatomic, retain) NSMutableDictionary *neighborsForPosition;
@property (nonatomic, retain) GCYBoardConnectionsView *connectionsView;
@property (nonatomic, assign) CGFloat circleRadius;



//Stuff ran at initiallization
- (id) initWithFrame:(CGRect)frame withLayers: (int) myLayers andInnerLength: (int) innerLength;
- (void) createBoardView;
- (int) centersAlongLayer: (int) layer fromPointA: (CGPoint) pointA toPointB: (CGPoint) pointB withCenter: (CGPoint) arcCenter startingAtPosition: (int) position;
- (void) calculateConnectionsForPosition: (int) position;

//Stuff that GCYGameVC will need
- (int) boardSize;
- (void) addConnectionFrom: (int) posA to: (int) posB forPlayer: (BOOL) p1;
- (void) removeConnectionFrom: (int) posA forPlayer: (BOOL) p1;
- (NSMutableSet *) edgesForPosition: (NSNumber *) position;


//Helpers
- (CGFloat) distanceFrom: (CGPoint) pointA to: (CGPoint) pointB;
- (int) positionsInTriangle: (int) triangleSideLength;
- (NSMutableArray *) positionsAtEdge: (int) edge;
- (NSMutableArray *) layerPositionsAtEdge: (int) edge;
- (NSMutableArray *) trianglePositionsAtEdge: (int) edge;
- (NSMutableArray *) potentialNeighborsForPosition: (int) pos;
- (int) layerForPos: (int) pos;
- (NSMutableArray *) positionsInLayer: (int) layer;
- (void) drawWinnerLine: (NSMutableArray *) path ForMode: (BOOL) misere;
- (void) removeWinnerLine;

@end
