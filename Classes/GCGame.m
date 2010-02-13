//
//  GCGame.m
//  GamesmanMobile
//
//  Created by Kevin Jorgensen on 1/29/10.
//  Copyright 2010 GamesCrafters. All rights reserved.
//

#import "GCGame.h"


@implementation GCGame

// Return the game's name
- (NSString *) gameName { return nil; }

// Getters for the player names
- (NSString *) player1Name { return nil; }
- (NSString *) player2Name { return nil; }

// Setters for the player names
- (void) setPlayer1Name: (NSString *) p1 { }
- (void) setPlayer2Name: (NSString *) p2 { }

// Getter for Player 1 Human/Computer
- (BOOL) isPlayer1Human { return YES; }
// Getter for Player 2 Human/Computer
- (BOOL) isPlayer2Human { return YES; }

// Setter for Player 1 Human/Computer
- (void) setPlayer1Human: (BOOL) human { }
// Setter for Player 2 Human/Computer
- (void) setPlayer2Human: (BOOL) human { }

// Return YES for supported mode(s)
- (BOOL) supportsPlayMode: (PlayMode) mode { return NO; }

// Return the option menu
- (UIViewController *) optionMenu { return nil; }

// Return the game's view controller
- (UIViewController *) gameViewController { return nil; }

// Do anything necessary to get the game started (return NO if something fails)
- (void) startGame { }

// Getters for Predictions and Move Values
- (BOOL) predictions { return NO; }
- (BOOL) moveValues { return NO; }

// Setters for Predictions and Move Values
// Must update the view to reflect the new settings
- (void) setPredicitons: (BOOL) pred { }
- (void) setMoveValues: (BOOL) move { }

// Return YES if Forward buttons should be enabled
- (BOOL) forwardPossible { return NO; }
// Return YES if Backward buttons should be enabled
- (BOOL) backwardPossible { return NO; }

// Handle one position forward
- (void) stepForward { }
// Handle one position backward
- (void) stepBackward { }

// Handle jump forward to "end"
- (void) jumpForward { }
// Handle jump backward to beginning
- (void) jumpBackward { }

// Return the current board
- (id) getBoard { return nil; }

// Return the name of the player whose turn it is
- (NSString *) getPlayer { return nil; }

// Return the value of the current board
- (GameValue) getValue { return UNAVAILABLE; }

// Return the remoteness of the current board (or -1 if not available)
- (NSInteger) getRemoteness { return -1; }

// Return the value of MOVE
- (GameValue) getValueOfMove: (id) move { return UNAVAILABLE; }

// Return the remoteness of MOVE (or -1 if not available)
- (NSInteger) getRemotenessOfMove: (id) move { return -1; }

// Return an array of legal moves using the current board
- (NSArray *) legalMoves { return nil; }

// Return YES if THEBOARD is primitive, NO if not
- (BOOL) isPrimitive: (id) theBoard  { return NO; }

// Ask the user for input
- (void) askUserForInput { }

// End asking for user input
- (void) stopUserInput { }

// Ask if the current player is a human
- (BOOL) currentPlayerIsHuman { return YES; }

// Get the move the user chose (only called after the GameController receives a notification)
- (id) getHumanMove { return nil; }

// Perform MOVE and update the view accordingly
- (void) doMove: (id) move { }

@end