//
//  Ship.m
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-21.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "Ship.h"

@implementation Ship

+ (id)shipWithType:(ShipType)shipType
{
    return [[[self class] alloc] initWithType:shipType];
}

- (id)initWithType:(ShipType)shipType
{
    if (self = [super init]) {
        
        self.type = shipType;
        
        switch (shipType) {
                
            case AircraftCarrier:
                self.tag = 0;
                self.lenght = 5;
                self.image = @"AircraftCarrier.png";
                self.name = @"AircraftCarrier";
                self.hitSegments = 0;
                break;
                
            case Battleship:
                self.tag = 1;
                self.lenght = 4;
                self.image = @"Battleship.png";
                self.name = @"Battleship";
                self.hitSegments = 0;
                break;
                
            case Cruiser:
                self.tag = 2;
                self.lenght = 4;
                self.image = @"Cruiser.png";
                self.name = @"Cruiser";
                self.hitSegments = 0;
                break;
                
            case Destroyer:
                self.tag = 3;
                self.lenght = 3;
                self.image = @"Destroyer.png";
                self.name = @"Destroyer";
                self.hitSegments = 0;
                break;
                
            case Submarine:
                self.tag = 4;
                self.lenght = 2;
                self.image = @"Submarine.png";
                self.name = @"Submarine";
                self.hitSegments = 0;
                break;
                
            default:
                break;
        }
        
        self.segments    = [NSMutableArray array];

    }
    
    return self;
}

@end
