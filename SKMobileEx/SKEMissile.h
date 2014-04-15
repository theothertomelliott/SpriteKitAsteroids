//
//  SKEMissile.h
//  SKMobileEx
//
//  Created by Tom Elliott on 14/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static const CGFloat missileSpeed = 50.0f;

@interface SKEMissile : SKShapeNode

-(id)initWithPosition:(CGPoint) position andDirection:(CGVector) direction;

@property (nonatomic) CGVector direction;

@end
