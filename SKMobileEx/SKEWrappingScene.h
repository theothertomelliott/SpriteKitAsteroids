//
//  SKEWrappingScene.h
//  SKEAsteroids
//
//  Created by Tom Elliott on 27/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEWrappingScene : SKScene <SKPhysicsContactDelegate>

- (SKLabelNode*) makeDefaultLabelWithPosition:(CGPoint) position horizontalAlignment:(SKLabelHorizontalAlignmentMode) haMode;

@end
