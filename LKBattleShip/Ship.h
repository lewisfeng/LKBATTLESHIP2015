//
//  Ship.h
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-21.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <Foundation/Foundation.h>

// All Ship Types
typedef enum {
    
    AircraftCarrier, // Length 5
    Battleship,      // Length 4
    Cruiser,         // Length 4
    Destroyer,       // Length 3
    Submarine        // Length 2
    
} ShipType;

@interface Ship : NSObject

@property (nonatomic, assign) ShipType        type;
@property (nonatomic, assign) NSInteger       tag;
@property (nonatomic, assign) NSInteger       lenght;
@property (nonatomic, assign) NSInteger       hitSegments;
@property (nonatomic, strong) NSMutableArray *segments;

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *name;


@property (nonatomic, assign) BOOL isPlaced;

- (id)initWithType:(ShipType)shipType;

+ (id)shipWithType:(ShipType)shipType;

@end
