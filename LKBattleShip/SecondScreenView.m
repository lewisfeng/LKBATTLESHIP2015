//
//  SecondScreenView.m
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-02-09.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "SecondScreenView.h"

@implementation SecondScreenView

- (id)initWithName:(NSString *)name andOppentName:(NSString *)opponentName {
    
    if (self = [super init]) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"SecondScreen" owner:self options:nil] objectAtIndex:0];
        
        self.alpha = 0.0f;
        
        self.nameLbl.text         = name;
        self.opponentNameLbl.text = opponentName;
        
        self.mapView.backgroundColor         = [UIColor clearColor];
        self.opponentMapView.backgroundColor = [UIColor clearColor];
        
        [self drawCell];
        
        self.allBtns         = [NSArray arrayWithArray:self.mapView.subviews];
        self.opponentAllBtns = [NSArray arrayWithArray:self.opponentMapView.subviews];
    }
    
    return self;
}

- (void)changeMapAlphaWith:(BOOL)isHostTurn {
    
    [UIView animateWithDuration:1.0f animations:^{
       
        if (isHostTurn) {
            for (UIButton *btn in self.allBtns) {
                btn.alpha = 0.3f;
            }
            for (UIButton *btn in self.opponentAllBtns) {
                btn.alpha = 1.0f;
            }
        } else {
            for (UIButton *btn in self.opponentAllBtns) {
                btn.alpha = 0.3f;
            }
            for (UIButton *btn in self.allBtns) {
                btn.alpha = 1.0f;
            }
        }
    }];
}

- (void)showCrossMarkWithShipName:(NSString *)shipName andIsOpponent:(BOOL)isOpponent {
    
    int tag = 0;
    if ([shipName isEqualToString:@"AircraftCarrier"]) {
        tag = 0;
    } else if ([shipName isEqualToString:@"Battleship"]) {
        tag = 1;
    } else if ([shipName isEqualToString:@"Cruiser"]) {
        tag = 2;
    } else if ([shipName isEqualToString:@"Destroyer"]) {
        tag = 3;
    }  else if ([shipName isEqualToString:@"Submarine"]) {
        tag = 4;
    }
    
    UIImageView *imgView;
    if (isOpponent) {
        imgView = self.opponentsCrossMarks[tag];
    } else {
        imgView = self.crossMarks[tag];
    }

    [UIView animateWithDuration:1.0f animations:^{
        imgView.alpha = 1.0f;
    }];
}

- (void)gameOverWithWinnerName:(NSString *)name {
    
    self.winnerLabel.text = [NSString stringWithFormat:@"%@ IS THE WINNER !", name];
    
    [UIView animateWithDuration:3.0f animations:^{
        
        self.mapView.alpha = 0.3f;
        self.opponentMapView.alpha = 0.3f;
        self.winnerLabel.alpha = 1.0f;
    }];
    
}

- (void)drawCell {
    
    CGFloat btnWH   = (self.mapView.frame.size.width - 1 * (10 + 1)) / 10;
    CGFloat btnnnWH = (self.opponentMapView.frame.size.width - 1 * (10 + 1)) / 10;

    for (int i = 0; i < 10 * 10; i ++) {
        
        UIButton *btn   = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *btnnn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.tag   = i;
        btnnn.tag = i;

        CGFloat btnX   = 1 + btnWH   * (i % 10) + 1 * (i % 10);
        CGFloat btnnnX = 1 + btnnnWH * (i % 10) + 1 * (i % 10);

        CGFloat btnY   = 1 + (i / 10) * (btnWH   + 1);
        CGFloat btnnnY = 1 + (i / 10) * (btnnnWH + 1);
        
        btn.frame   = CGRectMake(btnX,   btnY,   btnWH,   btnWH);
        btnnn.frame = CGRectMake(btnnnX, btnnnY, btnnnWH, btnnnWH);
        
        [btn   setBackgroundImage:[UIImage imageNamed:@"BlueBtn.png"] forState:UIControlStateNormal];
        [btnnn setBackgroundImage:[UIImage imageNamed:@"BlueBtn.png"] forState:UIControlStateNormal];

        [self.mapView         addSubview:btn];
        [self.opponentMapView addSubview:btnnn];
    }
    
    [UIView animateWithDuration:3.0f animations:^{
        self.alpha = 1.0f;
    }];
}

@end
