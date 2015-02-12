//
//  Map.m
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-02-08.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "Map.h"
#import "Ship.h"

@interface Map ()

@property (nonatomic, strong) UIView *mapView;

@property (nonatomic, copy) NSString *myName;
@property (nonatomic, copy) NSString *opponentName;

@property (nonatomic, retain) NSMutableArray *checkOrCrossMarks;

@property (nonatomic, assign) BOOL allShipsPlaced;

@end

@implementation Map {
    
    CGFloat _deviceW;
}

- (void)gameOverWith:(BOOL)isWinner {
    
    [UIView animateWithDuration:1.0f animations:^{
        
        self.mapView.alpha = 0.3f;
        self.nameLbl.alpha = 0.0f;
        self.opponentLbl.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        UILabel *winnderLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.nameLbl.frame.origin.y, _deviceW, self.nameLbl.frame.size.height)];
        winnderLbl.textAlignment = NSTextAlignmentCenter;
        if (isWinner) {
            winnderLbl.text = @"YOU ARE THE WINNER";
        } else {
            winnderLbl.text = [NSString stringWithFormat:@"%@ IS THE WINNER", self.opponentName];
        }
        winnderLbl.alpha = 0.0f;
        winnderLbl.textColor = [UIColor whiteColor];
        winnderLbl.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:23.0f];
        [self addSubview:winnderLbl];
        
        winnderLbl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5f, 0.5f);
        
        [UIView animateWithDuration:1.0f animations:^{
            winnderLbl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15f, 1.15f);
            winnderLbl.alpha = 1.0f;
        }];
    }];
}


- (id)initWithFrame:(CGRect)frame andPlayerName:(NSString *)name {
    
    if (self = [super init]) {
    
        _deviceW = frame.size.width;
        
        self.alpha = 0.0f;
        
        self.shipsPosition = [NSMutableArray array];
        
        // MapView
        CGFloat mapViewWH = _deviceW * 0.95;
        CGFloat mapViewX  = (_deviceW - mapViewWH) / 2;
        
        // Name Label
        CGFloat labelH = 30;
        
        self.nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, _deviceW, labelH)];
        self.nameLbl.text = name;
        self.nameLbl.textColor = [UIColor whiteColor];
        self.nameLbl.textAlignment = NSTextAlignmentCenter;
        self.nameLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:23.0f];
        [self addSubview:self.nameLbl];
        
        self.mapView = [[UIView alloc] initWithFrame:CGRectMake(mapViewX, CGRectGetMaxY(self.nameLbl.frame), mapViewWH, mapViewWH)];
        
        [self drawCell];

        self.allBtns = [NSArray arrayWithArray:self.mapView.subviews];
        self.reminingBtns = [NSMutableArray arrayWithArray:self.allBtns];
        [self addSubview:self.mapView];
        
        // Ship micro view
        [self addShipsImgView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andPlayerName:(NSString *)name andopponentName:(NSString *)opponentName {
    
    if (self = [super init]) {
        
        _deviceW = frame.size.width;
        
        self.myName = name;
        self.opponentName = opponentName;
        
        self.shipsPosition = [NSMutableArray array];

        self.alpha = 0.0f;
        
        self.allShipsPlaced = NO;
        
        // MapView
        CGFloat mapViewWH = _deviceW * 0.95;
        CGFloat mapViewX  = (_deviceW - mapViewWH) / 2;
        
        // Name Label
        CGFloat labelW = (_deviceW - mapViewX * 2) / 2;
        CGFloat labelH = 30;
        
        self.nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(mapViewX, 20, labelW, labelH)];
        self.nameLbl.text = [NSString stringWithFormat:@"%@ - not ready", name];
        self.nameLbl.textColor = [UIColor whiteColor];
        self.nameLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
        [self addSubview:self.nameLbl];
        
        self.opponentLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nameLbl.frame), self.nameLbl.frame.origin.y, labelW, labelH)];
        self.opponentLbl.textAlignment = NSTextAlignmentRight;
        self.opponentLbl.textColor = self.nameLbl.textColor;
        self.opponentLbl.text = [NSString stringWithFormat:@"not ready - %@", opponentName];
        self.opponentLbl.font = self.nameLbl.font;
        [self addSubview:self.opponentLbl];
        
        self.mapView = [[UIView alloc] initWithFrame:CGRectMake(mapViewX, CGRectGetMaxY(self.nameLbl.frame), mapViewWH, mapViewWH)];
        [self drawCell];
        self.allBtns = [NSArray arrayWithArray:self.mapView.subviews];
        
        for (UIButton *btn in self.allBtns) {
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        self.reminingBtns = [NSMutableArray arrayWithArray:self.allBtns];
        [self addSubview:self.mapView];
        
        // Ship micro view
        [self addShipsImgView];
    }
    
    return self;
}

