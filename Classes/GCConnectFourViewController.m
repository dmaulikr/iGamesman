    //
//  GCConnectFourViewController.m
//  GamesmanMobile
//
//  Created by Kevin Jorgensen on 2/5/10.
//  Copyright 2010 GamesCrafters. All rights reserved.
//

#import "GCConnectFourViewController.h"


@implementation GCConnectFourViewController

@synthesize buttonsEnabled;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/**
 The designated initializer.
 
 @param _width the number of columns
 @param _height the number of rows
 @param _pieces the number in a row needed to win
 */
- (id) initWithGame: (GCConnectFour *) _game {
	if (self = [super init]) {
		width  = _game.width;
		height = _game.height;
		pieces = _game.pieces;
		game = _game;
		
		buttonsEnabled = NO;
		
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	}
	return self;
}

#pragma mark Custom class methods
- (void) tapped: (UIButton *) sender {
	int col = sender.tag % width;
	if (col == 0) col = width;
	NSString *move = [NSString stringWithFormat: @"%d", col];
	
	if ([[game legalMoves] containsObject: move])
		[game postHumanMove: move];
}

- (void) updateServerDataWithService: (GCConnectFourService *) _service {
	game.gameReady = NO;
	service = _service;
	[spinner startAnimating];
	waiter = [[NSThread alloc] initWithTarget: self selector: @selector(fetchNewData:) object: [NSNumber numberWithBool:buttonsEnabled]];
	[waiter start];
	timer = [[NSTimer scheduledTimerWithTimeInterval: 60 target: self selector: @selector(timedOut:) userInfo: nil repeats: NO] retain];
}

- (void) fetchNewData: (BOOL) buttonsOn {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread: @selector(disableButtons) withObject: nil waitUntilDone: NO];
	[service retrieveDataForBoard: [game board] width: width height: height pieces: pieces];
	game.gameReady = YES;
	[self performSelectorOnMainThread: @selector(fetchFinished:) withObject: [NSNumber numberWithBool: buttonsOn] waitUntilDone: NO];
	[pool release];
}


- (void) fetchFinished: (BOOL) buttonsOn {
	if (waiter != nil) {
		if (buttonsOn)
			[self enableButtons];
		[spinner stopAnimating];
		[timer invalidate];
	}
	[self updateLabels];
	if (![service connected] || ![service status])
		[game postProblem];
	else {
		game.gameReady = YES;
		[game postReady];
	}
}


- (void) timedOut: (NSTimer *) theTimer {
	message.numberOfLines = 4;
	message.lineBreakMode = UILineBreakModeWordWrap;
	[message setText: @"Server request timed out. Check the strength of your Internet connection."];
	
	[waiter cancel];
	[waiter release];
	waiter = nil;
	[spinner stopAnimating];
}


- (void) updateLabels {
	NSString *player = ([game currentPlayer] == PLAYER1) ? [game player1Name] : [game player2Name];
	NSString *color = ([game currentPlayer] == PLAYER1) ? @"Red" : @"Blue";
	PlayerType type = ([game currentPlayer] == PLAYER1) ? [game player1Type] : [game player2Type];
	message.numberOfLines = 4;
	message.lineBreakMode = UILineBreakModeWordWrap;
	if ([game predictions]) {
		NSString *value = [service getValue];
		int remoteness  = [service getRemoteness];
		if (value != nil && remoteness != -1) {
			NSString *modifier = (type == COMPUTER_PERFECT) ? @"will" : @"should";
			[message setText: [NSString stringWithFormat: @"%@ (%@)\n%@ %@ in %d", player, color, modifier, 
							   value, remoteness]];
		}
	} else {
		[message setText: [NSString stringWithFormat: @"%@ (%@)'s turn", player, color]];
	}
	
	if ([game moveValues]) {
		UIImage *gridTop = [UIImage imageNamed: @"C4GridTopClear.png"];
		int lastTag = width * height;
		for (int i = 0; i < width; i += 1) {
			NSString *currentValue = [service getValueAfterMove: [NSString stringWithFormat: @"%d", i]];
			UIButton *B = (UIButton *) [self.view viewWithTag: i + lastTag - width + 1];
			if ([currentValue isEqualToString: @"win"])
				[B setBackgroundImage: [UIImage imageNamed: @"C4GridTopGreen.png"] forState: UIControlStateNormal];
			else if ([currentValue isEqualToString: @"lose"])
				[B setBackgroundImage: [UIImage imageNamed: @"C4GridTopRed.png"] forState: UIControlStateNormal];
			else if ([currentValue isEqualToString: @"tie"])
				[B setBackgroundImage: [UIImage imageNamed: @"C4GridTopYellow.png"] forState: UIControlStateNormal];
			else
				[B setBackgroundImage: gridTop forState: UIControlStateNormal];
		}
	} else {
		UIImage *gridTop = [UIImage imageNamed: @"C4GridTopClear.png"];
		int lastTag = width * height;
		for (int i = lastTag - width + 1; i <= width * height; i += 1) {
			UIButton *B = (UIButton *) [self.view viewWithTag: i];
			[B setBackgroundImage: gridTop forState: UIControlStateNormal];
		}
	}
	
	if (game.gameMode == ONLINE_SOLVED) {
		if (![service status])
			[message setText: @"Server error. Please try again later"];
		if (![service connected])
			[message setText: @"Server connection failed. Please check your Web connection"];
	}
	
	if ([game isPrimitive: [game getBoard]])
		[self displayPrimitive];
}


