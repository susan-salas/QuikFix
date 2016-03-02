//
//  QuikClaim.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikClaim.h"
#import "QuikCar.h"
#import "Firebase/Firebase.h"
#import "QuikOffers.h"

@implementation QuikClaim

-(instancetype)initWithDictionary: (NSDictionary *)claimDictionary{
    self = [super init];
    if (self) {
        NSDictionary *offersDict= claimDictionary[@"offers"];
        NSDictionary *imagesDict= claimDictionary[@"images"];
        NSMutableArray *offersArray = [NSMutableArray new];
        NSMutableArray *imagesArray = [NSMutableArray new];

        for (NSString *key in offersDict) {
            QuikOffers *currentOffer = [[QuikOffers alloc]initWithDictionary:[offersDict objectForKey:key]];
                [offersArray addObject:currentOffer];
        }

        for (NSString *imageKey in imagesDict) {
            NSString *imageData = [imagesDict valueForKey:imageKey];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                [imagesArray addObject:[UIImage imageWithData:data]];
        }

        self.carWithDamage = claimDictionary[@"carWithDamage"];
        self.claimID = claimDictionary[@"claimID"];
        self.damageDescription = claimDictionary[@"damageDescription"];
        self.ownerID = claimDictionary[@"owner"];
        self.images = imagesArray;
        self.offers = offersArray;
        self.panel = claimDictionary[@"panel"];
        self.carDetail = claimDictionary[@"carDetail"];
        self.damageType = claimDictionary[@"damageType"];
        self.username = claimDictionary[@"username"];
        self.claimLocation = claimDictionary[@"location"];
        self.offersDictionary = claimDictionary[@"offers"]; 
    }
    
    return self;
}
@end
