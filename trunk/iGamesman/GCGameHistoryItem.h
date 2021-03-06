//
//  GCGameHistoryItem.h
//  iGamesman
//
//  Created by Kevin Jorgensen on 11/23/11.
//  Copyright (c) 2011 GamesCrafters. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCGame.h"

@interface GCGameHistoryItem : NSObject
{
    /* The position */
    GCPosition *_position;
    
    /* The player */
    GCPlayerSide _player;
    
    /* The move that led to the position */
    GCMove *_move;
    
    /* The value of the position */
    GCGameValue *_value;
    
    /* The remoteness of the position */
    NSInteger _remoteness;
    
    /* A map (move->value) of the values of the moves that can be made from the position */
    NSMutableDictionary *_moveValues;
    
    /* A map (move->remoteness) of the remotenesses of the moves that can be made from the position */
    NSMutableDictionary *_moveRemotenesses;
}

- (id) initWithPosition: (GCPosition *) position
                 player: (GCPlayerSide) side
                   move: (GCMove *) move
                  value: (GCGameValue *) value
             remoteness: (NSInteger) remoteness;

- (GCPosition *) position;
- (GCPlayerSide) playerSide;
- (GCMove *) move;
- (GCGameValue *) value;
- (NSInteger) remoteness;
- (NSArray *) moves;
- (GCGameValue *) valueForMove: (GCMove *) move;
- (NSInteger) remotenessForMove: (GCMove *) move;

- (void) setGameValue: (GCGameValue *) value;
- (void) setRemoteness: (NSInteger) remoteness;

- (void) setGameValue: (NSString *) value remoteness: (NSInteger) remoteness forMove: (GCMove *) move;

@end
