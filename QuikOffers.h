//
//  QuikOffers.h
//  QuikFix
//
//  Created by Susan Salas on 2/26/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QuikVendor;

@interface QuikOffers : NSObject
@property QuikVendor *vendor;
@property NSString *message;
@property NSString *bid;
@property BOOL hasBeenChecked;

-(instancetype)initWithDictionary: (NSDictionary *) offersDictionary;

@end
