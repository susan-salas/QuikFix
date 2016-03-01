//
//  AddDamageVC.h
//  QuikFix
//
//  Created by Sean Barry on 2/18/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class QuikCar;
@class QuikClaim;

@interface AddDamageVC : UIViewController


@property (nonatomic,retain) CLLocationManager *locationManager;
@property NSString *carDetailText;
@property QuikCar *car;
@property QuikClaim *claim;
@end
