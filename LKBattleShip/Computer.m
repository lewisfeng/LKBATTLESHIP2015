//
//  Computer.m
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-10.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "Computer.h"
#import "Ship.h"
#import "Map.h"

@interface Computer ()

@property (nonatomic, assign) NSInteger hitSegments;
@property (nonatomic, assign) NSInteger isMissAfterMoreThanOneHitCount;

@property (nonatomic, assign) BOOL isHit;
@property (nonatomic, assign) BOOL isShipSunk;
@property (nonatomic, assign) BOOL areAllShipsSunk;

@property (nonatomic, assign) BOOL isAIHit;
@property (nonatomic, assign) BOOL isPlayerShipSunk;
@property (nonatomic, assign) BOOL areAllPlayerShipsSunk;

@property (nonatomic, assign) BOOL isMissAfterFirstHit;
@property (nonatomic, assign) BOOL isMissAfterMoreThanOneHit;
@property (nonatomic, assign) BOOL isTeeBtn;

@property (nonatomic, copy)   NSArray *beforeSortedArray;

@property (nonatomic, strong) Ship *aISunkShip;
@property (nonatomic, strong) Ship *playerSunkShip;

@property (nonatomic, retain) NSMutableArray *clickedShipBtnsMarray;
@property (nonatomic, retain) NSMutableArray *playerShipPositions;
@property (nonatomic, retain) NSMutableArray *clickedBtns;
@property (nonatomic, retain) NSMutableArray *afterSortedMArray;
@property (nonatomic, retain) NSMutableArray *randomMArray;
@property (nonatomic, retain) NSMutableArray *oppositeMArray;
@property (nonatomic, retain) NSMutableArray *shootBtnsMArray;

@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) UIButton *shootBtn;
@property (nonatomic, strong) UIButton *tempBtn;
@property (nonatomic, strong) UIButton *firstHitBtn;

@end

@implementation Computer

- (id)initWithMap:(Map *)map andPlayerShipsArray:(NSMutableArray *)playerShipsArray {
    
    if (self = [super init]) {
        
        self.map = map;
        
        self.map.alpha = 1.0f;
        
        self.isWinner = NO;
        
        self.clickedBtns           = [NSMutableArray array];
        self.beforeSortedArray     = [NSMutableArray array];
        self.randomMArray          = [NSMutableArray array];
        self.playerShipPositions   = [NSMutableArray array];
        self.clickedShipBtnsMarray = [NSMutableArray array];
        
        self.playerShipsArray = [NSMutableArray arrayWithArray:playerShipsArray];
        
        for (Ship *ship in self.playerShipsArray) {
            for (UIButton *btn in ship.segments) {
                [self.playerShipPositions addObject:btn];
            }
        }
        
        self.hitSegments = 0;
        self.isMissAfterMoreThanOneHitCount = 0;
        
        for (UIButton *btn in self.map.allBtns) {
            [btn addTarget:self action:@selector(computerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self addShip];
        
        [self placeShips];
    }
    
    return self;
}

#pragma AI
- (void)whatShouldIDo {

    if (self.hitSegments == 0) {
        
        self.isMissAfterMoreThanOneHitCount = 0;
        
        [self.clickedShipBtnsMarray removeAllObjects];
        
        [self chooseGrid];
        
    } else {
        
        if (self.isTeeBtn) {
            
            NSLog(@" isTeeBtn ");
            
            [self teeBtn];
            
        } else if (self.isMissAfterMoreThanOneHit) {
            
            NSLog(@" isMissAfterMoreThanOneHit ");
            
            [self missAfterMoreThanOneHit];
            
        } else if (self.isMissAfterFirstHit) {
            
            NSLog(@" isMissAfterFirstHit ");
            
            [self missAfterFirstHit];
            
        } else if (!self.isMissAfterFirstHit && self.hitSegments == 1) {
            
            NSLog(@" secondhit ");
            
            [self secondHit];
            
        } else if (!self.isMissAfterFirstHit) {
            
            NSLog(@"Second time hit !");
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(letsShoot) userInfo:nil repeats:NO];
    }
}

- (void)resultFromPlayer { // AI Side

    if (self.areAllPlayerShipsSunk) { // AI Win

        if (self.delegate && [self.delegate respondsToSelector:@selector(aIWinWithLastBtnTag:andSunkShip:)]) {
            [self.delegate aIWinWithLastBtnTag:self.shootBtn.tag andSunkShip:self.playerSunkShip];
        }
        
    } else if (self.isPlayerShipSunk) { // player ship sunk
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerShipSunkWithShip:andBtnTag:)]) {
            [self.delegate playerShipSunkWithShip:self.playerSunkShip andBtnTag:self.shootBtn.tag];
        }
        
    } else if (self.isAIHit) { // AI Hit

        if (self.delegate && [self.delegate respondsToSelector:@selector(aIHitPlayerShipWithBtntag:)]) {
            [self.delegate aIHitPlayerShipWithBtntag:self.shootBtn.tag];
        }

    } else { // AI Miss
        
//        NSLog(@"Miss Tag - %lu", self.shootBtn.tag);
        
        if (self.hitSegments == 1) {
            
            self.isMissAfterFirstHit = YES;
            
        } else {
            
           if (self.isMissAfterMoreThanOneHit) {
                
                self.isTeeBtn = YES;
                
            } else {
                
                self.isMissAfterMoreThanOneHit = YES; // oppositeMArry
                
                self.isMissAfterMoreThanOneHitCount += 1;
            }

            self.isMissAfterFirstHit = NO;
        }
        
        // Player turn
        [self.delegate aIMissPlayerShipWithBtntag:self.shootBtn.tag];
    }
}

