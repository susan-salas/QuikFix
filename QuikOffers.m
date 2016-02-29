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
        self.vendor = [offersDictionary objectForKey:@"vendor"];
        self.message = [offersDictionary objectForKey:@"meesage"];
        self.bid = [offersDictionary objectForKey:@"bid"];
    }
    return self;
}

@end
