//
//  BNNETCacheManager.m
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "BNNetCacheManager.h"
#import <UIKit/UIKit.h>

static NSString *BNNetCacheName = @"BNNetCache";
static NSString *BNprecedenceKeyUrlsKey = @"BNprecedenceKeyUrlsKey";
static NSString *BNSecondPrecedenceKeyUrlsKey = @"BNSecondPrecedenceKeyUrlsKey";

#define LOCK(X) dispatch_semaphore_wait(X, DISPATCH_TIME_FOREVER)
#define UNLOCK(X) dispatch_semaphore_signal(X)

static NSString *BNCacheKey(NSString *url,NSDictionary *params, NSString *method)
{
    NSMutableString *mStr = @"".mutableCopy;
    ///add url
    if(url.length) [mStr appendString:url];
    ///add method
    if(method.length) [mStr appendString:method?:@""];
    ///sorte params keys
    NSArray *keys = params.allKeys;
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    ///add params
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:sort];
    [sortedKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mStr appendString:obj];
        [mStr appendString:[NSString stringWithFormat:@"%@",params[obj]]];
    }];
    ///repace space
    [mStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    ///try hash value
    //    return  @(mStr.hash).stringValue;
    return  mStr.copy;
}

@interface BNNetCacheManager ()
@property (nonatomic, strong) NSArray *precedenceKeyUrls;
@property (nonatomic, strong, readwrite) YYCache *yyCacheInstace;
@property (nonatomic, strong) dispatch_semaphore_t cacheSemaphore;
@property (nonatomic, strong) dispatch_queue_t workQueue;
@end

@implementation BNNetCacheManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static BNNetCacheManager *static_cacheManager;
    dispatch_once(&onceToken, ^{
        static_cacheManager = BNNetCacheManager.new;
        static_cacheManager.perLoadMaxCount = 10;
        static_cacheManager.secondPreLoadMaxCount = 2 * static_cacheManager.perLoadMaxCount;
        static_cacheManager.cacheSemaphore = dispatch_semaphore_create(1);
        static_cacheManager.workQueue = dispatch_queue_create("BNNetCacheManager.work.serial.queue", DISPATCH_QUEUE_SERIAL);
        [static_cacheManager _setup];
    });
    return static_cacheManager;
}

- (void)_setup
{
    _yyCacheInstace = [[YYCache alloc]initWithName:BNNetCacheName];
    _yyCacheInstace.memoryCache.countLimit = 500;
    _yyCacheInstace.diskCache.countLimit = 500;
}

#pragma mark -
//register url async serial
- (void)registerPrecedenceLoadKeyUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method
{
    dispatch_async(self.workQueue, ^{
        if (self.perLoadMaxCount <= 0) {
            return;
        }
        NSString *cacheKey = BNCacheKey(url,params,method);
        NSArray *preLoadKeys = (NSArray*)[self.yyCacheInstace.diskCache objectForKey:BNprecedenceKeyUrlsKey];
        if (![preLoadKeys containsObject:cacheKey]) {
            NSMutableArray *firstMArr = preLoadKeys?preLoadKeys.mutableCopy : @[].mutableCopy;
            if(preLoadKeys.count < self.perLoadMaxCount)
            {
                [firstMArr addObject:cacheKey];
            }
            else
            {
                if (self.secondPreLoadMaxCount > 0) {
                    NSArray *secondPreLoadKeys = (NSArray*)[self.yyCacheInstace.diskCache objectForKey:BNSecondPrecedenceKeyUrlsKey];
                    if (![secondPreLoadKeys containsObject:cacheKey]) {
                        NSMutableArray *secondMArr = secondPreLoadKeys?secondPreLoadKeys.mutableCopy : @[].mutableCopy;
                        if(secondPreLoadKeys.count > self.secondPreLoadMaxCount)
                        {
                            ///插入到firstPre header, 最后一个元素后移到secondPre header
                            [firstMArr insertObject:cacheKey atIndex:0];
                            [secondMArr insertObject:firstMArr.lastObject atIndex:0];
                            [firstMArr removeLastObject];
                            [secondMArr removeLastObject];
                        }
                        else
                        {
                            ///插入到secondPre header
                            [secondMArr insertObject:cacheKey atIndex:0];
                        }
                        [self.yyCacheInstace.diskCache setObject:secondMArr forKey:BNSecondPrecedenceKeyUrlsKey];
                        NSLog(@"BNNetMoudle：(maxcount:%ld)更新SecPreLoadUrls %@",(long)self.secondPreLoadMaxCount,secondMArr);
                    }
                }
            }
            [self.yyCacheInstace.diskCache setObject:firstMArr forKey:BNprecedenceKeyUrlsKey];
            NSLog(@"BNNetMoudle：(maxcount:%ld)更新PreLoadUrls %@",(long)self.perLoadMaxCount,firstMArr);
        }
    });
}

