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
        NSInteger position = [data rangeOfString:delimiter].location;
        
        if (position!=NSNotFound)
        {
            
            data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
            
            
            data = [data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            data = [data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            
            
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
                    if (component.text==nil && [component.tagLabel isEqualToString:tag])
                    {
                        NSString *text2 = [data substringWithRange:NSMakeRange(component.position, position-component.position)];
                        component.text = text2;
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