- (void)letsShoot {
    
    if (self.shootBtnsMArray.count > 0) {
        
        self.shootBtn = self.shootBtnsMArray[0];
        
        BOOL isBtnClicked = NO;
        for (UIButton *btn in self.clickedBtns) {
            if (btn.tag == self.shootBtn.tag) {
                NSLog(@"        \n\nClickedBtns include shootBtn - %lu\n\n", btn.tag);
                isBtnClicked = YES;
                [self chooseGrid];
                break;
            }
        }
        if (!isBtnClicked) {
            
            [self.shootBtnsMArray  removeObject:self.shootBtn];
            [self.map.reminingBtns removeObject:self.shootBtn];
            [self.clickedBtns      addObject:   self.shootBtn];
            
            [self checkResultWithPlayer];
        }

    } else {
        
        [self chooseGrid];
    }
}

- (void)checkResultWithPlayer { // computer side

    NSLog(@"        Before  Hit Segments      =      %lu      Tag        =      %lu",self.hitSegments, self.shootBtn.tag);

    self.isAIHit = NO;
    self.isPlayerShipSunk = NO;
    self.areAllPlayerShipsSunk = NO;
    
    for (Ship *ship in self.playerShipsArray) {
        
        for (UIButton *btn in ship.segments) {
            
            if (btn.tag == self.shootBtn.tag) {
                
                self.isAIHit = YES;
                self.hitSegments += 1;
                
                [self.clickedShipBtnsMarray addObject:self.shootBtn];
                
                self.isMissAfterFirstHit = NO;
                self.isMissAfterMoreThanOneHit = NO;
                self.isTeeBtn = NO;

                [ship.segments removeObject:btn];
                
                if (ship.segments.count == 0) {

                    self.isPlayerShipSunk = YES;
                    self.playerSunkShip = ship;
                    self.hitSegments -= ship.lenght;
                    
                    if (self.hitSegments != 0) {
                        
                        self.isMissAfterMoreThanOneHit = YES;
                        
                        self.isMissAfterMoreThanOneHitCount += 1;
                        
                        if (self.isMissAfterMoreThanOneHitCount >= 2) {
                            self.isTeeBtn = YES;
                        }
                    }
                    
                    [self.playerShipsArray removeObject:ship];

                    if (self.playerShipsArray.count == 0) {

                        self.areAllPlayerShipsSunk = YES;
                    }
                }
                break;
            }
        }
        
        if (self.isPlayerShipSunk) {
            break;
        }
    }
    
    [self resultFromPlayer];
}