- (void)btnClicked:(UIButton *)sender {
    
//    NSLog(@"btnClicked");
    
    // 1. sender userInteractionEnabled = NO
    
    // 2. map userInteractionEnabled = NO
    
    // 3. Send tag to another player
    
    // 4. get resulte from another player
    
    // 5. if hit -> update score on both map and another player's both map
    
    // 5.1. -> map userInteractionEnabled = Yes
    
    // 5.2. -> self msg label = @"You hit it !"   another player msg label = @"Your name hit it !"
    
    // 6. if miss -> change another map alpha to 0, your map alpha = 1
    
    //    sender.enabled = NO;
    
    sender.userInteractionEnabled = NO;
    
    self.userInteractionEnabled = NO;
    
    [sender setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
     
    [self.delegate btnClickedWithBtnTagStr:[NSString stringWithFormat:@"%i",sender.tag]];
}


- (void)addCheckMarkWith:(UIImageView *)imageView {
    
    UIImageView *checkImgView = [[UIImageView alloc] initWithFrame:imageView.frame];
    checkImgView.image = [UIImage imageNamed:@"CheckMark.png"];
    checkImgView.contentMode = UIViewContentModeBottom;
    checkImgView.alpha = 0.0f;
    [self addSubview:checkImgView];
    [self.checkOrCrossMarks addObject:checkImgView];
}

- (void)addCrossMarkWithShipName:(NSString *)shipName {
    
    int tag;
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
    
    UIImageView *imgView = self.checkOrCrossMarks[tag];
    imgView.contentMode = UIViewContentModeCenter;
    imgView.image = [UIImage imageNamed:@"CrossM.png"];
    
    [UIView animateWithDuration:1.0f animations:^{
        imgView.alpha = 1.0f;
    }];
}

- (void)removeAllCheckMarks {
    
    self.userInteractionEnabled = NO;

    [UIView animateWithDuration:1.0f animations:^{
        
        for (UIImageView *checkMark in self.checkOrCrossMarks) {
            checkMark.alpha = 0.0f;
        }
    }];
}

- (void)gameStarted {
    
    self.nameLbl.text = [NSString stringWithFormat:@"%@ - 0", self.myName];
    self.opponentLbl.text = [NSString stringWithFormat:@"0 - %@", self.opponentName];
    
    for (UIButton *btn in self.allBtns) {
        btn.userInteractionEnabled = YES;
    }
}

- (void)anotherPlayerIsReady {
    
    self.opponentLbl.text = [NSString stringWithFormat:@"ready - %@", self.opponentName];
}

- (void)drawCell {
    
    // get btn WH
    CGFloat btnWH = (self.mapView.frame.size.width - 1 * (10 + 1)) / 10;
    
    // draw
    for (int i = 0; i < 10 * 10; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // btn X
        CGFloat btnX = 1 + btnWH * (i % 10) + 1 * (i % 10);
        // btn Y  注：i / 10 得到的是int值，整数后面的小数不计算 如 1.9 ＝ 1
        CGFloat btnY = 1 + (i / 10) * (btnWH + 1);
        
        btn.frame = CGRectMake(btnX, btnY, btnWH, btnWH);
        
        [btn setBackgroundImage:[UIImage imageNamed:@"BlueBtn.png"] forState:UIControlStateNormal];
        
        btn.tag = i; //btn tag
        
//        [btn setTitle:[NSString stringWithFormat:@"%lu",btn.tag] forState:UIControlStateNormal];
        
//        btn.userInteractionEnabled = NO;
        
        [self.mapView addSubview:btn];
    }
}

- (void)addShipsImgView {
    
    CGFloat imgViewY = CGRectGetMaxY(self.mapView.frame);
    CGFloat imgViewH = 30;
    
    UIImage *img0 = [UIImage imageNamed:@"ShipImg0.png"]; // Aircraft Carrier
    UIImage *img1 = [UIImage imageNamed:@"ShipImg1.png"]; // Battleship
    UIImage *img2 = [UIImage imageNamed:@"ShipImg2.png"]; // Cruiser
    UIImage *img3 = [UIImage imageNamed:@"ShipImg3.png"]; // Destroyer
    UIImage *img4 = [UIImage imageNamed:@"ShipImg4.png"]; // Submarine
    
    CGFloat space = (self.mapView.frame.size.width - img0.size.width - img1.size.width - img2.size.width - img3.size.width - img4.size.width) / 4;
    
    // Destroyer
    UIImageView *imgV3 = [[UIImageView alloc] initWithFrame:CGRectMake(self.mapView.frame.origin.x, imgViewY, img3.size.width, imgViewH)];
    [self setUpImageViewWith:imgV3 and:img3];
    
    // Battleship
    UIImageView *imgV1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV3.frame) + space, imgViewY, img1.size.width, imgViewH)];
    [self setUpImageViewWith:imgV1 and:img1];
    
    // Aircraft Carrier
    UIImageView *imgV0 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV1.frame) + space, imgViewY, img0.size.width, imgViewH)];
    [self setUpImageViewWith:imgV0 and:img0];
    
    // Cruiser
    UIImageView *imgV2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV0.frame) + space, imgViewY, img2.size.width, imgViewH)];
    [self setUpImageViewWith:imgV2 and:img2];
    
    // Submarine
    UIImageView *imgV4 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV2.frame) + space, imgViewY, img4.size.width, imgViewH)];
    [self setUpImageViewWith:imgV4 and:img4];
    
    self.frame = CGRectMake(0, 0, _deviceW, CGRectGetMaxY(imgV3.frame)); // Set frame here
    
    self.shipsImgArray = [NSArray arrayWithObjects:imgV0, imgV1, imgV2, imgV3, imgV4, nil];
    
    [self addCheckMark];
}

