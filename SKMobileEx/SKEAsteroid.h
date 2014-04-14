//
//  SKEAsteroid.h
//  SKMobileEx
//
//  Created by Tom Elliott on 13/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEAsteroid : SKShapeNode

-(id)initWithRadius:(CGFloat) radius andPosition:(CGPoint) position;

@property (nonatomic) CGFloat radius;

@end
