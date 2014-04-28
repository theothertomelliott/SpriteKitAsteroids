//
//  SKEAsteroid.m
//  SKMobileEx
//
//  Created by Tom Elliott on 13/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEAsteroid.h"
#import "CollisionCategories.h"

@implementation SKEAsteroid

-(id)initWithType:(int) type position:(CGPoint) position {
    if((self = [super init]))
    {
        self.type = type;
        if(type == ASTEROID_TYPE_SMALL){
            self.radius = 5;
            self.score = 100;
        }
        else if(type == ASTEROID_TYPE_MEDIUM){
            self.radius = 10;
            self.score = 50;
        }
        else if(type == ASTEROID_TYPE_LARGE){
            self.radius = 20;
            self.score = 20;
        }
        [self setPosition:position];
        
        CGMutablePathRef circlePath = CGPathCreateMutable();
        CGPathAddEllipseInRect(circlePath , NULL , CGRectMake(-self.radius, -self.radius, self.radius*2, self.radius*2) );
        self.path = circlePath;
        self.lineWidth = 1.0f;
        
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius];
        self.physicsBody.friction = 0.0f;
        
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask = asteroidCategory | wraparoundCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = missileCategory;
        
    }
    return self;
}

@end
