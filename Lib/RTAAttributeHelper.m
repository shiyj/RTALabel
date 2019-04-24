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



static inline float floatFromHex(NSString *str)
{
    NSScanner *scanner = [NSScanner scannerWithString:str];
    float f;
    [scanner scanFloat:&f];
    return f;
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
    
    // green
    range.location +=2;
    subStr = [color substringWithRange:range];
    green = intergerFromHex(subStr);
    
    // blue
    range.location +=2;
    subStr = [color substringWithRange:range];
    blue = intergerFromHex(subStr);
    
    // alpha
    CGFloat alpha = 1;
    range.location += 2;
    if (color.length >=  range.location + range.length) {
        subStr = [color substringWithRange:range];
        alpha = intergerFromHex(subStr)/255.0;
    }
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

static inline CGRect rectFromString(NSString *str)
{
    NSRange r= NSMakeRange(1, str.length - 2);
    str = [str substringWithRange:r];
    NSArray *arr = [str componentsSeparatedByString:@","];
    if ([arr count] !=4) {
        return CGRectZero;
    }
    
    CGRect rect;
    rect.origin.x = floatFromHex(arr[0]);
    rect.origin.y = floatFromHex(arr[1]);
    rect.size.width = floatFromHex(arr[2]);
    rect.size.height = floatFromHex(arr[3]);
    return rect;
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

-(BOOL)isAppendComponent:(RTAComponent *)component {
    if (isTagSame(component.tagLabel, @"image")
        || isTagSame(component.tagLabel, @"space")) {
        return YES;
    }
    return NO;
}

-(NSAttributedString*)generateString:(NSString*)richText
{
    RTAExtractedComponent *ext = [RTAExtractedComponent extractTextStyleFromText:richText];
    NSString *realStr = ext.plainText;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:realStr];
    NSMutableArray *insertComponents = [NSMutableArray new];
    for (NSInteger i=[ext.textComponents count] - 1; i>= 0; --i) {
        RTAComponent *component = ext.textComponents[i];
        if ([self isAppendComponent:component]) {
            [insertComponents addObject:component];
        } else {
            [self generateAttrabute:attStr ofComponent:component];
        }
    }
    
    for (NSInteger i=0; i<[insertComponents count]; i++) {
        RTAComponent *component = insertComponents[i];
        if ([component.tagLabel isEqualToString:@"image"]) {
            [self generateImageAttribute:component to:attStr];
        } else if([component.tagLabel isEqualToString:@"space"]) {
            [self generateSpaceAttribute:component to:attStr];
        }
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
        } else if(isTagSame(key, @"bg_color")) {
            UIColor *color =colorFromHexString(component.attributes[key]);
            if (nil!=color) {
                [attr addAttribute:NSBackgroundColorAttributeName value:color range:r];
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
        } else if (isTagSame(key, @"minLineHeight")) {
            isAdded = YES;
            CGFloat minLineHeight = [component.attributes[key] floatValue];
            paragraphStyle.minimumLineHeight = minLineHeight;
        } else if (isTagSame(key, @"maxLineHeight")) {
            isAdded = YES;
            CGFloat maxLineHeight = [component.attributes[key] floatValue];
            paragraphStyle.maximumLineHeight = maxLineHeight;
        } else if(isTagSame(key, @"indent")) {
            isAdded = YES;
            CGFloat indent = [component.attributes[key] floatValue];
            paragraphStyle.firstLineHeadIndent = indent;
        } else if(isTagSame(key, @"paragraphSpacing")) {
            CGFloat paragraphSpacing = [component.attributes[key] floatValue];
            paragraphStyle.paragraphSpacing = paragraphSpacing;
        } else if(isTagSame(key, @"align")) {
            NSString *value = component.attributes[key];
            
            NSTextAlignment align = NSTextAlignmentLeft;
            if (isTagSame(@"left", value)) {
                align = NSTextAlignmentLeft;
            } else if (isTagSame(@"right", value)) {
                align = NSTextAlignmentRight;
            } else if (isTagSame(@"center", value)) {
                align = NSTextAlignmentCenter;
            } else if (isTagSame(@"Justified", value)) {
                align = NSTextAlignmentJustified;
            } else if (isTagSame(@"Natural", value)) {
                align = NSTextAlignmentNatural;
            }
            paragraphStyle.alignment = align;
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
        } else if (isTagSame(@"regular", fontStyle)) {
            weight = UIFontWeightRegular;
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

- (void)generateSpaceAttribute:(RTAComponent*)component to:(NSMutableAttributedString*)attr {
    NSArray *allKeys = [component.attributes allKeys];
    NSString *strValue = nil;
    
    for (NSString *key in allKeys) {
        if (isTagSame(key, @"value")) {
            strValue = component.attributes[key];
            break;
        }
    }
    if (strValue.length > 0) {
        CGFloat offset = [strValue floatValue];
        
        if (component.position <= 0) {
            return;
        }
        NSInteger len = component.text.length;
        if (len < 1) {
            len = 1;
        }
        NSRange r = NSMakeRange(component.position - 1, len);
        [attr addAttribute:NSKernAttributeName value:@(offset) range:r];
    }
}
- (void)generateImageAttribute:(RTAComponent*)component to:(NSMutableAttributedString*)attr
{
    NSArray *allKeys = [component.attributes allKeys];
    NSString *imageName = nil;
    NSString *boundsString = nil;
    for (NSString *key in allKeys) {
        if (isTagSame(key, @"imageName")) {
            imageName = component.attributes[key];
        } else if (isTagSame(key, @"bounds")) {
            boundsString = component.attributes[key];
        }
    }
    if (imageName.length > 0) {
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            NSTextAttachment *attachement = [NSTextAttachment new];
            attachement.image = image;
            CGRect bounds = rectFromString(boundsString);
            if (CGRectEqualToRect(bounds, CGRectZero) ) {
                bounds.size = image.size;
                UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];
                if (font) {
                    CGFloat y = -(font.lineHeight - font.pointSize)/2.0;
                    bounds.origin.y = y;
                }
            }
            attachement.bounds = bounds;
            NSAttributedString *imgAttr = [NSAttributedString attributedStringWithAttachment:attachement];
            [attr insertAttributedString:imgAttr atIndex:component.position];
        }
    }
}
- (void)generateAttrabute:(NSMutableAttributedString*)attr ofComponent:(RTAComponent*)component
{
    NSString *strKey = component.tagLabel;
    if (isTagSame(strKey, @"image")) {
        return;
    }
    NSRange r;
    r.location = component.position;
    r.length = component.text.length;
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
