//
//  BNNetManager.h
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNNetTypeSet.h"
#import "BNNetManagerProtocol.h"
#import "BNHTTPManager.h"
#import "BNNetCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface BNNetManager : NSObject

@property (nonatomic, strong, readonly) BNHTTPManager *httpManager;
@property (nonatomic, strong, readonly) BNNetCacheManager *cacheManager;

+ (instancetype)sharedManager;

+ (void)setupWithDeleage:(nullable id<BNNetManagerProtocol>)delegate;

- (void)get:(NSString *)url params:(nullable NSDictionary *)params
    success:(nullable BNNetSuccessBlock)success
    failure:(nullable BNNetFailureBlock)failure;

- (void)post:(nullable NSString *)url params:(NSDictionary *)params
     success:(nullable BNNetSuccessBlock)success
     failure:(nullable BNNetFailureBlock)failure;

- (void)get:(NSString *)url params:(nullable NSDictionary *)params
cacheOption:(BNNetCacheOption)cacheOption
      cache:(nullable BNNetCacheBlock)cache
    success:(nullable BNNetSuccessBlock)success
    failure:(nullable BNNetFailureBlock)failure;

- (void)post:(NSString *)url params:(nullable NSDictionary *)params
 cacheOption:(BNNetCacheOption)cacheOption
       cache:(nullable BNNetCacheBlock)cache
     success:(nullable BNNetSuccessBlock)success
     failure:(nullable BNNetFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
