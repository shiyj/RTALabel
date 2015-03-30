//
//  RTAExtractedComponent.h
//  RTALabel
//
//  Created by engin on 15-3-14.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface RTAExtractedComponent : NSObject
@property (nonatomic, strong) NSMutableArray *textComponents;
@property (nonatomic, copy) NSString *plainText;
+ (RTAExtractedComponent*)extractTextStyleFromText:(NSString*)data;
@end
