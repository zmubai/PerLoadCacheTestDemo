//
//  BNNetManager.m
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "BNNetManager.h"

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@interface BNNetManager ()
@property (nonatomic, strong, readwrite) BNHTTPManager *httpManager;
@property (nonatomic, strong, readwrite) BNNetCacheManager *cacheManager;
@property (nonatomic, strong) id<BNNetManagerProtocol> delegate;
@end

@implementation BNNetManager
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static BNNetManager *netManager;
    dispatch_once(&onceToken, ^{
        netManager = BNNetManager.new;
        netManager.httpManager = BNHTTPManager.sharedManager;
        netManager.cacheManager = BNNetCacheManager.sharedManager;
    });
    return netManager;
}

+ (void)setupWithDeleage:(nullable id<BNNetManagerProtocol>)delegate
{
    [BNNetManager sharedManager].delegate = delegate;
}

- (void)get:(NSString *)url params:(nullable NSDictionary *)params
    success:(nullable BNNetSuccessBlock)success
    failure:(nullable BNNetFailureBlock)failure
{
    [self _innerGet:url params:params cacheOption:(BNNetCacheOptionUnUse) cache:nil success:success failure:failure];
}

- (void)post:(nullable NSString *)url params:(NSDictionary *)params
     success:(nullable BNNetSuccessBlock)success
     failure:(nullable BNNetFailureBlock)failure
{
    [self _innerPost:url params:params cacheOption:(BNNetCacheOptionUnUse) cache:nil success:success failure:failure];
}

- (void)get:(NSString *)url params:(nullable NSDictionary *)params
cacheOption:(BNNetCacheOption)cacheOption
      cache:(nullable BNNetCacheBlock)cache
    success:(nullable BNNetSuccessBlock)success
    failure:(nullable BNNetFailureBlock)failure
{
    [self _innerGet:url params:params cacheOption:cacheOption cache:cache success:success failure:failure];
}

- (void)post:(NSString *)url params:(nullable NSDictionary *)params
 cacheOption:(BNNetCacheOption)cacheOption
       cache:(nullable BNNetCacheBlock)cache
     success:(nullable BNNetSuccessBlock)success
     failure:(nullable BNNetFailureBlock)failure
{
    [self _innerPost:url params:params cacheOption:cacheOption cache:cache success:success failure:failure];
}

#pragma mark -
- (void)_innerGet:(NSString *)url params:(nullable NSDictionary *)params
      cacheOption:(BNNetCacheOption)cacheOption
            cache:(nullable BNNetCacheBlock)cache
          success:(nullable BNNetSuccessBlock)success
          failure:(nullable BNNetFailureBlock)failure
{
    __weak __typeof(self) weakself = self;
    __block BOOL requestSuccess = NO;
    __block NSDictionary *kCacheDic = nil;

    if ((cacheOption & BNNetCacheOptionUse) && (cacheOption & BNNetCacheOptionPerLoad)) {
        [self.cacheManager registerPrecedenceLoadKeyUrl:url params:params method:@"get"];
    }

    if (cacheOption & BNNetCacheOptionUse) {
        [self.cacheManager querycacheWithUrl:url params:params method:@"get" cacheResultBlock:^(NSDictionary * _Nonnull cacheDictionary) {
            ///如果网络已经获取成功，取消缓存处理
            if(requestSuccess == YES) return;
            kCacheDic = cacheDictionary;
            if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(processCache:callBackBlock:)])
            {
                [weakself.delegate processCache:cacheDictionary callBackBlock:^(id  _Nullable responseObj) {
                    dispatch_main_async_safe(^{
                        if(cache) cache(responseObj);
                    });
                }];
            }
            else
            {
                dispatch_main_async_safe(^{
                    if(cache) cache(cacheDictionary);
                });
            }
        }];
    }

    [self.httpManager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        requestSuccess = YES;
        if(cacheOption & BNNetCacheOptionUse)
        {
            [self.cacheManager savaDictionary:responseObject WithUrl:url params:params method:@"get"];
            if((cacheOption & BNNetCacheOptionIgnoreNetCallBackWhenCacheRespondEqualNetRespond)&& [kCacheDic isEqual:responseObject])
            {
                return;
            }
        }

        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(processResponseObj:callBackBlock:)])
        {
            [weakself.delegate processResponseObj:responseObject callBackBlock:^(id  _Nullable kresponseObj, NSError * _Nullable error) {
                if (error) {
                    if(failure) failure(error);
                }
                else
                {
                    if(success) success(kresponseObj);
                }
            }];
        }
        else
        {
            if(success)success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(processError:callBackBlock:)])
        {
            [weakself.delegate processError:error callBackBlock:^(id  _Nullable kresponseObj, NSError * _Nonnull kError) {
                if (error) {
                    if(failure) failure(error);
                }
                else
                {
                    if(success) success(kresponseObj);
                }
            }];
        }
        else
        {
            if(failure)failure(error);
        }
    }];
}

- (void)_innerPost:(NSString *)url params:(nullable NSDictionary *)params
       cacheOption:(BNNetCacheOption)cacheOption
             cache:(nullable BNNetCacheBlock)cache
           success:(nullable BNNetSuccessBlock)success
           failure:(nullable BNNetFailureBlock)failure
{
    __weak __typeof(self) weakself = self;
    __block BOOL requestSuccess = NO;
    __block NSDictionary *kCacheDic = nil;

    if ((cacheOption & BNNetCacheOptionUse) && (cacheOption & BNNetCacheOptionPerLoad)) {
        [self.cacheManager registerPrecedenceLoadKeyUrl:url params:params method:@"post"];
    }

    if (cacheOption & BNNetCacheOptionUse) {
        [self.cacheManager querycacheWithUrl:url params:params method:@"post" cacheResultBlock:^(NSDictionary * _Nonnull cacheDictionary) {
            ///如果网络已经获取成功，取消缓存处理
            if(requestSuccess == YES) return;
            kCacheDic = cacheDictionary;
            if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(processCache:callBackBlock:)])
            {
                [weakself.delegate processCache:cacheDictionary callBackBlock:^(id  _Nullable responseObj) {
                    dispatch_main_async_safe(^{
                        if(cache) cache(responseObj);
                    });
                }];
            }
            else
            {
                dispatch_main_async_safe(^{
                    if(cache) cache(cacheDictionary);
                });
            }
        }];
    }

    [self.httpManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        requestSuccess = YES;
        if(cacheOption & BNNetCacheOptionUse)
        {
            [self.cacheManager savaDictionary:responseObject WithUrl:url params:params method:@"post"];
            if((cacheOption & BNNetCacheOptionIgnoreNetCallBackWhenCacheRespondEqualNetRespond)&& [kCacheDic isEqual:responseObject])
            {
                return;
            }
        }
        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(processResponseObj:callBackBlock:)])
        {
            [weakself.delegate processResponseObj:responseObject callBackBlock:^(id  _Nullable kresponseObj, NSError * _Nullable error) {
                if (error) {
                    if(failure) failure(error);
                }
                else
                {
                    if(success) success(kresponseObj);
                }
            }];
        }
        else
        {
            if(success)success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(processError:callBackBlock:)])
        {
            [weakself.delegate processError:error callBackBlock:^(id  _Nullable kresponseObj, NSError * _Nonnull kError) {
                if (error) {
                    if(failure) failure(error);
                }
                else
                {
                    if(success) success(kresponseObj);
                }
            }];
        }
        else
        {
            if(failure)failure(error);
        }
    }];
}

@end