- (void)secondHit {
    
    NSInteger tag = self.shootBtn.tag;

    // 按照击中的按钮计算上下左右的没被点击过的按钮数量并分别放到上下左右4个数组里
    NSMutableArray *up    = [NSMutableArray array];
    NSMutableArray *down  = [NSMutableArray array];
    NSMutableArray *left  = [NSMutableArray array];
    NSMutableArray *right = [NSMutableArray array];
    
    for (int i = 1; i < 10; i ++) {
        
        // Up
        if (tag - 10 * i < 0 || [self.clickedBtns containsObject:self.map.allBtns[tag - 10 * i]]) {
            break;
        } else {
            [up addObject:self.map.allBtns[tag - 10 * i]];
        }
    }
    
    for (int i = 1; i < 10; i ++) {
        
        // Down
        if (tag + 10 * i >= 10 * 10 || [self.clickedBtns containsObject:self.map.allBtns[tag + 10 * i]]) {
            break;
        } else {
            [down addObject:self.map.allBtns[tag + 10 * i]];
        }
    }
    
    for (int i = 1; i < 10; i ++) {
        
        // Left
        if (tag / 10 != (tag - i) / 10 || tag - i < 0 || (tag - i) / 10 != tag / 10 || [self.clickedBtns containsObject:self.map.allBtns[tag - i]]) {
            break;
        } else {
            [left addObject:self.map.allBtns[tag - i]];
        }
    }
    
    for (int i = 1; i < 10; i ++) {
        
        // Right
        if (tag / 10 != (tag + i) / 10 || tag + i > 10 * 10 || (tag + i) / 10 != tag / 10 || [self.clickedBtns containsObject:self.map.allBtns[tag + i]]) {
            break;
        } else {
            [right addObject:self.map.allBtns[tag + i]];
        }
    }
    
    // 按照上下左右Array的count数量重新排序
    self.beforeSortedArray = [NSArray arrayWithObjects:up, down, left, right, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"@count" ascending:NO];
    NSArray *afterSortedA = [self.beforeSortedArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
    self.afterSortedMArray = [NSMutableArray arrayWithArray:afterSortedA];
    
    // 计算出count最多的 random数组
    if ([self.afterSortedMArray[0] count] == [self.afterSortedMArray[1] count] && [self.afterSortedMArray[0] count] == [self.afterSortedMArray[2] count] && [self.afterSortedMArray[0] count] == [self.afterSortedMArray[3] count]) {
        
        self.randomMArray = self.afterSortedMArray[rand() % 4];
        
    } else if ([self.afterSortedMArray[0] count] == [self.afterSortedMArray[1] count] && [self.afterSortedMArray[0] count] == [self.afterSortedMArray[2] count]) {
        
        self.randomMArray = self.afterSortedMArray[rand() % 3];
        
    } else if ([self.afterSortedMArray[0] count] == [self.afterSortedMArray[1] count]) {
        
        self.randomMArray = self.afterSortedMArray[rand() % 2];
        
    } else if ([self.afterSortedMArray[0] count] > [self.afterSortedMArray[1] count]) {
        
        self.randomMArray = self.afterSortedMArray[0];
    }
    
    // Get randomArray's oppositeArray 得到random数组的相反数组
    // Up -> Down
    if (self.randomMArray == self.beforeSortedArray[0]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[1]];
        
        // Down -> Up
    } else if (self.randomMArray == self.beforeSortedArray[1]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[0]];
        
        // Left -> Right
    } else if (self.randomMArray == self.beforeSortedArray[2]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[3]];
        
        // Right -> Left
    } else if (self.randomMArray == self.beforeSortedArray[3]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[2]];
    }
    
    self.shootBtnsMArray = [NSMutableArray arrayWithArray:self.randomMArray];
}

#pragma mark Miss after first Hit
- (void)missAfterFirstHit {
    
    if (self.afterSortedMArray.count > 0) {
        
        [self.afterSortedMArray removeObjectAtIndex:0];
        
        if (self.afterSortedMArray.count > 0) {
            
            self.randomMArray = self.afterSortedMArray[0];
            
            [self getOppositeMArray];
            
            self.shootBtnsMArray = [NSMutableArray arrayWithArray:self.randomMArray];
        }
    }
}

