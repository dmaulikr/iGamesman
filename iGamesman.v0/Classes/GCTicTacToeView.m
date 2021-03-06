//
//  GCTicTacToeView.m
//  GamesmanMobile
//
//  Created by Class Account on 10/8/10.
//  Copyright 2010 GamesCrafters. All rights reserved.
//

#import "GCTicTacToeView.h"


@implementation GCTicTacToeView


- (id)initWithFrame:(CGRect)frame andRows: (int) r andCols: (int) c {
    if ((self = [super initWithFrame:frame])) {
		rows = r;
		cols = c;
		
		self.opaque = NO;
		
		self.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 102.0/256.0 alpha: 1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat w = self.bounds.size.width;
	CGFloat h = self.bounds.size.height;
	
	CGFloat size = MIN((w - 180)/cols, (h - 20)/rows);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(ctx, 4);
	CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
	
	for (int i = 1; i < cols; i += 1) {
		CGContextMoveToPoint(ctx, 10 + size * i, 10);
		CGContextAddLineToPoint(ctx, 10 + size * i, 10 + size * rows);
	}
	
	for (int j = 1; j < rows; j += 1) {
		CGContextMoveToPoint(ctx, 10, 10 + size * j);
		CGContextAddLineToPoint(ctx, 10 + size * cols, 10 + size * j);
	}
	
	CGContextStrokePath(ctx);
}

- (void)dealloc {
    [super dealloc];
}


@end
