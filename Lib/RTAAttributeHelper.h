//
//  RTAAttributeHelper.h
//  RTALabel
//
//  Created by engin on 15-4-19.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface RTAAttributeHelper : NSObject
-(instancetype)initWithFontName:(NSString*)name fontSize:(float)fontSize;
-(NSAttributedString*)generateString:(NSString*)richText;

+(NSAttributedString*)generateString:(NSString*)richText forView:(UIView*)view;
@end
