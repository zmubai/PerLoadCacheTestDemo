//
//  BNNetTypeSet.h
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#ifndef BNNetTypeSet_h
#define BNNetTypeSet_h

typedef NS_OPTIONS(NSUInteger, BNNetCacheOption) {
    BNNetCacheOptionUnUse = 1 << 0,
    BNNetCacheOptionUse = 1 << 1,
    BNNetCacheOptionPerLoad = 1 << 2,/*预加载*/
    BNNetCacheOptionIgnoreNetCallBackWhenCacheRespondEqualNetRespond = 1 << 3,/*缓存数据与网络数据一致时，忽略网络数据回调*/
};

typedef void (^BNNetCacheBlock)(_Nullable id responseObj);
typedef void (^BNNetSuccessBlock)(_Nonnull id responseObj);
typedef void (^BNNetFailureBlock)( NSError * _Nonnull error);
typedef void (^BNNetProcessBlock)(_Nullable id responseObj, NSError * _Nullable error);

#endif /* BNNetTypeSet_h */
