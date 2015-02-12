//
//  Player.h
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-01-26.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ship;
@class Map;

@protocol PlayerDelegate <NSObject>

@optional

- (void)playerShipSunkWithShipTag:(NSInteger)tag;
- (void)aIHitIt;
- (void)aIMissIt;

@end

@interface Player : NSObject

@property (nonatomic, strong) id<PlayerDelegate> delegate;

@property (nonatomic, strong) Ship *ship;
@property (nonatomic, strong) Map *map;
@property (nonatomic, retain) NSMutableArray *shipsArray;
@property (nonatomic, retain) NSMutableArray *shipsPosition;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) BOOL isWinner;

@property (nonatomic, assign) int score;

- (id)initWithPlayerName:(NSString *)name;

- (id)initWithPlayerName:(NSString *)name andMap:(Map *)map;

- (void)checkResultWithBtnTag:(NSInteger)tag;

@end
