//
//  MenuTableViewController.m
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

#import "XLNetworkStatusView.h"

@implementation XLNetworkStatusView

@synthesize messageLabel = _messageLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor orangeColor]];
        [self addSubview:self.messageLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        self.layer.zPosition = MAXFLOAT;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}


#pragma mark - Properties

-(UILabel *)messageLabel
{
    if (_messageLabel) return _messageLabel;
    _messageLabel = [[UILabel alloc] init];
    [_messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_messageLabel setTextColor:[UIColor whiteColor]];
    [_messageLabel setText:NSLocalizedString(@"No internet connection", nil)];
    UIFont * font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [_messageLabel setFont:font];
    return _messageLabel;
}



@end
