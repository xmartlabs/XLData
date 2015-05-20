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

#import "XLSearchBar.h"

@implementation XLSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        UITextField * textField = [XLSearchBar textField:self];
        textField.clearButtonMode = UITextFieldViewModeNever;
        self.placeholder = NSLocalizedString(@"Search", @"Search");
    }
    return self;
}

-(UITextField *)textField
{
    return [XLSearchBar textField:self];
}

+(UITextField *)textField:(UIView *)view
{
    if ([view isKindOfClass:[UITextField class]]){
        return (UITextField *)view;
    }
    for (UIView * subview in view.subviews) {
        UITextField * textField = [self textField:subview];
        if (textField) return textField;
    }
    return nil;
}

-(void)stopActivityIndicator
{
    UITextField *searchField = [XLSearchBar textField:self];
    if (searchField) {
        if ([searchField.rightView isKindOfClass:[UIActivityIndicatorView class]]){
            [((UIActivityIndicatorView *)searchField.rightView) stopAnimating];
        }
    }
    
}

-(void)startActivityIndicator
{
    UITextField *searchField = [XLSearchBar textField:self];
    if (searchField) {
        if (![searchField.rightView isKindOfClass:[UIActivityIndicatorView class]]){
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            searchField.rightView  = spinner;
            searchField.rightViewMode = UITextFieldViewModeAlways;
        }
        [((UIActivityIndicatorView *)searchField.rightView) startAnimating];
    }
}

@end
