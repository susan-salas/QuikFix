//
//  QuikCarTableViewCell.h
//  QuikFix
//
//  Created by Sean Barry on 2/25/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QuikCar;

@interface QuikCarTableViewCell : UITableViewCell
@property (nonatomic, strong) QuikCar *car;
@property (nonatomic) float tableViewWidth;

+(CGFloat) heightForCarItem:(QuikCar *)car width:(CGFloat)width;

@end
