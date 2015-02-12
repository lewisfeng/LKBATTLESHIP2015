//
//  GameBottomVIew.h
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-06.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BotViewDelegate <NSObject>

@optional

- (void)gameStarted;

@end

@interface GameBottomVIew : UIView

@property (nonatomic, strong) id<BotViewDelegate> delegate;

@property (nonatomic, strong) UILabel *msgLbl;

@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *playAgainBtn;

@property (nonatomic, strong) UIImageView *shipImgView;

@property (nonatomic, assign) CGPoint originalShipCenter;

- (void)addPlayAgainBtnWith:(UIView *)deviceV;

- (void)startCountDown;

- (void)readyToStartGameWith:(BOOL)isHost;

- (void)hideBotViewShipImgVWith:(BOOL)isHost;

- (id)initWithMapViewFrame:(CGRect)mFrame andDeviceView:(UIView *)deviceV;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView *)deviceW ;

@end
