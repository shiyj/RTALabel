//
//  TextViewController.m
//  RTALabel
//
//  Created by engin on 15-4-19.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import "TextViewController.h"
#import "RTAAttributeHelper.h"

@interface TextViewController()
{
    NSArray *_allTextArray;
    NSInteger _currentIndex;
}
@property (weak, nonatomic) IBOutlet UITextView *originLabel;
@property (weak, nonatomic) IBOutlet UITextView *renderLabel;
@end
@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *dic = [self getDataDic];
    _allTextArray = dic[@"items"];
    _currentIndex = 0;
    [self setCurrentLabel];
}

- (void)setCurrentLabel
{
    _currentIndex ++;
    if (_currentIndex >= [_allTextArray count]) {
        _currentIndex = 0;
    }
    
    NSString *str = _allTextArray[_currentIndex];
    NSAttributedString *attr = [RTAAttributeHelper generateString:str forView:self.renderLabel];
    self.renderLabel.attributedText = attr;
    self.originLabel.text = str;
}
- (NSDictionary*)getDataDic
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:strPath];
    NSData *dataJSON  = [fileHandle readDataToEndOfFile];
    
    NSError *err=nil;
    NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:dataJSON options:NSJSONReadingMutableContainers error:&err];
    
    return dic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapToShowNext:(id)sender {
    [self setCurrentLabel];
}
@end