- (void) displayPrimitive {
	NSString *value = [service getValue];
	NSString *winner;
	if ([value isEqualToString: @"tie"] || [value isEqualToString: @"draw"])
		message.text = @"It's a tie!";
	else {
		if ([value isEqualToString: @"win"])
			winner = game.p1Turn ? game.player1Name : game.player2Name;
		else
			winner = game.p1Turn ? game.player2Name : game.player1Name;
		message.text = [NSString stringWithFormat: @"%@ wins!", winner];
	}
}


- (void) doMove: (NSString *) move {
	int col = [move integerValue];
	if (col == 0) col = width;
	if ([[game legalMoves] containsObject: move]) {		
		// Update the view. Perform the animation
		int tag = col;
		while (tag < width * height + 1) {
			if ([[[game board] objectAtIndex: tag - 1] isEqual: @"+"])
				break;
			tag += width;
		}
		
		// Now TAG is the tag of the slot we want to add a piece to.
		UIButton *B = (UIButton *) [self.view viewWithTag: tag];
		
		NSString *piece = (game.p1Turn ? @"X" : @"O");
		UIImage *img = [UIImage imageNamed: [NSString stringWithFormat: @"C4%@.png", piece]];
		
		// Set up the piece image view
		double x = [B frame].origin.x;
		double y = [B frame].origin.y;
		double w = [B frame].size.width;
		double h = [B frame].size.height;
		UIImageView *imgView = [[UIImageView alloc] initWithFrame: CGRectMake(x, -30, w, h)];
		[imgView setImage: img];
		imgView.tag = 1234;
		[self.view insertSubview: imgView atIndex: 0];
		
		// Animate the piece
		[UIView beginAnimations: @"Drop" context: NULL];
		[imgView setFrame: CGRectMake(x, y, w, h)];
		[UIView commitAnimations];
	}
}


/** Convenience method for disabling all of the board's buttons. */
- (void) disableButtons {
	for (int i = 1; i < width * height + 1; i += 1) {
		UIButton *B = (UIButton *) [self.view viewWithTag: i];
		[B setEnabled: NO];
	}
	buttonsEnabled = NO;
}


/** Convenience method for enabling all of the board's buttons. */
- (void) enableButtons {
	for (int i = 1; i < width * height + 1; i += 1) {
		UIButton *B = (UIButton *) [self.view viewWithTag: i];
		[B setEnabled: YES];
	}
	buttonsEnabled = YES;
}

- (void) stop {
	if (waiter)
		[waiter cancel];
	if (timer)
		[timer invalidate];
}


#pragma mark View controller delegate methods
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void) viewDidLoad {
    [super viewDidLoad];
	if ([self interfaceOrientation] == UIInterfaceOrientationPortrait)
		self.view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 416)];
	else
		self.view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 480, 256)];
	
	self.view.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 102.0/256.0 alpha: 1];
	
	float squareSize;
	// Come back to this bit later after I figure out how tall the top
	// Row will be to make the move value bigger
	if ([self interfaceOrientation] == UIInterfaceOrientationPortrait)
		squareSize = MIN(300.0 / width, 356.0 / height);
	else
		squareSize = MIN(236.0 / height, 380.0 / width);
	
	UIImage *gridImg = [UIImage imageNamed: @"C4Grid.png"];
	int tagNum = 1;
	for (int j = height - 1; j >= 0; j -= 1) {
		for (int i = 0; i < width; i += 1) {
			UIButton *B = [UIButton buttonWithType: UIButtonTypeCustom];
			[B setFrame: CGRectMake((10 + width/2) + i * (squareSize - 1), 10 + j * (squareSize - 1), squareSize, squareSize)];
			[B setBackgroundImage: gridImg forState: UIControlStateNormal];
			[B addTarget: self action: @selector(tapped:) forControlEvents: UIControlEventTouchUpInside];
			B.adjustsImageWhenDisabled = NO;
			B.tag = tagNum;
			tagNum += 1;
			[self.view addSubview: B];
		}
	}
	
	UIImage *gridTop = [UIImage imageNamed: @"C4GridTopClear.png"];
	int lastTag = width * height;
	for (int i = lastTag - width + 1; i <= width * height; i += 1) {
		UIButton *B = (UIButton *) [self.view viewWithTag: i];
		[B setBackgroundImage: gridTop forState: UIControlStateNormal];
	}
	
	if ([self interfaceOrientation] == UIInterfaceOrientationPortrait)
		message = [[UILabel alloc] initWithFrame: CGRectMake(20, 25 + height * squareSize, 
															   280, 416 - (35 + height * squareSize))];
	else
		message = [[UILabel alloc] initWithFrame: CGRectMake(10 + width * squareSize, 3, 
															   480 - (10 + width * squareSize), 250)];
	message.backgroundColor = [UIColor clearColor];
	message.textColor = [UIColor whiteColor];
	message.textAlignment = UITextAlignmentCenter;
	message.text = @"";
	[self.view addSubview: message];
	
	[spinner setFrame: CGRectMake(width/2.0 * squareSize, height/2.0  * squareSize,  37, 37)];
	[self.view addSubview: spinner];
	
	[self disableButtons];
	
	[self updateLabels];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
	if (width > 5)
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
				interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload {
    [super viewDidUnload];
	[message release];
	[spinner release];
}


- (void) dealloc {
	[spinner release];
    [super dealloc];
}


@end
