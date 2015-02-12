//
//  Player.m
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-01-26.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "Player.h"
#import "Map.h"
#import "Ship.h"

@interface Player ()

@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, assign) NSInteger shipTag;

@property (nonatomic, assign) BOOL isHit;
@property (nonatomic, assign) BOOL isShipSunk;
@property (nonatomic, assign) BOOL areAllShipsSunk;

@end

@implementation Player

- (id)initWithPlayerName:(NSString *)name {
    
    if (self = [super  init]) {
        
        self.name = name;
        self.score = 0;
        self.isWinner = NO;
        self.shipsPosition = [NSMutableArray array];
       
        [self addShip];
    }
    return self;
}

- (id)initWithPlayerName:(NSString *)name andMap:(Map *)map {
    
    if (self = [super  init]) {
        
        self.name = name;
        self.score = 0;
        self.map = map;
        self.map.userInteractionEnabled = NO;
        self.isWinner = NO;
        self.shipsPosition = [NSMutableArray array];

        [self addShip];
    }
    return self;
}

- (void)checkResultWithBtnTag:(NSInteger)tag {
    
    self.selectedBtn = self.map.allBtns[tag];
    
    self.isHit = NO;
    self.isShipSunk = NO;
    self.areAllShipsSunk = NO;
    
    [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
    
    [self checkResult];
}


- (void)result {
    
    if (self.areAllShipsSunk) {
        
    } else if (self.isShipSunk) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerShipSunkWithShipTag:)]) {
            [self.delegate playerShipSunkWithShipTag:self.shipTag];
        }
        
    } else if (self.isHit) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(aIHitIt)]) {
            [self.delegate aIHitIt];
        }

        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal];
        
    } else { // Miss
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(aIMissIt)]) {
            [self.delegate aIMissIt];
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
                    self.shipTag = ship.tag;

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
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(result) userInfo:nil repeats:NO];
}


- (void)addShip {
   
    Ship *ship0 = [[Ship alloc] initWithType:AircraftCarrier];
    Ship *ship1 = [[Ship alloc] initWithType:Battleship];
    Ship *ship2 = [[Ship alloc] initWithType:Cruiser];
    Ship *ship3 = [[Ship alloc] initWithType:Destroyer];
    Ship *ship4 = [[Ship alloc] initWithType:Submarine];
    
    self.shipsArray = [NSMutableArray arrayWithObjects:ship0, ship1, ship2, ship3, ship4, nil];
    
//    self.shipsArray = [NSMutableArray arrayWithObjects:ship0, ship1, nil];
}

@end
