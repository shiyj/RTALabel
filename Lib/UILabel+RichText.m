//
//  UILabel+RichText.m
//  RTALabel
//
//  Created by engin on 15-3-14.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import "UILabel+RichText.h"
#import "RTAExtractedComponent.h"
#import "RTAComponent.h"

#pragma mark - public function
static inline BOOL isTagSame(NSString *str1,NSString *str2)
{
    if ([str1 caseInsensitiveCompare:str2] == NSOrderedSame) {
        return YES;
    }
    return NO;
}


static inline int intergerFromHex(NSString *str)
{
    NSScanner *scanner = [NSScanner scannerWithString:str];
    unsigned int i;
    [scanner scanHexInt:&i];
    return i;
}
static inline UIColor* colorFromHexString(NSString *color)
{
    if ([[NSNull null] isEqual:color]) {
        return nil;
    }
    if ([color length]<6) {
        return nil;
    }
    
    NSString * subStr = [color substringToIndex:1];
    NSRange range;
    range.length = 2;
    range.location = 0;
    if ([subStr isEqualToString:@"#"]) {
        range.location = 1;
    }
    NSInteger red,green,blue;
    //red
    subStr = [color substringWithRange:range];
    red = intergerFromHex(subStr);
    
    range.location +=2;
    subStr = [color substringWithRange:range];
    green = intergerFromHex(subStr);
    
    range.location +=2;
    subStr = [color substringWithRange:range];
    blue = intergerFromHex(subStr);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

#pragma mark - UILabel
@implementation UILabel (RichText)
-(void)setRichAttributedText:(NSString *)richText
{
    RTAExtractedComponent *ext = [RTAExtractedComponent extractTextStyleFromText:richText];
    NSString *realStr = ext.plainText;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:realStr];
    for (RTAComponent *component in ext.textComponents) {
        [self generateAttrabute:attStr ofComponent:component];
    }
    
    self.attributedText = attStr;
}

- (CGFloat)generateComponentAttribute:(RTAComponent*)component to:(NSMutableAttributedString*)attr
{
    CGFloat fontSize = -1;
    NSArray *allKeys = [component.attributes allKeys];
    NSRange r;
    r.location = component.position;
    r.length = component.text.length;
    
    for (NSString *key in allKeys) {
        if (isTagSame(key, @"color")) {
            UIColor *color = colorFromHexString(component.attributes[key]);
            if (nil!=color) {
                [attr addAttribute:NSForegroundColorAttributeName value:color range:r];
            }
        } else if(isTagSame(key, @"size")){
            fontSize = [component.attributes[key] floatValue];
        } else if (isTagSame(key, @"lineColor")) {
            UIColor *color = colorFromHexString(component.attributes[key]);
            if (nil!=color) {
                NSString *lineColorName = nil;
                if (isTagSame(component.tagLabel, @"u") ) {
                    lineColorName = NSUnderlineColorAttributeName;
                } else if (isTagSame(component.tagLabel, @"del")) {
                    lineColorName = NSStrikethroughColorAttributeName;
                }
                if (nil!=lineColorName) {
                    [attr addAttribute:lineColorName value:color range:r];
                }
                
            }
        }
    }

    return fontSize;
}
- (void)generateAttrabute:(NSMutableAttributedString*)attr ofComponent:(RTAComponent*)component
{
    NSRange r;
    
    r.location = component.position;
    r.length = component.text.length;
    
    NSString *strKey = component.tagLabel;
    
    if (isTagSame(strKey, @"i")) {
        CGFloat fontSize = [self generateComponentAttribute:component to:attr];
        if (fontSize<1) {
            fontSize = self.font.pointSize;
        }
        UIFont *font = [UIFont italicSystemFontOfSize:fontSize];
        [attr addAttribute:NSFontAttributeName value:font range:r];
        
    } else if(isTagSame(strKey, @"b")) {
        CGFloat fontSize = [self generateComponentAttribute:component to:attr];
        if (fontSize<1) {
            fontSize = self.font.pointSize;
        }
        UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
        [attr addAttribute:NSFontAttributeName value:font range:r];
    } else if(isTagSame(strKey, @"u") || isTagSame(strKey, @"del")) {
        CGFloat fontSize = [self generateComponentAttribute:component to:attr];
        if (fontSize>1) {
            UIFont *font = [UIFont fontWithName:self.font.fontName size:fontSize];
            [attr addAttribute:NSFontAttributeName value:font range:r];
        }
        NSNumber *value = @(NSUnderlinePatternSolid | NSUnderlineStyleSingle);
        NSString *name = nil;
        if (isTagSame(strKey, @"u")) {
            name = NSUnderlineStyleAttributeName;
  
        } else {
            name = NSStrikethroughStyleAttributeName;
        }
        [attr addAttribute:name
                     value:value
                     range:r];
    } else if(isTagSame(strKey, @"attr")) {
        CGFloat fontSize = [self generateComponentAttribute:component to:attr];
        if (fontSize>1) {
            UIFont *font = [UIFont fontWithName:self.font.fontName size:fontSize];
            [attr addAttribute:NSFontAttributeName value:font range:r];
        }
    }
}

@end
