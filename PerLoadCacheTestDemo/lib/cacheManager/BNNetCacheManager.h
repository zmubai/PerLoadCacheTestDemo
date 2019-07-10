//
//  BNNETCacheManager.h
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYCache.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^BNNetCacheResultBlock)(NSDictionary *cacheDictionary);

@interface BNNetCacheManager : NSObject
/*预加载，同步（in main queue）最大缓存数量*/
@property (nonatomic, assign) NSInteger perLoadMaxCount;
/*预加载，异步(not in main queue)最大缓存数量*/
@property (nonatomic, assign) NSInteger secondPreLoadMaxCount;
/*基于YYCache的缓存单例*/
@property (nonatomic, strong, readonly) YYCache *yyCacheInstace;
+ (instancetype)sharedManager;


/**
 清除用于加载的keys，重新执行registerPrecedenceLoadKeyUrl，会从头插入
 */
- (void)clearPrecedenceLoadKeys;
/**
 预加载注册方法

 @param url 网络请求URL
 @param params 网络请求参数
 @param method 网络请求方法
 */
- (void)registerPrecedenceLoadKeyUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method;

/**
 预加载缓存数据
 */
- (void)loadPrecedenceUrlDatas;

/**
 查询缓存

 @param url 网络请求URL
 @param params 网络请求参数
 @param method 网络请求方法
 @param resultBlock 回调
 */
- (void)querycacheWithUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method cacheResultBlock:(BNNetCacheResultBlock) resultBlock;

/**
 保存缓存

 @param dict 缓存数据
 @param url 网络请求URL
 @param params 网络请求参数
 @param method 网络请求方法
 */
- (void)savaDictionary:(NSDictionary*)dict WithUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method;
@end

NS_ASSUME_NONNULL_END
