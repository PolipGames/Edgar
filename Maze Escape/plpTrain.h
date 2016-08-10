//
//  plpMyTrain.h
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

@interface plpTrain : SKSpriteNode
{
    SKSpriteNode *leftWheelNode;
    SKSpriteNode *rightWheelNode;
    BOOL isRunning;
    BOOL heroAbove;
}
- (id)initAtPosition:(CGPoint)position withMainTexture:(NSString*)textureString andWheelTexture:(NSString*)wheelTextureString;
- (SKSpriteNode*)getLeftWheel;
- (SKSpriteNode*)getRightWheel;
- (void)accelerateAtRate:(float)acceleration toMaxSpeed:(float)maxSpeed invertDirection:(BOOL)moveLeft;
- (void)decelerateAtRate:(float)deceleration;
- (void) setHeroAbove;
- (void) HeroWentAway;
- (float) getVelocityX;
@end
