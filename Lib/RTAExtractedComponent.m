//
//  RTAExtractedComponent.m
//  RTALabel
//
//  Created by engin on 15-3-14.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//
#import "RTAExtractedComponent.h"
#import "RTAComponent.h"

@implementation RTAExtractedComponent

+ (RTAExtractedComponent*)extractTextStyleFromText:(NSString*)data
{
    NSScanner *scanner = nil;
    
    NSString *tag = nil;
    
    NSMutableArray *components = [NSMutableArray array];
    
    NSInteger last_position = 0;
    scanner = [NSScanner scannerWithString:data];
    while (![scanner isAtEnd])
    {
        NSString *text = nil;
        
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];
        
        if (nil==text) {
            data = [data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            data = [data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            break;
        }
        
        NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
        NSRange searchRange;
        searchRange.location = last_position;
        searchRange.length = data.length - last_position;
        
        NSRange delimiterRange = [data rangeOfString:delimiter options:NSCaseInsensitiveSearch range:searchRange];
        NSInteger position = delimiterRange.location;
        
        if (position!=NSNotFound)
        {
            data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:delimiterRange];
        }
        
        if ([text rangeOfString:@"</"].location==0)
        {
            // end of tag
            tag = [text substringFromIndex:2];
            if (position!=NSNotFound)
            {
                for (NSInteger i=[components count]-1; i>=0; i--)
                {
                    RTAComponent *component = [components objectAtIndex:i];
                    if (NO == component.isPair && [component.tagLabel isEqualToString:tag])
                    {
                        NSString *text2 = [data substringWithRange:NSMakeRange(component.position, position-component.position)];
                        component.text = text2;
                        component.isPair = YES;
                        
                        NSString *newText = [text2 stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                        newText = [newText stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                        if (newText.length != text2.length) {
                            NSRange r = NSMakeRange(component.position, text2.length);
                            data = [data stringByReplacingCharactersInRange:r withString:newText];
                            component.text = newText;
                            position -= text2.length - newText.length;
                        }
                        break;
                    }
                }
            }
            
        }
        else
        {
            // start of tag
            NSArray *textComponents = [[text substringFromIndex:1] componentsSeparatedByString:@" "];
            tag = [textComponents objectAtIndex:0];
            //NSLog(@"start of tag: %@", tag);
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            for (NSUInteger i=1; i<[textComponents count]; i++)
            {
                NSArray *pair = [[textComponents objectAtIndex:i] componentsSeparatedByString:@"="];
                if ([pair count] > 0) {
                    NSString *key = [[pair objectAtIndex:0] lowercaseString];
                    
                    if ([pair count]>=2) {
                        // Trim " charactere
                        NSString *value = [[pair subarrayWithRange:NSMakeRange(1, [pair count] - 1)] componentsJoinedByString:@"="];
                        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 1)];
                        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange([value length]-1, 1)];
                        
                        [attributes setObject:value forKey:key];
                    } else if ([pair count]==1) {
                        [attributes setObject:key forKey:key];
                    }
                }
            }
            RTAComponent *component = [RTAComponent componentWithString:nil tag:tag attributes:attributes];
            component.position = position;
            [components addObject:component];
        }
        
        last_position = position;
    }
    RTAExtractedComponent *extra = [RTAExtractedComponent new];
    extra.textComponents = components;
    extra.plainText = data;
    return extra;
}

@end
