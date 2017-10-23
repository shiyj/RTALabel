//
//  RTAAttributeHelper.m
//  RTALabel
//
//  Created by engin on 15-4-19.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import "RTAAttributeHelper.h"
#import <UIKit/UIKit.h>
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
#pragma mark - RTAAttributeHelper
@interface RTAAttributeHelper()
@property (nonatomic,strong) NSString *fontName;
@property (nonatomic,assign) float fontSize;
@end

@implementation RTAAttributeHelper

-(instancetype)initWithFontName:(NSString*)name fontSize:(float)fontSize
{
    self = [super init];
    if (self) {
        self.fontName = name;
        self.fontSize = fontSize;
    }
    return self;
}

+(NSAttributedString*)generateString:(NSString*)richText forView:(UIView*)view
{
    id labelDuck = (id)view;
    BOOL isLabelDuck = YES;
    UIFont *font = nil;
    if ([labelDuck respondsToSelector:@selector(font)]) {
        font = (UIFont*)[labelDuck performSelector:@selector(font)];
    } else {
        isLabelDuck = NO;
    }
    if (isLabelDuck && [font isKindOfClass:[UIFont class]]) {
        RTAAttributeHelper *helper = [[RTAAttributeHelper alloc] initWithFontName:font.fontName fontSize:font.pointSize];
        return [helper generateString:richText];
    }
    return nil;
}
#pragma mark - getter/setter
-(float)fontSize
{
    if (_fontSize < 1) {
        _fontSize = 17;
    }
    return _fontSize;
}
-(NSString*)fontName
{
    if (nil == _fontName) {
        _fontName = [[UIFont systemFontOfSize:17] fontName];
    }
    return _fontName;
}
#pragma mark - generate attribute string
-(NSAttributedString*)generateString:(NSString*)richText
{
    RTAExtractedComponent *ext = [RTAExtractedComponent extractTextStyleFromText:richText];
    NSString *realStr = ext.plainText;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:realStr];
    for (RTAComponent *component in ext.textComponents) {
        [self generateAttrabute:attStr ofComponent:component];
    }
    return attStr;
}

static NSString *g_rta_fontName = @"fontName";
static NSString *g_rta_fontNameStyle = @"fontStyle";
static NSString *g_rta_fontSize = @"fontSize";

- (NSDictionary *)generateComponentAttribute_ext:(RTAComponent*)component to:(NSMutableAttributedString*)attr {
    NSNumber *fontSizeNumber = nil;
    NSString *fontName = nil;
    NSString *fontStyle = nil;
    
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
            fontSizeNumber = component.attributes[key];
        } else if(isTagSame(key, @"fontName")){
            fontName = component.attributes[key];
        }  else if(isTagSame(key, @"fontStyle")){
            fontStyle = component.attributes[key];
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
    
    NSMutableDictionary *mDic = [NSMutableDictionary new];
    if (nil != fontName) {
        mDic[g_rta_fontName] = fontName;
    }
    
    if (nil != fontSizeNumber) {
        mDic[g_rta_fontSize] = fontSizeNumber;
    }
    
    if (nil != fontStyle) {
        mDic[g_rta_fontNameStyle] = fontStyle;
    }
    return mDic;
}

- (void)generateParagraphAttribute:(RTAComponent*)component to:(NSMutableAttributedString*)attr
{
    if(!isTagSame(@"p", component.tagLabel)) {
        return;
    }
    
    NSArray *allKeys = [component.attributes allKeys];
    NSRange r;
    r.location = component.position;
    r.length = component.text.length;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    BOOL isAdded = NO;
    for (NSString *key in allKeys) {
        if (isTagSame(key, @"lineSpace")) {
            isAdded = YES;
            CGFloat lineSpace = [component.attributes[key] floatValue];
            [paragraphStyle setLineSpacing:lineSpace];
        } else if(isTagSame(key, @"indent")) {
            isAdded = YES;
            CGFloat indent = [component.attributes[key] floatValue];
            paragraphStyle.firstLineHeadIndent = indent;
        } else if(isTagSame(key, @"paragraphSpacing")) {
            CGFloat paragraphSpacing = [component.attributes[key] floatValue];
            paragraphStyle.paragraphSpacing = paragraphSpacing;
        }
    }
    if (isAdded) {
        [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:r];
    }
}

