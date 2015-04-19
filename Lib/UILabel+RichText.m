//
//  UILabel+RichText.m
//  RTALabel
//
//  Created by engin on 15-3-14.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import "UILabel+RichText.h"
#import "RTAAttributeHelper.h"

#pragma mark - UILabel
@implementation UILabel (RichText)
-(void)setRichAttributedText:(NSString *)richText
{
    RTAAttributeHelper *helper = [[RTAAttributeHelper alloc] initWithFontName:self.font.fontName fontSize:self.font.pointSize];
    
    NSAttributedString *attStr = [helper generateString:richText];
    self.attributedText = attStr;
}

@end
