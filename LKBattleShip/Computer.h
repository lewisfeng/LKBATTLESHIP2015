//
//  Computer.h
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-10.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class Ship;

@protocol ComputerDelegate <NSObject>

@optional

- (void)playerWinWithLastShip:(Ship *)ship andBtnTag:(NSInteger)tag;
- (void)shipSunkWithShip:(Ship *)ship andBtnTag:(NSInteger)tag;
- (void)youHitItWithBtnTag:(NSInteger)tag;
- (void)youMissItWithBtnTag:(NSInteger)tag;

- (void)aIHitPlayerShipWithBtntag:(NSInteger)tag;
- (void)aIMissPlayerShipWithBtntag:(NSInteger)tag;

- (void)playerShipSunkWithShip:(Ship *)ship andBtnTag:(NSInteger)btnTag;
- (void)aIWinWithLastBtnTag:(NSInteger)btnTag andSunkShip:(Ship *)ship;

@end

@class Map;
@class Ship;

@interface Computer : NSObject

@property (nonatomic, strong) Ship  *ship;
@property (nonatomic, strong) Map   *map;

@property (nonatomic, strong) id<ComputerDelegate> delegate;

@property (nonatomic, assign) BOOL isWinner;

@property (nonatomic, retain) NSMutableArray *shipsArray;
@property (nonatomic, retain) NSMutableArray *playerShipsArray;
@property (nonatomic, retain) NSMutableArray *shipsPosition;

- (id)initWithMap:(Map *)map andPlayerShipsArray:(NSMutableArray *)playerShipsArray;

- (void)whatShouldIDo;

@end
