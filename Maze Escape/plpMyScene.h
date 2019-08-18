//
//  plpMyScene.h
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
#import <AVFoundation/AVFoundation.h>
#import "JSTileMap.h"
#import "plpHero.h"
#import "plpEnemy.h"
#import "plpTrain.h"
#import "plpPlatform.h"
#import "plpItem.h"
#import "plpSoundController.h"

#define LAST_LEVEL_INDEX 7
#define USE_ALTERNATE_CONTROLS 0
#define DEFAULT_EDGAR_VELOCITY 150

float contextVelocityX;

@interface plpMyScene : SKScene <SKPhysicsContactDelegate>
{
    // Objects
    plpHero *Edgar;
    SKPhysicsBody *EdgarCircleBody;
    JSTileMap *myLevel;
    SKNode *myWorld;
    SKCameraNode *myCamera;
    SKSpriteNode *myFinishRectangle;
    
    // Physics
    BOOL freeCamera;
    BOOL willLoseContextVelocity;
    float EdgarVelocity;
    CGPoint startPosition;
    
    // Character actions:
    SKAction *moveLeftAction;
    SKAction *moveRightAction;
    SKAction *moveUp;
    
    // Audio
    plpSoundController *soundController;
    SKAction *takeCellSound;
    SKAction *activateLiftSound;
    SKAction *takeLiftSound;
    SKAction *liftReadySound;
    SKAction *leftFootstepSound;
    SKAction *rightFootstepSound;
    BOOL pushingCrate;
    SKAction *crateSound;
    SKAction *trainImpactSound;
    NSTimer *setNearHeroTimer;
    NSMutableArray *platformNodes;
    
    // Input
    CGPoint touchStartPosition;
    BOOL waitForTap;
    BOOL isJumping;
    BOOL ignoreNextTap;
    BOOL moveLeftRequested;
    BOOL moveRightRequested;
    BOOL moveUpRequested;
    BOOL bigJumpRequested;
    BOOL stopRequested;
    BOOL gonnaCrash;
    BOOL movingLeft;
    BOOL movingRight;
    BOOL listensToContactEvents;
    BOOL levelTransitioning;
    
    // User interface
    UIView *containerView;
    UITextView *myTextView;
    BOOL runningOniPad;
    float screenCenterX;
    
    // Game data
    int deathCount;
    int globalCounter;
    int nextLevelIndex;
    double initialTime;
    double additionalSavedTime;
    double additionalLevelTime;
    BOOL liftReady;
    BOOL cheatsEnabled;
}

-(void)loadAssets:(JSTileMap*) tileMap;
-(void)addStoneBlocks:(JSTileMap*) tileMap;
-(void)resetGameData;
-(void)EdgarDiesOf:(int)deathType;
-(void)resetEdgar;
-(void)getsPaused;
-(void)resumeAfterPause;
-(void)resumeFromLevel:(NSInteger)theLevel;
-(void)updateVolumes;
-(int)getNextLevelIndex;
-(void)saveHighScoreForUser:(NSString*)userName;
-(void)saveInitialTime;
-(void)saveAdditionalTime:(float)additionalTime;
-(void)saveAdditionalTime;
-(void)computeSceneCenter;
-(void)setNearHero;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property(nonatomic, weak) SKNode *listener;

@end
