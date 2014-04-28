//
//  SKEWrappingScene.m
//  SKEAsteroids
//
//  Created by Tom Elliott on 27/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEWrappingScene.h"
#import "CollisionCategories.h"

@implementation SKEWrappingScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self createWorldBorder];
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

/*
 * Handle contact between two entities
 */
- (void) didBeginContact:(SKPhysicsContact *)contact
{
    
    /*
     * Handle collisions with an edge
     */
    
    // Distance from the edge which a body should be re-introduced to the scene
    CGFloat distance = contact.bodyB.node.frame.size.width/2 + 5.0f;
    
    if(contact.bodyA.categoryBitMask == borderTop){
        NSLog(@"Collision with top");
        SKAction *moveBottom = [SKAction moveTo:CGPointMake(contact.bodyB.node.position.x, distance) duration:0.0f];
        [contact.bodyB.node runAction:moveBottom];
    }
    
    if(contact.bodyA.categoryBitMask == borderLeft){
        NSLog(@"Collision with left");
        SKAction *moveRight = [SKAction moveTo:CGPointMake(self.size.width-distance, contact.bodyB.node.position.y) duration:0.0f];
        [contact.bodyB.node runAction:moveRight];
    }
    
    if(contact.bodyA.categoryBitMask == borderRight){
        NSLog(@"Collision with right");
        SKAction *moveLeft = [SKAction moveTo:CGPointMake(distance, contact.bodyB.node.position.y) duration:0.0f];
        [contact.bodyB.node runAction:moveLeft];
    }
    
    if(contact.bodyA.categoryBitMask == borderBottom){
        NSLog(@"Collision with bottom");
        SKAction *moveTop = [SKAction moveTo:CGPointMake(contact.bodyB.node.position.x, self.size.height-distance) duration:0.0f];
        [contact.bodyB.node runAction:moveTop];
    }

}

/*
 * Create a border between the specified points to handle wraparound
 */
- (void) addBorderFromPoint:(CGPoint)from toPoint:(CGPoint) to withCategory:(int)category {
    
    SKNode* border = [SKNode node];
    border.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:from toPoint:to];
    border.physicsBody.usesPreciseCollisionDetection = YES;
    border.physicsBody.categoryBitMask = category;
    border.physicsBody.collisionBitMask = 0;
    border.physicsBody.contactTestBitMask = wraparoundCategory;
    [self addChild:border];
}

/*
 * Add bodies on each edge of the scene to handle wraparound
 */
- (void) createWorldBorder {
    [self addBorderFromPoint:CGPointMake(0,self.size.height) toPoint:CGPointMake(self.size.width,self.size.height) withCategory:borderTop];
    [self addBorderFromPoint:CGPointMake(0.0f,0.0f) toPoint:CGPointMake(self.size.width,0.0f) withCategory:borderBottom];
    [self addBorderFromPoint:CGPointMake(0.0f,0.0f) toPoint:CGPointMake(0.0f,self.size.height) withCategory:borderLeft];
    [self addBorderFromPoint:CGPointMake(self.size.width,0.0f) toPoint:CGPointMake(self.size.width,self.size.height) withCategory:borderRight];
}

@end