- (UIFont *)generateFontWithSize:(CGFloat)fontSize fontName:(NSString *)fontName fontStyle:(NSString *)fontStyle {
    if (fontSize < 1 && fontName.length < 1 && fontStyle.length < 1) {
        return nil;
    }
    if (fontSize < 1) {
        fontSize = self.fontSize;
    }
    
    // if the fontName is nil then use systemFont style
    UIFont *font = nil;
    if (nil == fontName && nil != fontStyle) {
        UIFontWeight weight = -1;
        if (isTagSame(@"medium", fontStyle)) {
            weight = UIFontWeightMedium;
        } else if (isTagSame(@"bold", fontStyle)) {
            weight = UIFontWeightBold;
        } else if (isTagSame(@"light", fontStyle)) {
            weight = UIFontWeightLight;
        } else if (isTagSame(@"thin", fontStyle)) {
            weight = UIFontWeightThin;
        } else if (isTagSame(@"heavy", fontStyle)) {
            weight = UIFontWeightHeavy;
        } else if (isTagSame(@"ultraLight", fontStyle)) {
            weight = UIFontWeightUltraLight;
        } else if (isTagSame(@"semiBold", fontStyle)) {
            weight = UIFontWeightSemibold;
        } else if (isTagSame(@"black", fontStyle)) {
            weight = UIFontWeightBlack;
        } else {
            font = [UIFont systemFontOfSize:fontSize];
        }
        if (nil == font) {
            font = [UIFont systemFontOfSize:fontSize weight:weight];
        }
    } else {
        if (nil == fontName) {
            fontName = self.fontName;
        }
        font = [UIFont fontWithName:fontName size:fontSize];
    }
    
    return font;
}

- (void)generateAttrabute:(NSMutableAttributedString*)attr ofComponent:(RTAComponent*)component
{
    NSRange r;
    
    r.location = component.position;
    r.length = component.text.length;
    
    NSString *strKey = component.tagLabel;
    
    NSDictionary *fontParams = [self generateComponentAttribute_ext:component to:attr];
    
    NSString *fontName = fontParams[g_rta_fontName];
    NSString *fontStyle = fontParams[g_rta_fontNameStyle];
    CGFloat fontSize = [fontParams[g_rta_fontSize] floatValue];

    // <i> <b> label only support UIFont systemFont.
    // other labels can support fontName and fontStyle.
    
    if (isTagSame(strKey, @"i")) {
        if (fontSize<1) {
            fontSize = self.fontSize;
        }
        UIFont *font = [UIFont italicSystemFontOfSize:fontSize];
        [attr addAttribute:NSFontAttributeName value:font range:r];
    } else if(isTagSame(strKey, @"b")) {
        if (fontSize<1) {
            fontSize = self.fontSize;
        }
        UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
        [attr addAttribute:NSFontAttributeName value:font range:r];
    } else if(isTagSame(strKey, @"u") || isTagSame(strKey, @"del")) {
        
        
        UIFont *font = [self generateFontWithSize:fontSize fontName:fontName fontStyle:fontStyle];
        if (font) {
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
        UIFont *font = [self generateFontWithSize:fontSize fontName:fontName fontStyle:fontStyle];
        if (font) {
            [attr addAttribute:NSFontAttributeName value:font range:r];
        }
    } else if(isTagSame(strKey, @"p")) {
        
        if (fontSize>1) {
            UIFont *font = [self generateFontWithSize:fontSize fontName:fontName fontStyle:fontStyle];
            if (font) {
                [attr addAttribute:NSFontAttributeName value:font range:r];
            }
            
        }
        [self generateParagraphAttribute:component to:attr];
    }
}
@end
