//
//  QuikCar.h
//  QuikFix
//
//  Created by Sean Barry on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "QuikUser.h"

@interface QuikCar : NSObject

@property (nonatomic, strong) QuikUser *owner;
@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *vin;
@property (nonatomic, strong) NSString *license;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) UIColor *carColor;

@end