- (void)loadPrecedenceUrlDatas
{
    NSArray *keyUrls = (NSArray*)[self.yyCacheInstace.diskCache objectForKey:BNprecedenceKeyUrlsKey];
    NSLog(@"BNNetMoudle：同步预加载到urls:%@",keyUrls);
    [keyUrls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ///同步获取
        id dstValue =  [self.yyCacheInstace.diskCache objectForKey:obj];
        [self.yyCacheInstace.memoryCache setObject:dstValue forKey:obj];
    }];

    dispatch_async(self.workQueue, ^{
        NSArray *keyUrls = (NSArray*)[self.yyCacheInstace.diskCache objectForKey:BNSecondPrecedenceKeyUrlsKey];
        LOCK(self.cacheSemaphore);
        [keyUrls enumerateObjectsUsingBlock:^(NSString  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id object =   [self.yyCacheInstace.diskCache objectForKey:obj];
            if (object && ![self.yyCacheInstace.memoryCache containsObjectForKey:obj]) {
                [self.yyCacheInstace.memoryCache setObject:(id)object forKey:obj];
            }
        }];
        UNLOCK(self.cacheSemaphore);
        NSLog(@"BNNetMoudle：异步预加载到urls:%@",keyUrls);
    });
}

- (void)querycacheWithUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method cacheResultBlock:(BNNetCacheResultBlock) resultBlock
{
    [self _querycacheWithCacheKey:BNCacheKey(url,params,method) cacheResultBlock:resultBlock];
}

- (void)savaDictionary:(NSDictionary*)dict WithUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method
{
    if(![dict isKindOfClass:NSDictionary.class]) return;
    dispatch_async(self.workQueue, ^{
        [self _querycacheWithCacheKey:BNCacheKey(url,params,method) cacheResultBlock:^(NSDictionary * _Nonnull cacheDictionary) {
            if (cacheDictionary && [cacheDictionary isEqual:dict]) {
                return;
            }
            else
            {
                NSString *cacheKey = BNCacheKey(url,params,method);
                [self.yyCacheInstace.diskCache setObject:dict forKey:cacheKey];
                LOCK(self.cacheSemaphore);
                [self.yyCacheInstace.memoryCache setObject:dict forKey:cacheKey];
                UNLOCK(self.cacheSemaphore);
            }
        }];
    });
}

#pragma mark -
- (void)_querycacheWithCacheKey:(NSString *)cacheKey cacheResultBlock:(BNNetCacheResultBlock) resultBlock
{
    LOCK(self.cacheSemaphore);
    NSDictionary *dstDict = [self.yyCacheInstace.memoryCache objectForKey:cacheKey];
    UNLOCK(self.cacheSemaphore);
    if(resultBlock && dstDict)
    {
        resultBlock(dstDict);
        return;
    }
    dispatch_async(self.workQueue, ^{
        id object = [self.yyCacheInstace.diskCache objectForKey:cacheKey];
        if (object) {
            LOCK(self.cacheSemaphore);
            [self.yyCacheInstace.memoryCache setObject:(id)object forKey:cacheKey];
            UNLOCK(self.cacheSemaphore);
        }
        resultBlock((id)object);
    });
}

@end
