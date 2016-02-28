//
//  QuikCar.m
//  QuikFix
//
//  Created by Sean Barry on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikCar.h"

@implementation QuikCar
-(instancetype)initWithDictionary: (NSDictionary *)carDictionary{
    self = [super init];
    if(self){
        self.owner = [carDictionary valueForKey:@"owner"];
        self.year = [carDictionary valueForKey:@"year"];
        self.make = [carDictionary valueForKey:@"make"];
        self.model = [carDictionary valueForKey:@"model"];
        self.vin = [carDictionary valueForKey:@"vin"];
        self.body = [carDictionary valueForKey:@"body"];
        self.color = [carDictionary valueForKey:@"color"];
        self.image = [UIImage imageNamed:@"180 - iPhone 6 Plus"];
        self.detail = [NSString stringWithFormat:@"%@ %@ %@  %@",
                       self.year,
                       self.make,
                       self.model,
                       self.color];
    }
    return self;
}
@end
