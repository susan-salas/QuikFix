//
//  QuikVendor.h
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuikVendor : NSObject

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) NSString *vendorName;
@property (nonatomic, strong) NSDictionary *vendorLocation;
@property (nonatomic, strong) NSURL *vendorWebsite;
@property (nonatomic, strong) NSString *vendorPhoneNumber;
@property (nonatomic, strong) NSString *vendorEmail;
@property (nonatomic, strong) NSNumber *vendorRating;

@end
