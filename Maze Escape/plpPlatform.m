//
//  plpPlatform.m
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

#import "plpPlatform.h"
#import "plpMyScene.h"

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  Horizontal and vertical moving platforms.
//
//................................................

@implementation plpPlatform

typedef NS_OPTIONS(uint32_t, MyPhysicsCategory)
{
    PhysicsCategoryEdgar = 1 << 0,
    PhysicsCategoryObjects = 1 << 1,
    PhysicsCategoryTiles = 1 << 2,
};

- (float)calculateSpeedForDuration:(float)duration fromPosition:(float)initPosition toLimit:(float)limit
{
    float distance = limit - initPosition;
    return distance/duration;
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration upToX:(float)x_limit andY:(float)y_limit andIdleDuration:(float)idleDuration
{
    NSString *texturePath;
    if(x_limit == position.x) // vertical platform
    {
        texturePath = [NSString stringWithFormat:@"Level_objects_img/elevateur-01.png"];
    }else{
        texturePath = [NSString stringWithFormat:@"Level_objects_img/elevateur-02-horizontal.png"];
    }
    
    SKTexture *plateformeTexture = [SKTexture textureWithImageNamed:texturePath];
    
    self = [super initWithTexture:plateformeTexture];
    
    if (self) {
        self.size = size;
        self.position = position;
        initXPosition = position.x;
        initYPosition = position.y;
        
        self.anchorPoint = CGPointMake(0, 0);
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(size.width-2, size.height) center:CGPointMake(size.width/2,size.height/2)];
        self.physicsBody.mass = 20000000000;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.friction = 1;
        self.physicsBody.collisionBitMask = 1;
        self.physicsBody.linearDamping = 0;
        
        self.physicsBody.categoryBitMask = PhysicsCategoryObjects;
        
        SKAction *waitDuration = [SKAction waitForDuration:idleDuration];
        SKAction *moveDuration = [SKAction waitForDuration:duration];
        
        platformSound = [[SKAudioNode alloc] initWithFileNamed:@"Sounds/fx_elevateur.wav"];
        platformSound.autoplayLooped = false;
        platformSound.position = CGPointMake(0, 0);
        platformSound.positional = true;
        [self addChild: platformSound];
        
        // A SKAction doesn't work with physics (Edgar couldn't stand on the platform).
        // Very primitive movement: we just set a constant speed.

        movementDuration = duration;
        float Yspeed = [self calculateSpeedForDuration:duration fromPosition:initYPosition toLimit:y_limit];
        float Xspeed = [self calculateSpeedForDuration:duration fromPosition:initXPosition toLimit:x_limit];
        if(initXPosition == x_limit)
        {
            isVertical = TRUE;
            if(Yspeed > 0)
            {
                motionSpeed = Yspeed; // used in the emergencyStop function (only for vertical platforms)
            }
            else
            {
                motionSpeed = -Yspeed;
            }
            endYPosition = y_limit;
        }
        else // horizontal platform
        {
            if(Xspeed > 0)
            {
                motionSpeed = Xspeed; // used in the emergencyStop function
            }
            else
            {
                motionSpeed = -Xspeed;
            }
            
            endXPosition = x_limit;
        }
        
        SKAction *stop = [SKAction runBlock:^{
            [self.physicsBody setVelocity:CGVectorMake(0, 0)];
            if(self->heroAbove)
            {
                contextVelocityX = 0;
            }
            [self->platformSound runAction: [SKAction stop]];
        }];

        if(isVertical) // vertical movement
        {
            SKAction *verticalMove1 = [SKAction runBlock:^{
                float newSpeed = [self calculateSpeedForDuration: self->movementDuration fromPosition:self.position.y toLimit: self->endYPosition];
                [self.physicsBody setVelocity:CGVectorMake(0, newSpeed)];
                
                // if near Hero
                [self->platformSound runAction: [SKAction play]];
            }];
            
            SKAction *verticalMove2 = [SKAction runBlock:^{
                float newSpeed = [self calculateSpeedForDuration: self->movementDuration fromPosition:self.position.y toLimit:self->initYPosition];
                [self.physicsBody setVelocity:CGVectorMake(0, newSpeed)];
                
                // if near Hero
                [self->platformSound runAction: [SKAction play]];
            }];
            
            SKAction *verticalSequence = [SKAction sequence:@[waitDuration, verticalMove1, moveDuration, stop, waitDuration, verticalMove2, moveDuration, stop]];
            [self runAction:[SKAction repeatActionForever: verticalSequence]];
        
        }else{ // horizontal movement
            
            SKAction *horizontalMove1 = [SKAction runBlock:^{
                [self horizontalMoveWithDuration: self->movementDuration forward: TRUE];
                
                // if near Hero
                [self->platformSound runAction: [SKAction play]];
            }];
            
            SKAction *horizontalMove2 = [SKAction runBlock:^{
                [self horizontalMoveWithDuration: self->movementDuration forward: FALSE];
                
                // if near Hero
                [self->platformSound runAction: [SKAction play]];
            }];
            
            standardSequence = [SKAction sequence:@[waitDuration, horizontalMove1, moveDuration, stop, waitDuration, horizontalMove2, moveDuration, stop]];
            [self runAction:[SKAction repeatActionForever: standardSequence]];
        }
    }
    return self;
}