- (void)getOppositeMArray {
    
    // Get randomArray's oppositeArray 得到random数组的相反数组
    // Up -> Down
    if (self.randomMArray == self.beforeSortedArray[0]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[1]];
        
        // Down -> Up
    } else if (self.randomMArray == self.beforeSortedArray[1]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[0]];
        
        // Left -> Right
    } else if (self.randomMArray == self.beforeSortedArray[2]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[3]];
        
        // Right -> Left
    } else if (self.randomMArray == self.beforeSortedArray[3]) {
        
        self.oppositeMArray = [NSMutableArray arrayWithArray:self.beforeSortedArray[2]];
    }
}


#pragma mark Miss after second Hit - choose opposite direction
- (void)missAfterMoreThanOneHit {
    
    self.shootBtnsMArray = [NSMutableArray arrayWithArray:self.oppositeMArray];
}


- (void)teeBtn {

    self.firstHitBtn = self.clickedShipBtnsMarray[0];
    [self.clickedShipBtnsMarray removeObject:self.firstHitBtn];

    // 按照击中的按钮计算上下左右的没被点击过的按钮数量并分别放到上下左右4个数组里
    NSMutableArray *up    = [NSMutableArray array];
    NSMutableArray *down  = [NSMutableArray array];
    NSMutableArray *left  = [NSMutableArray array];
    NSMutableArray *right = [NSMutableArray array];
    
    for (int i = 1; i < 10; i ++) {
        
        // Up
        if (self.firstHitBtn.tag - 10 * i < 0 || [self.clickedBtns containsObject:self.map.allBtns[self.firstHitBtn.tag - 10 * i]]) {
            break;
        } else {
            [up addObject:self.map.allBtns[self.firstHitBtn.tag - 10 * i]];
        }
    }
    
    for (int i = 1; i < 10; i ++) {
        
        // Down
        if (self.firstHitBtn.tag + 10 * i >= 10 * 10 || [self.clickedBtns containsObject:self.map.allBtns[self.firstHitBtn.tag + 10 * i]]) {
            break;
        } else {
            [down addObject:self.map.allBtns[self.firstHitBtn.tag + 10 * i]];
        }
    }
    
    for (int i = 1; i < 10; i ++) {
        
        // Left
        if (self.firstHitBtn.tag / 10 != (self.firstHitBtn.tag - i) / 10 || self.firstHitBtn.tag - i < 0 || (self.firstHitBtn.tag - i) / 10 != self.firstHitBtn.tag / 10 || [self.clickedBtns containsObject:self.map.allBtns[self.firstHitBtn.tag - i]]) {
            break;
        } else {
            [left addObject:self.map.allBtns[self.firstHitBtn.tag - i]];
        }
    }
    
    for (int i = 1; i < 10; i ++) {
        
        // Right
        if (self.firstHitBtn.tag / 10 != (self.firstHitBtn.tag + i) / 10 || self.firstHitBtn.tag + i > 10 * 10 || (self.firstHitBtn.tag + i) / 10 != self.firstHitBtn.tag / 10 || [self.clickedBtns containsObject:self.map.allBtns[self.firstHitBtn.tag + i]]) {
            break;
        } else {
            [right addObject:self.map.allBtns[self.firstHitBtn.tag + i]];
        }
    }
    
    // 按照上下左右Array的count数量重新排序
    self.beforeSortedArray = [NSArray arrayWithObjects:up, down, left, right, nil];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"@count" ascending:NO];
    NSArray *afterSortedA = [self.beforeSortedArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
    self.afterSortedMArray = [NSMutableArray arrayWithArray:afterSortedA];
    
    // 计算出count最多的 random数组
    if ([self.afterSortedMArray[0] count] == [self.afterSortedMArray[1] count] && [self.afterSortedMArray[0] count] == [self.afterSortedMArray[2] count] && [self.afterSortedMArray[0] count] == [self.afterSortedMArray[3] count]) {
        
        self.randomMArray = self.afterSortedMArray[rand() % 4];
        
    } else if ([self.afterSortedMArray[0] count] == [self.afterSortedMArray[1] count] && [self.afterSortedMArray[0] count] == [self.afterSortedMArray[2] count]) {
        
        self.randomMArray = self.afterSortedMArray[rand() % 3];
        
    } else if ([self.afterSortedMArray[0] count] == [self.afterSortedMArray[1] count]) {
        
        self.randomMArray = self.afterSortedMArray[rand() % 2];
        
    } else if ([self.afterSortedMArray[0] count] > [self.afterSortedMArray[1] count]) {
        
        self.randomMArray = self.afterSortedMArray[0];
    }
    
    [self getOppositeMArray];
    
    self.shootBtnsMArray = [NSMutableArray arrayWithArray:self.randomMArray];
}


