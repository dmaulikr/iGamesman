//
//  GCOthello.m
//  GamesmanMobile
//
//  Created by Class Account on 9/26/10.
//  Copyright 2010 GamesCrafters. All rights reserved.
//

#import "GCOthello.h"
#import "GCOthelloOptionMenu.h"
#import "GCOthelloViewController.h"

#define BLANK @"+"
#define P1PIECE @"X"
#define P2PIECE @"O"

#define PASS @"PASS"


@implementation GCOthello
@synthesize player1Name, player2Name; 
@synthesize player1Type, player2Type;
@synthesize rows, cols;
@synthesize misere;
@synthesize autoPass;
@synthesize p1Turn;
@synthesize board, myOldMoves;
@synthesize p1pieces, p2pieces;
@synthesize predictions, moveValues;

- (id) init {
	if (self = [super init]) {
		player1Name = @"Player 1";
		player2Name = @"Player 2";
		myOldMoves = [[NSMutableArray alloc] initWithCapacity:rows*cols*2];
		rows = 8;
		cols = 8;
		misere = NO;
		p1Turn = YES;
		p1pieces = 2;
		p2pieces = 2;
		autoPass = NO;
		
		board = [[NSMutableArray alloc] initWithCapacity: rows * cols];
		for (int i = 0; i < rows * cols; i += 1) {
			[board addObject: BLANK];
		}
		int x = rows/2 -1;
		int y = cols/2 -1;
		[board replaceObjectAtIndex:y+x*cols withObject:P1PIECE];
		[board replaceObjectAtIndex:y+x*cols+1 withObject:P2PIECE];
		[board replaceObjectAtIndex:y+(x+1)*cols withObject:P2PIECE];
		[board replaceObjectAtIndex:y+(x+1)*cols+1 withObject:P1PIECE];
	}
	return self;
}

- (UIViewController *) gameViewController {
	return othView;
}

- (PlayMode) playMode {
	return gameMode;
}

- (void) startGameInMode:(PlayMode)mode {
	[self resetBoard];
	
	gameMode = mode;
	
	p1Turn = YES;
	
	if (!othView)
		[othView release];
	othView = [[GCOthelloViewController alloc] initWithGame: self];
}


- (NSString *) gameName {
	return @"Othello";
}


- (NSArray *) getBoard {
	return board;
}

- (Player) currentPlayer {
	return p1Turn ? PLAYER1 : PLAYER2;
}

-(NSArray *) legalMoves {
	NSMutableArray *moves = [[NSMutableArray alloc] initWithCapacity:rows*cols];
	for (int i=0; i< rows*cols; i+=1) {
		if ([[board objectAtIndex:i] isEqualToString:BLANK]) {
			if([[self getFlips: i] count] > 0) {
				[moves addObject: [NSNumber numberWithInt: i]];
			}
		}
	}
	if ([moves count]==0) {
		[moves addObject:PASS];
	}
	return moves;
}

- (NSArray *) getFlips: (int) loc {
	NSMutableArray *flips = [[NSMutableArray alloc] initWithCapacity:rows*cols];
	if ([[board objectAtIndex:loc] isEqualToString:BLANK]) {			
		NSString *myPiece = p1Turn ? P1PIECE : P2PIECE;
		int offsets[8] = {1,-1,cols,-cols,cols+1,cols-1,-cols+1,-cols-1};
		for (int i=0; i<8; i+=1) {
			int offset = offsets[i];
			NSMutableArray *tempFlips = [[NSMutableArray alloc] initWithCapacity:rows*cols];
			int tempLoc = loc;
			while (YES) {
				tempLoc += offset;
				if ([self isOutOfBounds: tempLoc offset:offset]) break;
				if ([[board objectAtIndex:tempLoc] isEqualToString: BLANK]) break; 
				if ([[board objectAtIndex:tempLoc] isEqualToString: myPiece]) {
					[flips addObjectsFromArray: tempFlips];
					break;
				}
				[tempFlips addObject: [NSNumber numberWithInt: tempLoc]];
			}
		}
	}
	
	return flips;
}

- (BOOL) isOutOfBounds: (int) loc offset: (int) offset {
	if (loc < 0 || loc >= rows*cols) {
		return YES;
	}
	if ((offset == -1 || offset == -cols-1 || offset== cols-1) 
		&& (loc % cols == cols-1 )) {
		return YES;
	}
	if ((offset == 1 || offset == cols + 1 || offset== -cols+1) 
		&& (loc % cols == 0)) {
		return YES;
	}
	return NO;
}