- (void) horizontalMoveWithDuration: (float) theDuration forward: (BOOL) forward
{
    float newSpeed;
    if(forward == TRUE)
    {
        newSpeed = [self calculateSpeedForDuration:theDuration fromPosition:self.position.x toLimit:endXPosition];
    }else{
        newSpeed = [self calculateSpeedForDuration:theDuration fromPosition:self.position.x toLimit:initXPosition];
    }
    [self.physicsBody setVelocity:CGVectorMake(newSpeed, 0)];
    if(heroAbove)
    {
        contextVelocityX = newSpeed;
    }
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration upToX:(float)x_limit andY:(float)y_limit
{
    
    return [self initAtPosition:position withSize:size withDuration:duration upToX:x_limit andY:y_limit andIdleDuration:2];
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration withMovement:(float)movement
{
    return [self initAtPosition:position withSize:size withDuration:duration upToX:position.x + movement andY:position.y];
}

- (float) getVelocityX
{
    return self.physicsBody.velocity.dx;
}

- (BOOL) heroIsNearby
{
    
    return FALSE;
}

- (void) setHeroAbove
{
    heroAbove = TRUE;
}
- (void) HeroWentAway
{
    heroAbove = FALSE;
}

- (void) setHeroNear
{
    heroNear = TRUE;
}
- (void) setHeroAway
{
    heroNear = FALSE;
}

- (BOOL) getIsVertical
{
    return isVertical;
}

// To handle the cases where no "emergency stop" and backward movement is desired (see emergencyStop function)
- (void) setNoEmergencyStop
{
    noEmergencyStop = TRUE;
}

// When our main character could be stucked under an elevator
- (void) emergencyStop
{
    // Condition: only if the platform is moving down
    if(self.physicsBody.velocity.dy < 0 && !emergencyStopTriggered && !noEmergencyStop)
    {
        emergencyStopTriggered = TRUE; // to avoid simoultaneous calls
        [self->platformSound runAction: [SKAction sequence:@[ [SKAction stop], [SKAction play] ] ] ];

        [self setSpeed: 0]; // We pause the animation
        [self.physicsBody setVelocity:CGVectorMake(0, motionSpeed)]; // We invert the direction
        
        SKAction *delay = [SKAction waitForDuration: .5];

        [self.scene runAction: delay completion:^
        {
            [self.physicsBody setVelocity:CGVectorMake(0, 0)];
            [self->platformSound runAction: [SKAction stop] ];

            [self.scene runAction: [SKAction waitForDuration: 2] completion:^
            {
                [self.physicsBody setVelocity:CGVectorMake(0, -self->motionSpeed)];
                [self->platformSound runAction: [SKAction play] ];

                [self.scene runAction: delay completion:^
                {
                    NSLog(@"Animation runs again");
                    self->emergencyStopTriggered = FALSE;

                    [self->platformSound runAction: [SKAction sequence:@[ [SKAction stop], [SKAction play] ] ] ];
                    [self setSpeed: 1]; // animation runs again
                }];

            }];
        }];
    }
}

// When our main character could get stucked left/right by a platform
- (void) horizontalEmergencyStop: (float) EdgarXPosition
{
    BOOL stopReallyNeeded = FALSE;
    int factor = 1;
    
    if([self getVelocityX] > 0) // the platform moves right
    {
        if(EdgarXPosition > self.position.x) // and Edgar stands at its right
        {
            stopReallyNeeded = TRUE;
            factor = -1;
        }
    }
    else // the platform moves left
    {
        if(EdgarXPosition < self.position.x) // and Edgar stands at its left
        {
            stopReallyNeeded = TRUE;
            factor = 1;
        }
    }
    
    if(stopReallyNeeded)
    {
        emergencyStopTriggered = TRUE; // to avoid simoultaneous calls
        
        [self removeAllActions];
        [self.physicsBody setVelocity:CGVectorMake(factor*motionSpeed, 0)]; // We invert the direction
        
        SKAction *mvDuration = [SKAction waitForDuration: .3];
        
        SKAction *moveDuration = [SKAction waitForDuration:movementDuration];
        SKAction *tempMove = [SKAction runBlock:^{
            [self horizontalMoveWithDuration: self->movementDuration forward: FALSE];
        }];
        
        [self.scene runAction: mvDuration completion:^
         {
             self->emergencyStopTriggered = FALSE;
             [self runAction: [SKAction sequence:@[tempMove, moveDuration]] completion:^{
                 [self runAction:[SKAction repeatActionForever: self->standardSequence]];
             }];
         }];
    }
}

- (SKAudioNode*) getPlatformSound{
    return self -> platformSound;
}

@end
