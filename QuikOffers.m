//
//  QuikOffers.m
//  QuikFix
//
//  Created by Susan Salas on 2/26/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikOffers.h"
#import "QuikVendor.h"
#import "Firebase/Firebase.h"

@implementation QuikOffers

-(instancetype)initWithDictionary: (NSDictionary *) offersDictionary{
    if (self) {
        
        Firebase *vendorRef = [[[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"] childByAppendingPath:@"vendors"] childByAppendingPath:[offersDictionary objectForKey:@"vendor"]];
        [vendorRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.exists) {
                self.vendor = [[QuikVendor alloc]initWithDictionary:snapshot.value];
                self.message = [offersDictionary objectForKey:@"message"];
                self.bid = [offersDictionary objectForKey:@"bid"];
                if ([[offersDictionary objectForKey:@"hasBeenChecked"] isEqualToString:@"YES"]) {
                    self.hasBeenChecked = YES;
                }else if ([[offersDictionary objectForKey:@"hasBeenChecked"] isEqualToString:@"NO"]){
                    self.hasBeenChecked = NO;
                }
            }
        }];
        
        
    }
    return self;
}

@end