- (void)addShip {
    
    Ship *ship0 = [[Ship alloc] initWithType:AircraftCarrier];
    Ship *ship1 = [[Ship alloc] initWithType:Battleship];
    Ship *ship2 = [[Ship alloc] initWithType:Cruiser];
    Ship *ship3 = [[Ship alloc] initWithType:Destroyer];
    Ship *ship4 = [[Ship alloc] initWithType:Submarine];
    
    self.shipsArray = [NSMutableArray arrayWithObjects:ship0, ship1, ship2, ship3, ship4, nil];
    
//    self.shipsArray = [NSMutableArray arrayWithObjects:ship0, ship1, nil];  // Test Use !
}


- (void)placeShips {
    
    self.shipsPosition = [NSMutableArray array];
    
    void(^possibility)(NSInteger, NSInteger, int, NSArray *, int, NSMutableArray *) = ^(NSInteger tag, NSInteger a, int c, NSArray *array, int shipLength, NSMutableArray *allPossibility) {
        
        NSMutableArray *possibilityV = [NSMutableArray array];
        
        if (tag - 10 * a >= 0 && tag + 10 * c < 100)  {
            
            for (int i = 0; i < shipLength; i ++) {
                
                UIButton *btn = self.map.allBtns[(tag + 10 * c) - 10 * i];
                
                if (![array containsObject:btn]) {
                    [possibilityV addObject:btn];
                }
            }
            
            if (possibilityV.count == shipLength) {
                [allPossibility addObject:possibilityV];
            }
        }
        
        NSMutableArray *possibilityH = [NSMutableArray array];
        
        if (tag - a >= (tag / 10) * 10 && tag + c < (tag / 10) * 10 + 10) {
            
            for (int i = 0; i < shipLength; i ++) {
                
                UIButton *btn = self.map.allBtns[tag + c - i];
                
                if (![array containsObject:btn]) {
                    [possibilityH addObject:btn];
                }
            }
            
            if (possibilityH.count == shipLength) {
                [allPossibility addObject:possibilityH];
            }
        }
        
    };
    
    for (int i = 0; i < self.shipsArray.count; i ++) {
        
        int ran = arc4random() % self.map.reminingBtns.count;
        UIButton *btn = self.map.reminingBtns[ran];
        NSInteger tag = btn.tag;
        
        NSMutableArray *allPossibility = [NSMutableArray array];
        
        Ship *ship = self.shipsArray[i];
        
        for (int i = 0; i < ship.lenght; i ++) {
            
            possibility(tag, ship.lenght - i - 1, i, self.shipsPosition, ship.lenght, allPossibility);
        }
        
        ship.segments = [NSMutableArray arrayWithArray:allPossibility[arc4random() % allPossibility.count]];
        
        [self.shipsPosition addObjectsFromArray:ship.segments];
        
        for (UIButton *btn in ship.segments) {
            
//                        [btn setBackgroundImage:[UIImage imageNamed:@"GreenBtn.png"] forState:UIControlStateNormal];
            
            [self.map.reminingBtns removeObject:btn];
        }
    }
    
    self.map.reminingBtns = [NSMutableArray arrayWithArray:self.map.allBtns];
}


