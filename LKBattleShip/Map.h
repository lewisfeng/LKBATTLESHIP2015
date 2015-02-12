//
//  Map.h
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-02-08.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameBottomVIew.h"

@protocol MapDelegate <NSObject>

@optional

- (void)allShipsAllPlaced;

- (void)btnClickedWithBtnTagStr:(NSString *)tagStr;

@end

@interface Map : UIView

@property (nonatomic, strong) id<MapDelegate> delegate;

@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *opponentLbl;

@property (nonatomic, copy) NSArray *allBtns;
@property (nonatomic, copy) NSArray *shipsImgArray;

@property (nonatomic, retain) NSMutableArray *reminingBtns;
@property (nonatomic, retain) NSMutableArray *shipsPosition;

- (void)gameOverWith:(BOOL)isWinner;

- (void)removeAllCheckMarks;

- (void)addCrossMarkWithShipName:(NSString *)shipName;

- (void)gameStarted;

- (void)anotherPlayerIsReady;

- (id)initWithFrame:(CGRect)frame andPlayerName:(NSString *)name;

- (id)initWithFrame:(CGRect)frame andPlayerName:(NSString *)name andopponentName:(NSString *)opponentName ;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withShipsArray:(NSMutableArray *)shipsArray and:(UIImageView *)shipImgView;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withShipsArray:(NSMutableArray *)shipsArray and:(GameBottomVIew *)botView;


@property (nonatomic, retain) NSMutableArray *shipsArray;


@end
