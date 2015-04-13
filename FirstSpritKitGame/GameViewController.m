//
//  GameViewController.m
//  FirstSpritKitGame
//
//  Created by Bo Guan on 12/26/14.
//  Copyright (c) 2014 Bo Guan. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

// - This is the first method where we have the correct bounds for the device and is called whenever the view controller is changing the display of the view (like device orientation, view loaded) or the UIView is marked as needing a layout

-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    [self setupGameWithView:(SKView *)self.view];
    
    
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setupGameWithView:(SKView *) skView{

        
        //sceneWithSize calls the method initWithSize
        GameScene *myScene = [GameScene sceneWithSize:skView.bounds.size];
        myScene.scaleMode = SKSceneScaleModeAspectFill;
        myScene.thisGameViewController = self;
        
        [skView presentScene:myScene];
        
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex != alertView.cancelButtonIndex){
        
        [self setupGameWithView:(SKView *)self.view];
        
    }
    
}

@end
