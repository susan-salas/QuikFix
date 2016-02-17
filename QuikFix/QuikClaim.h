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

@property (nonatomic, strong) QuikCar *carWithDamage;
@property (nonatomic, strong) QuikVendor *vendorForClaim;
@property (nonatomic, strong) NSString *claimID;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSString *damageDescription;
@property (nonatomic, strong) NSDictionary *claimLocation;

@end