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

@implementation QuikClaim
-(void) addClaimToDatabase{
    Firebase *ref = [[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/claims"] childByAutoId];

    NSMutableDictionary *claimDict = [NSMutableDictionary new];
    [claimDict setObject:[ref key] forKey:@"claimID"];
    [claimDict setObject:self.carWithDamage forKey:@"carWithDamage"];
    [claimDict setObject:self.damageDescription forKey:@"damageDescription"];
    [claimDict setObject:self.ownerID forKey:@"owner"];

    NSArray *images = self.images;
    NSString *encodedCloseUp1 = [UIImagePNGRepresentation(images[0]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *encodedCloseUp2 = [UIImagePNGRepresentation(images[1]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *encodedTwoFt1 = [UIImagePNGRepresentation(images[2]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *encodedTwoFt2 = [UIImagePNGRepresentation(images[3]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    NSDictionary *imageDict = @{@"closeUp1":encodedCloseUp1,
                                @"closeUp2":encodedCloseUp2,
                                @"TwoFt1":encodedTwoFt1,
                                @"TwoFt2":encodedTwoFt2};
    [claimDict setObject:imageDict forKey:@"images"];
    [ref setValue: claimDict];
    
}

-(instancetype)initWithDictionary: (NSDictionary *)claimDictionary{
    self = [super init];
    if (self) {
        self.carWithDamage = claimDictionary[@"carWithDamage"];
        self.claimID = claimDictionary[@"claimID"];
        self.damageDescription = claimDictionary[@"damageDescription"];
//        self.claimLocation = claimDictionary[@""];
//        
//        for (NSString *picture in claimDictionary[@"images"]){
//            [self.images addObject:picture];
//        }
        
    }
    
    return self;
}
@end
