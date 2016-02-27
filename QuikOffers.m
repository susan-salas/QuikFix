//
//  QuikOffers.m
//  QuikFix
//
//  Created by Susan Salas on 2/26/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikOffers.h"

@implementation QuikOffers

-(instancetype)initWithDictionary: (NSDictionary *) offersDictionary{
    if (self) {
        self.vendor = offersDictionary[@"vendor"];
        self.message = offersDictionary[@"message"];
        self.bid = offersDictionary[@"bid"];
    }
    return self;
}

@end
