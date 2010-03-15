//
//  GCConnectionsViewController.h
//  GamesmanMobile
//
//  Created by Kevin Jorgensen on 2/21/10.
//  Copyright 2010 GamesCrafters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCConnections.h"


@interface GCConnectionsViewController : UIViewController {
	int size;
	GCConnections *game;
}

- (id) initWithGame: (GCConnections *) _game;
- (void) doMove: (NSNumber *) move;

/// Convenience method for disabling all of the board's buttons.
- (void) disableButtons;
/// Convenience method for enabling all of the board's buttons.
- (void) enableButtons;

@end
