//
//  ViewController.m
//  PerLoadCacheTestDemo
//
//  Created by Bennie on 2019/5/6.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "ViewController.h"
#import "lib/BNNetManager.h"
#import "BNNetCacheManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //清空加载清单， 重新设定加载顺序
    [[BNNetCacheManager sharedManager]clearPrecedenceLoadKeys];

    NSString *url = @"http://www.douban.com/j/app/radio/channels";
    [[BNNetManager sharedManager] get:url params:nil cacheOption:(BNNetCacheOptionUse | BNNetCacheOptionPerLoad | BNNetCacheOptionIgnoreNetCallBackWhenCacheRespondEqualNetRespond) cache:^(id  _Nullable responseObj) {
        NSLog(@"cache obj :%@",responseObj);
    } success:^(id  _Nonnull responseObj) {
        NSLog(@"net obj :%@",responseObj);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
    }];
}


@end
