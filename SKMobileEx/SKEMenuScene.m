//
//  SKEMenuScene.m
//  SKEAsteroids
//
//  Created by Tom Elliott on 25/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEMenuScene.h"
#import "SKEGameScene.h"
#import "SKEAsteroid.h"
#import "SKEPersistent.h"

@implementation SKEMenuScene

-(id)initWithSize:(CGSize)size title:(NSString*) title {
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Initializing scene");
        
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        [self addAsteroids:4];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        SKLabelNode* titleLabel = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width/2,
                                                                                 self.frame.size.height-100) horizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
        titleLabel.text = title;
        titleLabel.fontSize = 30;
        
        SKLabelNode* menuLabel = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width/2,
                                                                                self.frame.size.height/2) horizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
        menuLabel.text = @"Touch to start a game";
        
        SKLabelNode* highScoreTitleLabel = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width/2,
                                                                                self.frame.size.height/2 - 80) horizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
        highScoreTitleLabel.text = @"High Score";
        
        SKLabelNode* highScoreLabel = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width/2,
                                                                                          self.frame.size.height/2 - 110) horizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
        highScoreLabel.text = [NSString stringWithFormat:@"%d",[SKEPersistent getHighScore]];
        
    }
    return self;
}

- (void) addAsteroids:(int) count {
    for(int i = 0; i < count; i++){
        
        // Select one each of the x and y coordinates and create position
        int xpos = arc4random_uniform(self.size.width);
        int ypos = arc4random_uniform(self.size.height);
        CGPoint pos = CGPointMake(xpos, ypos);
        
        // Apply a random impulse to get the asteroid moving
        CGVector impulse = CGVectorMake(arc4random_uniform(200)/100.0f, arc4random_uniform(200)/100.0f);
        
        SKEAsteroid* asteroid = [[SKEAsteroid alloc] initWithType:ASTEROID_TYPE_LARGE position:pos];
        [self addChild:asteroid];
        [asteroid.physicsBody applyImpulse:impulse];
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene * scene = [SKEGameScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [self.view presentScene:scene];
}


@end
