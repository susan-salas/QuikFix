//
//  QuikNotificationCell.m
//  QuikFix
//
//  Created by Sean Barry on 3/2/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikNotificationCell.h"

@implementation QuikNotificationCell

- (void)setFrame:(CGRect)frame {
    if (self.superview) {
        float cellWidth = 40.0;
        frame.origin.x = (self.superview.frame.origin.x + (cellWidth/2));
        frame.size.width = self.superview.frame.size.width - cellWidth;
    }

    [super setFrame:frame];
}

@end
