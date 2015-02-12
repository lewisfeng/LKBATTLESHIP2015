//
//  SecondScreenView.h
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-02-09.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondScreenView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLbl;

@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIView *opponentMapView;

@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *shipImgViews;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *opponentShipImgViews;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *crossMarks;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *opponentsCrossMarks;

@property (nonatomic, copy) NSArray *allBtns;
@property (nonatomic, copy) NSArray *opponentAllBtns;

- (void)changeMapAlphaWith:(BOOL)isHostTurn;

- (void)gameOverWithWinnerName:(NSString *)name;

- (id)initWithName:(NSString *)name andOppentName:(NSString *)opponentName;

- (void)showCrossMarkWithShipName:(NSString *)shipName andIsOpponent:(BOOL)isOpponent;

@end
