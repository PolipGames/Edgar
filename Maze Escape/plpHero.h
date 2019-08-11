//
//  plpHero.h
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

#import <SpriteKit/SpriteKit.h>

@interface plpHero : SKSpriteNode
{
    SKTexture *facingEdgar;
    NSArray *_EdgarWalkingFrames;
    NSArray *_EdgarJumpingFrames;
    @public SKSpriteNode *rectangleNode;
    @public SKPhysicsBody *circleBody;
    @public SKSpriteNode *circleNode;
    BOOL boolHasControl;
    BOOL isInfected;
    BOOL hasUranium;
}

-(id)initAtPosition:(CGPoint)position;
-(void)walkingEdgar;
-(void)jumpingEdgar;
-(void)facingEdgar;
-(void)addLight;
-(void)removeLight;
-(void)addMasque;
-(void)removeMasque;
-(void)giveControl;
-(void)removeControl;
-(BOOL)hasControl;
-(void)takeDamage;
-(void)getsInfectedFor:(float)randomDuration;
-(BOOL)alreadyInfected;
-(void)takeItem;
-(void)resetItem;
-(void)resetInfected;
-(BOOL)hasItem;


@end
