//
//  SKEMissile.m
//  SKMobileEx
//
//  Created by Tom Elliott on 14/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEMissile.h"
#import "CGVectorAdditions.h"
#import "CollisionCategories.h"

@implementation SKEMissile

-(id)initWithPosition:(CGPoint) position andDirection:(CGVector) direction {
    if((self = [super init]))
    {
        
        self.direction = CGVectorNormalize(direction);
        self.position = position;
        
        SKAction *moveMissile = [SKAction moveBy:CGVectorMultiplyByScalar(direction, missileSpeed) duration:1];
        [self runAction:[SKAction repeatActionForever:moveMissile]];
        
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, 0.0f, 0.0f);
        CGPathAddLineToPoint(pathToDraw, NULL, direction.dx, direction.dy);
        
        self.path = pathToDraw;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1.0f];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask = missileCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = asteroidCategory;
        
    }
    return self;
}

@end
