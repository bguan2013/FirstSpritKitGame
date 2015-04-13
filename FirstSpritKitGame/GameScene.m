//
//  GameScene.m
//  FirstSpritKitGame
//
//  Created by Bo Guan on 12/26/14.
//  Copyright (c) 2014 Bo Guan. All rights reserved.
//

#import "GameScene.h"

static const uint32_t projectileCategory = 0x1 << 0;
static const uint32_t monsterCategory = 0x1 << 1;
static const uint32_t playerCategory = 0x1 << 2;

@interface GameScene() <SKPhysicsContactDelegate>

@property(nonatomic)SKSpriteNode *player;
@property(nonatomic)NSTimeInterval timePassedSinceLastSpawn;
@property(nonatomic)NSTimeInterval timeNeededToSpawn;

@property(nonatomic)BOOL dead;



@end

@implementation GameScene



-(id)initWithSize:(CGSize)size{
    
    if(self = [super initWithSize:size]){
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.dead = NO;
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
        self.player.physicsBody.dynamic = YES;
        self.player.physicsBody.categoryBitMask = playerCategory;
        self.player.physicsBody.contactTestBitMask = monsterCategory;
        self.player.physicsBody.collisionBitMask = monsterCategory;
        self.player.physicsBody.usesPreciseCollisionDetection = YES;
        
        
        
        //addChild adds the node to the scene
        [self addChild:self.player];
        
        self.timeNeededToSpawn = (NSTimeInterval)2.0;
        self.timePassedSinceLastSpawn =(NSTimeInterval)0.0;
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = (id)self;
        
        
        
    }
    
    return self;
    
}

-(void)addMonster{
    
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    int minY = monster.size.height/2;
    int maxY = self.size.height-monster.size.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    monster.position = CGPointMake(self.size.width+monster.size.width/2, actualY);
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory | playerCategory;
    
    //0 means it will not collide with any one
    monster.physicsBody.collisionBitMask = playerCategory;
    
    [self addChild:monster];
    
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    SKAction *move = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction *removeMonster = [SKAction removeFromParent];
    
    [monster runAction:[SKAction sequence:@[move, removeMonster]]];
    
    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if(self.timePassedSinceLastSpawn == 0.0){
        
        
        self.timePassedSinceLastSpawn = currentTime;
    }
    
    NSTimeInterval timePassed = currentTime - self.timePassedSinceLastSpawn;
    
    if(timePassed >= self.timeNeededToSpawn){
        
        [self addMonster];
        self.timePassedSinceLastSpawn = currentTime;
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *anyTouch = [touches anyObject];
    
    SKAction *move = [SKAction moveTo:CGPointMake(self.player.position.x, [anyTouch locationInNode:self].y) duration: 0.4];
    
    if([anyTouch locationInNode:self].x <= self.frame.size.width/2){
    
    [self.player runAction:move];
    
    }
    
}


//This is called when touches end
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
   
        UITouch *anyTouch = [touches anyObject];
    //CGPoint location = [anyTouch locationInNode:self];
    
    
        if([anyTouch locationInNode:self].x >= self.frame.size.width/2){
            
            CGPoint location = self.player.position;
        
            SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
        
            projectile.position = location;
            
            projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
            projectile.physicsBody.dynamic = YES;
            projectile.physicsBody.categoryBitMask = projectileCategory;
            projectile.physicsBody.contactTestBitMask = monsterCategory;
            projectile.physicsBody.collisionBitMask = 0;
            projectile.physicsBody.usesPreciseCollisionDetection = YES;
        
            [self addChild:projectile];
        
        
            SKAction *shoot = [SKAction moveTo:CGPointMake(location.x+self.frame.size.width, location.y) duration: 1.0];
        
            SKAction *removeFromScene = [SKAction removeFromParent];
        
            [projectile runAction:[SKAction sequence:@[shoot, removeFromScene]]];
        
    
        }
    

}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    SKPhysicsBody *bodyA = contact.bodyA;
    SKPhysicsBody *bodyB = contact.bodyB;
    
    if(bodyA.categoryBitMask > bodyB.categoryBitMask){
        
        if((bodyA.categoryBitMask == monsterCategory) && (bodyB.categoryBitMask == projectileCategory)){
            
            NSLog(@"Hit!");
            [bodyA.node removeFromParent];
            [bodyB.node removeFromParent];
            
            //Animation here
            
        }
        else if((bodyA.categoryBitMask == playerCategory) && (bodyB.categoryBitMask == monsterCategory)){
            
            
            
            if(!self.dead){
                
                self.dead = YES;
                //UIAlertView to show to play again
                UIAlertView *youAreDead = [[UIAlertView alloc] initWithTitle:@"You are dead!" message:@"Play again?" delegate:self.thisGameViewController cancelButtonTitle:@"Cancel" otherButtonTitles:@"Play!", nil];
                
                [youAreDead show];
            }
        }
        
        
    }
    else{
        if((bodyB.categoryBitMask == monsterCategory) && (bodyA.categoryBitMask == projectileCategory)){
            
            NSLog(@"Hit!");
            [bodyA.node removeFromParent];
            [bodyB.node removeFromParent];
            
            //Animation here
            
        }
        else if((bodyB.categoryBitMask == playerCategory) && (bodyA.categoryBitMask == monsterCategory)){
            
            
            if(!self.dead){
                
                self.dead = YES;
                //UIAlertView to show to play again
                UIAlertView *youAreDead = [[UIAlertView alloc] initWithTitle:@"You are dead!" message:@"Play again?" delegate:self.thisGameViewController cancelButtonTitle:@"Cancel" otherButtonTitles:@"Play!", nil];
            
                [youAreDead show];
            }
        }
        
        
    }
    
    
}


@end
