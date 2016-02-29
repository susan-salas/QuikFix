//
//  QuikClaim.h
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
@class QuikCar;
@class QuikVendor;

@interface QuikClaim : NSObject

@property (nonatomic, strong) NSString *carWithDamage;
@property (nonatomic, strong) NSString *ownerID;
@property (nonatomic, strong) QuikVendor *assignedToVendor;
@property (nonatomic, strong) NSMutableArray *offers;
@property (nonatomic, strong) NSString *claimID;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSString *damageDescription;
@property (nonatomic, strong) NSString *panel;
@property (nonatomic, strong) NSString *damageType;
@property (nonatomic, strong) NSString *carDetail;
@property (nonatomic, strong) NSDictionary *claimLocation;
@property NSString *username;

-(instancetype)initWithDictionary: (NSDictionary *)claimDictionary;

@end