- (void)addCheckMark {
    
    self.checkOrCrossMarks = [NSMutableArray array];
    
    for (UIImageView *shipImgView in self.shipsImgArray) {
        [self addCheckMarkWith:shipImgView];
    }
}

- (void)setUpImageViewWith:(UIImageView *)imageView and:(UIImage *)image {
    
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = image;
    [self addSubview:imageView];
}


#pragma mark - touch begin
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withShipsArray:(NSMutableArray *)shipsArray and:(UIImageView *)shipImgView {
    
    if (!self.allShipsPlaced) {
        
        UITouch *touch = [touches anyObject];
        CGPoint touchCenter = [touch locationInView:self];
        
        for (Ship *ship in shipsArray) {
            if (!ship.isPlaced) {
                ship.segments = [NSMutableArray array];
            }
        }
        
        // alloc here
        NSMutableArray *allBtns = [NSMutableArray arrayWithArray:self.reminingBtns];
        
        for (UIButton *btn in self.allBtns) {
            
            // finger in map
            if (CGRectContainsPoint(btn.frame, touchCenter)) {
                
                NSInteger smallestTagH = (btn.tag / 10) * 10;            //  水平 tag所在行的最小tag
                NSInteger biggestTagH  = (btn.tag / 10) * 10 + (10 - 1); //  水平 tag所在行的最大tag
                
                for (int i = 0; i < 5; i ++) {
                    
                    Ship *ship = shipsArray[i];
                    
                    if (!ship.isPlaced) {
                        
                        for (int j = 0; j < ship.lenght; j ++) {
                            
                            if (shipImgView.image.imageOrientation == UIImageOrientationUp) { // isHor
                                
                                if (btn.tag - ship.lenght + 1 - j >= smallestTagH && btn.tag + j <= biggestTagH) {
                                    
                                    [self placeShipWith:ship and:allBtns and:j and:btn and:NO];
                                    
                                    break;
                                }
                                
                            } else { // isVertical
                                
                                if (btn.tag - 10 * (ship.lenght - 1 - j) >= 0 && btn.tag + 10 * j <= 100) {
                                    
                                    [self placeShipWith:ship and:allBtns and:j and:btn and:YES];
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
}


- (void)placeShipWith:(Ship *)ship and:(NSMutableArray *)allBtns and:(int)j and:(UIButton *)btn and:(BOOL)isVertical {
    
    for (int i = 0; i < ship.lenght; i ++) {
        
        NSInteger tag = btn.tag + j - i;
        
        if (isVertical) {
            
            tag = btn.tag + 10 * j - 10 * i;
        }
        
        UIButton *btnn = self.allBtns[tag];
        if (![self.shipsPosition containsObject:btnn]) {
            [ship.segments addObject:btnn];
        }
    }
    
    if (ship.segments.count == ship.lenght) {
        for (UIButton *btn in ship.segments) {
            [btn setBackgroundImage:[UIImage imageNamed:@"GreenBtn.png"] forState:UIControlStateNormal];
            btn.alpha = 1.0f;
        }
    }
    
    // delete btn
    for (int i = 0; i < ship.segments.count; i ++) {
        if ([allBtns  containsObject:ship.segments[i]]) {
            [allBtns removeObject:ship.segments[i]];
        }
    }
    
    // after delete btn
    for (UIButton *btn in allBtns) {
        [btn setBackgroundImage:[UIImage imageNamed:@"BlueBtn.png"] forState:UIControlStateNormal];
        //        btn.alpha = 0.5f;
    }
}


#pragma mark - touch over Order : Aircraft Carrier -> Battleship -> Cruiser -> Destroyer -> Submarine
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withShipsArray:(NSMutableArray *)shipsArray and:(GameBottomVIew *)botView {

    if (!self.allShipsPlaced) {
        
        for (int i = 0; i < shipsArray.count; i ++) {
            
            Ship *ship = shipsArray[i];
            
            if (!ship.isPlaced) {
                
                if (ship.segments.count == ship.lenght) {
                    
                    ship.isPlaced = YES;

                    [self.shipsPosition addObjectsFromArray:ship.segments];

                    [self.reminingBtns removeObjectsInArray:self.shipsPosition];
                    
                    int a;
                    if (i + 1 == shipsArray.count) {
                        a = i;
                        botView.msgLbl.text = @"All ships are placed";
                        if (self.myName) {
                            self.nameLbl.text = [NSString stringWithFormat:@"%@ - ready", self.myName];
                        }
                        
                        self.allShipsPlaced = YES;
                        [self.delegate allShipsAllPlaced];
                        
                    } else {
                        a = i + 1;
                        Ship *nextShip = shipsArray[a];
                        botView.shipImgView.image = [UIImage imageNamed:nextShip.image];
                        botView.msgLbl.text = [NSString stringWithFormat:@"%@ is placed", ship.name];
                    }
                    
                    [UIView animateWithDuration:1.0f animations:^{
                        [self.checkOrCrossMarks[i] setAlpha:1.0f];
                    }];
                
                } else {
                    
                    for (UIButton *btn in self.reminingBtns) {
                        [btn setBackgroundImage:[UIImage imageNamed:@"BlueBtn.png"] forState:UIControlStateNormal];
                    }
                }
            }
        }
        
        botView.shipImgView.center = botView.originalShipCenter;
    }
}


@end