- (void)chooseGrid {

    self.hitSegments = 0;
    self.isMissAfterFirstHit = NO;
    self.isMissAfterMoreThanOneHit = NO;
    self.isTeeBtn = NO;
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSMutableArray *allBtnsCopy = [NSMutableArray arrayWithArray:self.map.allBtns];
    
    [allBtnsCopy removeObjectsInArray:self.map.reminingBtns];

    // Step 1.btn上下 和 左右＋－2都必须符合要求
    for (UIButton *btn in self.map.reminingBtns) {
        
        if ((((btn.tag - 2) / 10 == (btn.tag + 2) / 10) && btn.tag - 2 >= 0) &&
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 2]] &&
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1]] &&
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1]] &&
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 2]] &&
            ((btn.tag - 2 * 10) >= 0 && (btn.tag + 2 * 10) < 10 * 10) &&
            
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 2 * 10]] &&
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1 * 10]] &&
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1 * 10]] &&
            ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 2 * 10]]) {
            
            [tempArray addObject:btn];
        }
    }
    
    if (tempArray.count == 0) {
        
        // Step 2.btn上下 或 左右 ＋－2符合要求
        for (UIButton *btn in self.map.reminingBtns) {
            
            if (
                // 上 － 下
                (
                 (((btn.tag - 2) / 10 == (btn.tag + 2) / 10) && btn.tag - 2 >= 0) &&
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 2]] &&
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1]] &&
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1]] &&
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 2]]
                 
                 ) ||
                
                // 左 － 右
                (
                 ((btn.tag - 2 * 10) >= 0 && (btn.tag + 2 * 10) < 10 * 10) &&
                 
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 2 * 10]] &&
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1 * 10]] &&
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1 * 10]] &&
                 ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 2 * 10]])
                
                ) {
                
                [tempArray addObject:btn];
            }
        }
        
        if (tempArray.count == 0) {
            
            // Step 3.btn上下 和 左右 ＋－1 符合要求
            for (UIButton *btn in self.map.reminingBtns) {
                
                if ((((btn.tag - 1) / 10 == (btn.tag + 1) / 10) && btn.tag - 1 >= 0) &&
                    
                    ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1]] &&
                    ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1]] &&
                    ((btn.tag - 1 * 10) >= 0 && (btn.tag + 1 * 10) < 10 * 10) &&
                    
                    ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1 * 10]] &&
                    ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1 * 10]]) {
                    
                    [tempArray addObject:btn];
                }
            }
            
            if (tempArray.count == 0) {
                
                // Step 4.btn上下 或 左右 ＋－1 符合要求
                for (UIButton *btn in self.map.reminingBtns) {
                    
                    if (
                        
                        (
                         (((btn.tag - 1) / 10 == (btn.tag + 1) / 10) && btn.tag - 1 >= 0) &&
                         
                         ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1]] &&
                         ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1]]
                         
                         ) ||
                        
                        (
                         ((btn.tag - 1 * 10) >= 0 && (btn.tag + 1 * 10) < 10 * 10) &&
                         
                         ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1 * 10]] &&
                         ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1 * 10]])
                        
                        ) {
                        
                        [tempArray addObject:btn];
                    }
                }
                
                if (tempArray.count == 0) {
                    
                    // Step 5.btn 左－1上－1   或   左－1下＋1   或   右＋1上－1   或右＋1下＋1   其中一个符合要求
                    for (UIButton *btn in self.map.reminingBtns) {
                        
                        if (
                            ( (btn.tag - 1) / 10 == btn.tag / 10 && btn.tag - 1 >= 0 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1]] && (btn.tag - 1 * 10) >= 0 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1 *10]] )
                            
                            ||
                            
                            ( (btn.tag - 1) / 10 == btn.tag / 10 && btn.tag - 1 >= 0 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1]] && (btn.tag + 1 * 10) < 10 * 10 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1 *10]] )
                            
                            ||
                            
                            ( (btn.tag + 1) / 10 == btn.tag / 10 && btn.tag + 1 < 10 * 10 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1]] && (btn.tag + 1 * 10) < 10 * 10 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1 *10]] )
                            
                            ||
                            
                            ( (btn.tag + 1) / 10 == btn.tag / 10 && btn.tag + 1 < 10 * 10 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1]] && (btn.tag - 1 * 10) >= 0 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1 *10]] )
                            ) {
                            
                            [tempArray addObject:btn];
                        }
                    }
                    
                    if (tempArray.count == 0) {
                        
                        // Step 6.btn的 上 或 下 或 左 或 右 有一个符合要求的
                        for (UIButton *btn in self.map.reminingBtns) {
                            
                            if (
                                ( (btn.tag - 1) / 10 == btn.tag / 10 && btn.tag - 1 >= 0 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1]] )
                                
                                ||
                                
                                ( (btn.tag + 1) / 10 == btn.tag / 10 && btn.tag + 1 < 10 * 10 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1]] )
                                
                                ||
                                
                                ( btn.tag - 1 * 10 >= 0 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag - 1 * 10]] )
                                
                                ||
                                
                                ( btn.tag + 1 * 10 < 10 * 10 && ![self.clickedBtns containsObject:self.map.allBtns[btn.tag + 1 * 10]] )
                                
                                ) {
                                
                                [tempArray addObject:btn];
                            }
                        }
                        
                    } if (tempArray.count == 0) {
                        
                        tempArray = self.map.reminingBtns;
                    }
                }
            }
        }
    }
    
    if (tempArray.count != 0) {
        
        self.shootBtn = tempArray[arc4random() % tempArray.count];
        [self.map.reminingBtns removeObject:self.shootBtn];
        [self.clickedBtns addObject:self.shootBtn];
        
        [self checkResultWithPlayer];
    }
}


