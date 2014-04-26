//
//  SKEMenuScene.m
//  SKMobileEx
//
//  Created by Tom Elliott on 25/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEMenuScene.h"
#import "SKEGameScene.h"

@implementation SKEMenuScene

-(id)initWithSize:(CGSize)size title:(NSString*) title {
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Initializing scene");
        
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        SKLabelNode* titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        titleLabel.text = title;
        titleLabel.fontSize = 30;
        titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        titleLabel.position = CGPointMake(self.frame.size.width/2,
                                         self.frame.size.height-100);
        
        [self addChild:titleLabel];
        
        SKLabelNode* menuLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        menuLabel.text = @"Touch to start a game";
        menuLabel.fontSize = 16;
        menuLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        menuLabel.position = CGPointMake(self.frame.size.width/2,
                                               self.frame.size.height/2);
        [self addChild:menuLabel];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene * scene = [SKEGameScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [self.view presentScene:scene];
}


@end
