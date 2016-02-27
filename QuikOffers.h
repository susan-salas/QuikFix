//
//  QuikOffers.h
//  QuikFix
//
//  Created by Susan Salas on 2/26/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuikOffers : NSObject
@property NSString *vendor;
@property NSString *message;
@property NSString *bid; 

-(instancetype)initWithDictionary: (NSDictionary *) offersDictionary;

@end
