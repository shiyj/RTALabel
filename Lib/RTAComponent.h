//
//  RTAComponent.h
//  RTALabel
//
//  Created by engin on 15-3-14.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTAAttributeNode : NSObject
@property (nonatomic,copy)NSString *name;
@property (nonatomic,strong) id value;
@end


@interface RTAComponent : NSObject
@property (nonatomic, assign) BOOL isPair;
@property (nonatomic, assign) int componentIndex;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *tagLabel;
@property (nonatomic) NSMutableDictionary *attributes;
@property (nonatomic, assign) NSInteger position;

- (id)initWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes;
+ (id)componentWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes;
- (id)initWithTag:(NSString*)aTagLabel position:(int)_position attributes:(NSMutableDictionary*)_attributes;
+ (id)componentWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes;


@end
