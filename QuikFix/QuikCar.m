//
//  QuikCar.m
//  QuikFix
//
//  Created by Sean Barry on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikCar.h"
#import "Firebase/Firebase.h"

@implementation QuikCar

-(void)addCarToDatabase{
    NSDictionary *carDict = @{@"vin":self.vin,
                                     @"year":self.year,
                                     @"make":self.make,
                                     @"model":self.model,
                                     @"body":self.body,
                                     @"color":@"red",
                                     @"license":self.license};

    NSDictionary *topLevel = @{self.vin:carDict};

    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/cars"];
    [ref setValue:topLevel];
}

@end
