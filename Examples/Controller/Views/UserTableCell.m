//
//  UserTableCell.m
//  XLData ( https://github.com/xmartlabs/XLData )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UserTableCell.h"

@implementation UserTableCell

@synthesize userImage = _userImage;
@synthesize userName  = _userName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self.contentView addSubview:self.userImage];
        [self.contentView addSubview:self.userName];
        
        [self.contentView addConstraints:[self layoutConstraints]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Views

-(UIImageView *)userImage
{
    if (_userImage) return _userImage;
    _userImage = [UIImageView new];
    _userImage.translatesAutoresizingMaskIntoConstraints = NO;
    _userImage.layer.masksToBounds = YES;
    _userImage.layer.cornerRadius = 10.0f;
    return _userImage;
}

-(UILabel *)userName
{
    if (_userName) return _userName;
    _userName = [UILabel new];
    _userName.translatesAutoresizingMaskIntoConstraints = NO;
    _userName.font = [UIFont systemFontOfSize:15.0];
    
    return _userName;
}

#pragma mark - Layout Constraints

-(NSArray *)layoutConstraints{
    
    NSMutableArray * result = [NSMutableArray array];
    
    NSDictionary * views = @{ @"image": self.userImage,
                              @"name": self.userName};
                              
    
    NSDictionary *metrics = @{@"imgSize":@50.0,
                              @"margin" :@12.0};
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[image(imgSize)]-[name]"
                                                                        options:NSLayoutFormatAlignAllTop
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[image(imgSize)]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:views]];
    return result;
}


@end