- (void) doMove:(NSNumber *)move {
	[othView doMove:move];
	if  ([move intValue] != -1) {
		NSMutableArray *oldBoard = [[NSMutableArray alloc] initWithCapacity: 3];
		[oldBoard addObject:[board copy]];
		[oldBoard addObject:[NSNumber numberWithInt:p1pieces]];
		[oldBoard addObject:[NSNumber numberWithInt:p2pieces]];
		[myOldMoves addObject:oldBoard];
		NSArray *flips = [self getFlips:[move intValue]];
		NSString *myPiece = p1Turn ? P1PIECE : P2PIECE;
		for (NSNumber *x in flips) {		
			[board replaceObjectAtIndex:[x intValue] withObject:myPiece];
		}
		[board replaceObjectAtIndex:[move intValue] withObject:myPiece];
		int changedPieces = [flips count];
		if (p1Turn) {
			p1pieces += changedPieces + 1;
			p2pieces -= changedPieces;
		} else {
			p2pieces += changedPieces + 1;
			p1pieces -= changedPieces;
		}
	} 
	p1Turn = !p1Turn;
	[othView updateLegalMoves];
    [othView updateLabels];
}

- (void) undoMove:(id)move {

	[othView undoMove:move];
	NSArray *b = [[myOldMoves lastObject] retain];
	[myOldMoves removeLastObject];
	board = [[b objectAtIndex:0] mutableCopy];
	p1pieces = [[b objectAtIndex:1] intValue];
	p2pieces = [[b objectAtIndex:2] intValue];
	if ([move intValue] != -1) {
		p1Turn = !p1Turn;
	} 
	[othView updateLegalMoves];
    [othView updateLabels];
}

- (NSString *) primitive {
	if ([[[self legalMoves] objectAtIndex:0] isEqual:PASS]) {
		p1Turn = !p1Turn;
		if ([[[self legalMoves] objectAtIndex:0] isEqual:PASS]) {
			p1Turn = !p1Turn;
			if (p1pieces > p2pieces) {
				if (p1Turn) {
					
					return @"WIN";
				} else{
					return @"LOSE";
				}
			}
			else if (p2pieces > p1pieces) {
				if (p1Turn ) {
					return @"LOSE";
				} else {
					return @"WIN";
				}
			} else {
			 return @"TIE";
			}
		}
		p1Turn = !p1Turn;
	}
	return nil;
}

- (void) notifyWhenReady {
	if (gameMode == OFFLINE_UNSOLVED || gameMode == ONLINE_SOLVED)
		[[NSNotificationCenter defaultCenter] postNotificationName: @"GameIsReady" object: self];
}

- (void) askUserForInput {
	if([[[self legalMoves] objectAtIndex: 0] isEqual: @"PASS"]) {
		if(!autoPass) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Legal Moves" 
															message:@"Click OK to pass"
														   delegate:self
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles: nil];
			[alert show];
			[alert release];
			 
			
			
		} else {
			[self postHumanMove: [NSNumber numberWithInt: -1]];
		}
	} else {
	othView.touchesEnabled = YES;
	}
}

- (void) stopUserInput {
	othView.touchesEnabled = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self postHumanMove: [NSNumber numberWithInt: -1]];
}

- (NSNumber *) getHumanMove {
	return humanMove;
}

- (void) postHumanMove: (NSNumber *) move {
	humanMove = move;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HumanChoseMove" object:self];
}


- (BOOL) supportsPlayMode: (PlayMode) mode {
	return mode == OFFLINE_UNSOLVED || mode == ONLINE_SOLVED;
}

- (UIViewController *) optionMenu {
	return [[GCOthelloOptionMenu alloc] initWithGame: self];
}

- (void) resetBoard {
	myOldMoves = [[NSMutableArray alloc] initWithCapacity:rows*cols*2];
	p1pieces = 2;
	p2pieces = 2;
	if (board != nil) {
		[board release];
		board = nil;
	}
	board = [[NSMutableArray alloc] initWithCapacity: cols * rows];
	for (int i = 0; i < cols * rows; i += 1)
		[board addObject: BLANK];
	
	int x = rows/2 -1;
	int y = cols/2 -1;
	[board replaceObjectAtIndex:x+y*cols withObject:P1PIECE];
	[board replaceObjectAtIndex:x+y*cols+1 withObject:P2PIECE];
	[board replaceObjectAtIndex:x+(y+1)*cols withObject:P2PIECE];
	[board replaceObjectAtIndex:x+(y+1)*cols+1 withObject:P1PIECE];
}


// Return the value of the current board
- (NSString *) getValue {
	int choice = rand() % 3;
	return [[NSArray arrayWithObjects: @"WIN", @"LOSE", @"TIE", nil] objectAtIndex: choice];
}

// Return the remoteness of the current board (or -1 if not available)
- (NSInteger) getRemoteness {
	return rand() % (rows * cols);
}

// Return the value of MOVE
- (NSString *) getValueOfMove: (NSNumber *) move {
	int choice = rand() % 3;
	return [[NSArray arrayWithObjects: @"WIN", @"LOSE", @"TIE", nil] objectAtIndex: choice];
}

// Return the remoteness of MOVE (or -1 if not available)
- (NSInteger) getRemotenessOfMove: (NSNumber *) move {
	return rand() % (rows * cols);
}


// Setter for Predictions
// Must update the view to reflect the new settings
- (void) setPredictions: (BOOL) pred {
	predictions = pred;
	[othView updateLabels];
}


// Setter for Move Values
// Must update the view to reflect the new settings
- (void) setMoveValues: (BOOL) move {
	moveValues = move;
	[othView updateLegalMoves];
}




@end
