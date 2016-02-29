//
//  QuikCarTableViewCell.m
//  QuikFix
//
//  Created by Sean Barry on 2/25/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikCarTableViewCell.h"
#import "QuikCar.h"

@interface QuikCarTableViewCell()
@property (nonatomic, strong) UIImageView *carImageView;
@property (nonatomic, strong) UILabel *carDescriptionLabel;
@end

@implementation QuikCarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.carImageView = [[UIImageView alloc] init];
        self.carDescriptionLabel = [[UILabel alloc] init];
        self.carDescriptionLabel.numberOfLines = 0;

        for (UIView *view in @[self.carImageView, self.carDescriptionLabel]) {
            [self.contentView addSubview:view];
        }
    }
    return self;
}

+ (CGFloat) heightForCarItem:(QuikCar *)car width:(CGFloat)width {
    // Make a cell
    QuikCarTableViewCell *layoutCell = [[QuikCarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];

    // Set it to the given width, and the maximum possible height
    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);

    // Give it the media item
    layoutCell.car = car;

    // Make it adjust the image view and labels
    [layoutCell layoutSubviews];

    // The height will be wherever the bottom of the comments label is
    return CGRectGetMaxY(layoutCell.carDescriptionLabel.frame);
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGFloat imageHeight = self.car.image.size.height / self.car.image.size.width * CGRectGetWidth(self.contentView.bounds);
    self.carImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);

    CGSize sizeOfCarDescriptionLabel = [self sizeOfString:self.carDescriptionLabel.attributedText];

    self.carDescriptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.carImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfCarDescriptionLabel.height + 20);

    [self.carDescriptionLabel setTextAlignment:NSTextAlignmentCenter];

    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}

- (CGSize) sizeOfString:(NSAttributedString *)string {
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds)+10, 0.0);
    CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    sizeRect = CGRectIntegral(sizeRect);
    return sizeRect.size;
}

- (void) setCar:(QuikCar *)car {
    _car = car;
    self.carImageView.image = car.image;
    self.carDescriptionLabel.text = _car.detail;

    [self layoutSubviews];
}


@end
