//
//  SKEAsteroid.h
//  SKEAsteroids
//
//  Created by Tom Elliott on 13/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define ASTEROID_TYPE_SMALL 0
#define ASTEROID_TYPE_MEDIUM 1
#define ASTEROID_TYPE_LARGE 2

@interface SKEAsteroid : SKShapeNode

-(id)initWithType:(int) type position:(CGPoint) position;

@property (nonatomic) int type;
@property (nonatomic) CGFloat radius;
@property (nonatomic) int score;

@end
