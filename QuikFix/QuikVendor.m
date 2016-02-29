//
//  QuikVendor.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendor.h"

@implementation QuikVendor

-(instancetype)initWithDictionary: (NSDictionary *) vendorDictionary{
    if (self) {
        self.idNumber = vendorDictionary[@"vendorid"];
        self.vendorName = vendorDictionary[@"name"];
        self.vendorLocation = vendorDictionary[@"location"];
        self.vendorWebsite = [NSURL URLWithString:vendorDictionary[@"@website"]];
        self.vendorPhoneNumber = vendorDictionary[@"phone"];
        self.vendorEmail = vendorDictionary[@"email"];
        if (vendorDictionary[@"rating"] != NULL) {
            self.vendorRating = vendorDictionary[@"rating"];
        }
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:vendorDictionary[@"image"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        self.image = [UIImage imageWithData:data];
        self.address = vendorDictionary[@"address"];
    }
    return self; 
}

@end
