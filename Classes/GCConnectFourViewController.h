//
//  GCConnectFourViewController.h
//  Gamesman
//
//  Created by Kevin Jorgensen on 11/3/09.
//  Copyright 2009 GamesCrafters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCGameView.h"
#import "GCConnectFourService.h"


/**
 Manages the Connect-4 board view and maintains the game play.
 */
@interface GCConnectFourViewController : UIViewController <GCGameView> {
	NSMutableArray *board;			///< Represents the current state of the Connect-4 board
	UILabel *descLabel;				///< Displays messages to the user
	NSArray *colHeads;				///< Contains the buttons along the top row of the board
	GCConnectFourService *service;  ///< Handles the server requests
	int width;						///< The number of columns
	int height;						///< The number of rows
	int pieces;						///< The number in a row needed to win
	BOOL turn;						///< Keeps track of whose turn it is
	BOOL showPredictions;			///< Keeps track of whether or not to display predictions
	BOOL showMoveValues;			///< Keeps track of whether or not to display move values
	NSString *p1Name, *p2Name;
	BOOL p1Human, p2Human;
	UIActivityIndicatorView *spinner;
	NSTimer *timer;
	NSThread *fetch;
}


/// The designated initializer
- (id) initWithWidth: (NSInteger) _width height: (NSInteger) _height pieces: (NSInteger) _pieces 
		 player1Name: (NSString *) player1Name player2Name: (NSString *) player2Name 
		player1Human: (BOOL) p1Hum player2Human: (BOOL) p2Hum;

/// Receives the button taps and interprets them as moves
- (void) tapped: (UIButton *) sender;

- (void) fetchNewData;

- (void) fetchFinished;

- (void) timedOut: (NSTimer *) theTimer;

/// Update the message label and the display of move values
- (void) updateLabels;

/// Disables all of the board's buttons
- (void) disableButtons;

/// Enables all of the board's buttons
- (void) enableButtons;

/// Returns a UIColor for a given game value
- (UIColor *) colorForValue: (NSString *) value;

@end

