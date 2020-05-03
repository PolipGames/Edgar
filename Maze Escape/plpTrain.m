//
//  plpMyTrain.m
//
//  Edgar The Explorer
//
//  Copyright (c) 2014-2016 Filipe Mathez and Paul Ronga
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation; either version 2.1 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////////////////////////

#import "plpTrain.h"
#import "plpMyScene.h"

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  The train on which Edgar can jump.
//
//................................................


@implementation plpTrain

- (id)initAtPosition:(CGPoint)position withMainTexture:(NSString*)textureString andWheelTexture:(NSString*)wheelTextureString
{
    float _x3 = 3;
    SKTexture *mainTexture = [SKTexture textureWithImageNamed:textureString];
    self = [super initWithTexture:mainTexture];
    
    SKPhysicsBody *mainBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(74*_x3, 5*_x3) center:CGPointMake(0, -2*_x3)];
    SKPhysicsBody *parapet1 = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(4*_x3, 8*_x3) center:CGPointMake(36*_x3, 4*_x3)];
    SKPhysicsBody *parapet2 = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(4*_x3, 8*_x3) center:CGPointMake(-36*_x3, 4*_x3)];
    
    self.physicsBody = [SKPhysicsBody bodyWithBodies:@[mainBody, parapet1, parapet2]];
    
    SKTexture *baseTexture = [SKTexture textureWithImageNamed:@"ChariotBase.png"];
    SKSpriteNode *base = [SKSpriteNode spriteNodeWithTexture:baseTexture];
    base.position = CGPointMake(0, -36);
    
    [self addChild: base];
    
    //    self.physicsBody = [SKPhysicsBody bodyWithTexture: mainTexture alphaThreshold: 0.5 size: CGSizeMake(74, 11)]; -> due to a SpriteKit bug, this doesn't work properly with collision detection. See: http://stackoverflow.com/questions/24228274/why-are-didbegincontact-called-multiple-times
    
    self.position = position;
    self.physicsBody.density = 5000*_x3;
    self.physicsBody.restitution = 0;
    
    SKTexture *textureRoue = [SKTexture textureWithImageNamed:wheelTextureString];
    
    leftWheelNode = [SKSpriteNode spriteNodeWithTexture:textureRoue];
    leftWheelNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:9.5*_x3 center:CGPointMake(0, 0)];
    leftWheelNode.position = CGPointMake(-20*_x3, -19*_x3);
    leftWheelNode.physicsBody.density = 5000*_x3; // 500;
    leftWheelNode.physicsBody.restitution = 0;
    [self addChild: leftWheelNode];
    
    rightWheelNode = [SKSpriteNode spriteNodeWithTexture:textureRoue];
    rightWheelNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:9.5*_x3 center:CGPointMake(0, 0)];
    rightWheelNode.position = CGPointMake(20*_x3, -19*_x3);
    rightWheelNode.physicsBody.density = 5000*_x3; // 500;
    rightWheelNode.physicsBody.restitution = 0;
    [self addChild: rightWheelNode];
    
    trainSound = [[SKAudioNode alloc] initWithFileNamed:@"Sounds/fx_chariot.wav"];
    trainSound.autoplayLooped = false;
    trainSound.position = CGPointMake(0, 0);
    trainSound.positional = true;
    [self addChild: trainSound];
    
    return self;
}

- (SKSpriteNode*)getLeftWheel
{
    return leftWheelNode;
}
- (SKSpriteNode*)getRightWheel
{
    return rightWheelNode;
}

- (void)decelerateAtRate:(float)deceleration
{
    [self removeActionForKey:@"running"];
    isRunning = FALSE;
    SKAction *decelerate;
    
    if (rightWheelNode.physicsBody.angularVelocity > 0) // positive speed -> the train runs left
    {
        decelerate = [SKAction runBlock:^{
            float newSpeed = self->rightWheelNode.physicsBody.angularVelocity - deceleration;
            if(newSpeed < 0){
                [self->trainSound runAction: [SKAction stop]];
                newSpeed = 0;
            }
            
            [self->rightWheelNode.physicsBody setAngularVelocity:newSpeed];
            [self->leftWheelNode.physicsBody setAngularVelocity:newSpeed];
        }];
        
    }else{ // 0 or negative speed -> the train runs right
        decelerate = [SKAction runBlock:^{
            float newSpeed = self->rightWheelNode.physicsBody.angularVelocity + deceleration;
            //            NSLog(@"newSpeed = %f", newSpeed);
            if(newSpeed > 0){
                [self->trainSound runAction: [SKAction stop]];
                newSpeed = 0;
            }
            [self->rightWheelNode.physicsBody setAngularVelocity:newSpeed];
            [self->leftWheelNode.physicsBody setAngularVelocity:newSpeed];
        }];
    }
    SKAction *theBraking = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:.1], decelerate]]];
    
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2], theBraking]] withKey:@"braking"];
}

- (void)accelerateAtRate:(float)acceleration toMaxSpeed:(float)maxSpeed
{
    [self removeActionForKey:@"braking"];
    
    [trainSound runAction: [SKAction play]];
    
    SKAction *accelerate;
    
    // Temporary test - no acceleration to the left
    BOOL enableRunLeft = false;
    
    if( (enableRunLeft) && ([self getVelocityX] < 0)) // if the train already runs left
    {
        accelerate = [SKAction runBlock:^{
            float newSpeed = self->rightWheelNode.physicsBody.angularVelocity + acceleration;
            if(newSpeed > maxSpeed){ // Speed limit / limite de vitesse
                newSpeed = maxSpeed;
            } else if(self->rightWheelNode.physicsBody.angularVelocity < 1){
                [self->trainSound runAction: [SKAction stop]];
            }

            [self->rightWheelNode.physicsBody setAngularVelocity:newSpeed];
            [self->leftWheelNode.physicsBody setAngularVelocity:newSpeed];
            
            if(self->heroAbove){
                contextVelocityX = self.physicsBody.velocity.dx;
            }
            
        }];
    }
    else
    {
        accelerate = [SKAction runBlock:^{
            float newSpeed = self->rightWheelNode.physicsBody.angularVelocity - acceleration;
            if(newSpeed < - maxSpeed){ // Speed limit / limite de vitesse
                newSpeed = - maxSpeed;
            } else if(self->rightWheelNode.physicsBody.angularVelocity > -1){
                [self->trainSound runAction: [SKAction stop]];
            }
            
            [self->rightWheelNode.physicsBody setAngularVelocity:newSpeed];
            [self->leftWheelNode.physicsBody setAngularVelocity:newSpeed];
            if(self->heroAbove){
                contextVelocityX = self.physicsBody.velocity.dx;
            }
        }];
    }
    
    
    SKAction *theMove = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:.1], accelerate]]];
    
    [self runAction: theMove withKey:@"running"];
    isRunning = TRUE;
}

- (float) getVelocityX
{
    return self.physicsBody.velocity.dx;
}

- (void) setHeroAbove
{
    heroAbove = TRUE;
}
- (void) HeroWentAway
{
    heroAbove = FALSE;
}

- (void) setVolume: (float) fxVolume{
    [self->trainSound runAction:[SKAction changeVolumeTo:fxVolume duration:0.1]];
}

@end
