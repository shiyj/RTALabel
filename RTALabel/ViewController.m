//
//  ViewController.m
//  RTALabel
//
//  Created by engin on 15-3-30.
//  Copyright (c) 2015年 geoinker.com. All rights reserved.
//

#import "ViewController.h"
#import "UILabel+RichText.h"

@interface ViewController ()
{
    NSArray *_allTextArray;
    NSInteger _currentIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *originLabel;
@property (weak, nonatomic) IBOutlet UILabel *renderLabel;

@end

@implementation ViewController

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
    [self.renderLabel setRichAttributedText:str];
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
