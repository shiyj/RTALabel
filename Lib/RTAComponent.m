//
//  RTAComponent.m
//  RTALabel
//
//  Created by engin on 15-3-14.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import "RTAComponent.h"

@implementation RTAComponent
- (id)initWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes
{
    self = [super init];
    if (self) {
        _text = aText;
        _tagLabel = aTagLabel;
        _attributes = theAttributes;
    }
    return self;
}

+ (id)componentWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes
{
    return [[self alloc] initWithString:aText tag:aTagLabel attributes:theAttributes];
}

- (id)initWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes
{
    self = [super init];
    if (self) {
        _tagLabel = aTagLabel;
        _position = aPosition;
        _attributes = theAttributes;
    }
    return self;
}

+(id)componentWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes
{
    return [[self alloc] initWithTag:aTagLabel position:aPosition attributes:theAttributes];
}

- (NSString*)description
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"text: %@", self.text];
    [desc appendFormat:@", position: %ld", self.position];
    if (self.tagLabel) [desc appendFormat:@", tag: %@", self.tagLabel];
    if (self.attributes) [desc appendFormat:@", attributes: %@", self.attributes];
    return desc;
}
@end
