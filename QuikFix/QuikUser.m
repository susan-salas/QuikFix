//
//  QuikUser.m
//  QuikFix
//
//  Created by Sean Barry on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikUser.h"

@implementation QuikUser
-(instancetype)initWithDictionary: (NSDictionary *)userDictionary{
    NSLog(@"THe user dict %@", userDictionary);
    self = [super init];
    if(self){
        self.idNumber = userDictionary[@"uid"];
        self.userName = userDictionary[@"username"];
        self.email = userDictionary [@"email"];
    }
    return self;
}
@end