- (void)computerBtnClicked:(UIButton *)sender {
    
    [self playSoundWithSoundName:@"Fire" andType:@"mp3"];
    
    self.selectedBtn = sender;
    
    self.isHit = NO;
    self.isShipSunk = NO;
    self.areAllShipsSunk = NO;
    
    sender.userInteractionEnabled = NO;
    self.map.userInteractionEnabled = NO;
    [sender setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
    
    [self checkResult];
}

- (void)result { // To Player
    
    if (self.areAllShipsSunk) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerWinWithLastShip:andBtnTag:)]) {
            [self.delegate playerWinWithLastShip:self.aISunkShip andBtnTag:self.selectedBtn.tag];
        }
        
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal];
        
    } else if (self.isShipSunk) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(shipSunkWithShip:andBtnTag:)]) {
            [self.delegate shipSunkWithShip:self.aISunkShip andBtnTag:self.selectedBtn.tag];
        }
        
        self.map.userInteractionEnabled = YES;
        
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal];
        
    } else if (self.isHit) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(youHitItWithBtnTag:)]) {
            [self.delegate youHitItWithBtnTag:self.selectedBtn.tag];
        }
        
        self.map.userInteractionEnabled = YES;
        
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal];
        
    } else { // Miss
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(youMissItWithBtnTag:)]) {
            [self.delegate youMissItWithBtnTag:self.selectedBtn.tag];
        }
        
        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"LightBlueBtn.png"] forState:UIControlStateNormal];
    }
}

- (void)checkResult { // computer side
    
    for (Ship *ship in self.shipsArray) {
        
        for (UIButton *btn in ship.segments) {
            
            if (btn.tag == self.selectedBtn.tag) {
                
                self.isHit = YES;
                
                [ship.segments removeObject:btn];
                
                if (ship.segments.count == 0) {
                    
                    self.isShipSunk = YES;
                    self.aISunkShip = ship;
                    
                    [self.map addCrossMarkWithShipName:ship.name];
                    
                    [self.shipsArray removeObject:ship];
                    
                    if (self.shipsArray.count == 0) {
                        
                        self.areAllShipsSunk = YES;
                    }
                }
                break;
            }
        }
        
        if (self.isShipSunk) {
            break;
        }
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(result) userInfo:nil repeats:NO];
}


- (void)playSoundWithSoundName:(NSString *)soundName andType:(NSString *)type {
    
    SystemSoundID completeSound;
    NSURL *audioPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:type]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
    AudioServicesPlaySystemSound (completeSound);
}


@end
