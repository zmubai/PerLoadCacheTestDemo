//
//  BNHTTPManager.m
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "BNHTTPManager.h"

@implementation BNHTTPManager
+ (instancetype)sharedManager {
    static BNHTTPManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BNHTTPManager alloc] init];
        // 设置json序列化
        _sharedManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        ///设置为15秒超时时间
        _sharedManager.requestSerializer.timeoutInterval = 15.0f;

        _sharedManager.responseSerializer = [AFJSONResponseSerializer serializer];
        // 设置可接受类型
        _sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json", nil];
    });
    return _sharedManager;
}
@end
