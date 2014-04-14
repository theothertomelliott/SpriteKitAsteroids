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

-(id)initWithRadius:(CGFloat) radius andPosition:(CGPoint)position {
    if((self = [super init]))
    {
        self.radius = radius;
        [self setPosition:position];
        
        CGMutablePathRef circlePath = CGPathCreateMutable();
        CGPathAddEllipseInRect(circlePath , NULL , CGRectMake(-radius, -radius, radius*2, radius*2) );
        self.path = circlePath;
        self.fillColor =  [SKColor whiteColor];
        self.lineWidth=0;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
        self.physicsBody.velocity = CGVectorMake(10.0f, 5.0f);
        
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask = asteroidCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = missileCategory;
        
    }
    return self;
}

@end
