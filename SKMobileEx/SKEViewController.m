//
//  SKEViewController.m
//  SKEAsteroids
//
//  Created by Tom Elliott on 07/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEViewController.h"
#import "SKEGameScene.h"
#import "SKEMenuScene.h"

@implementation SKEViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    skView.showsPhysics = NO;
    
    // Create and configure the scene.
    SKScene * scene = [[SKEMenuScene alloc] initWithSize:skView.bounds.size title:@"Asteroids"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
