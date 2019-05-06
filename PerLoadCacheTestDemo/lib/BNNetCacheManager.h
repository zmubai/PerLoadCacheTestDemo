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
@property (nonatomic, assign) NSInteger perLoadMaxCount; ///>0 如果为0要处理下
@property (nonatomic, assign) NSInteger secondPreLoadMaxCount;
@property (nonatomic, strong, readonly) YYCache *yyCacheInstace;
+ (instancetype)sharedManager;
- (void)registerPrecedenceLoadKeyUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method;
- (void)loadPrecedenceUrlDatas;
- (void)querycacheWithUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method cacheResultBlock:(BNNetCacheResultBlock) resultBlock;
- (void)savaDictionary:(NSDictionary*)dict WithUrl:(NSString *)url params:(NSDictionary*)params method:(NSString*)method;
@end

NS_ASSUME_NONNULL_END
