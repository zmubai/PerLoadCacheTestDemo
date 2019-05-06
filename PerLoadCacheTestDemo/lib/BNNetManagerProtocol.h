//
//  BNNetManagerProtocol.h
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNNetTypeSet.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BNNetManagerProtocol <NSObject>
@optional
- (void)processCache:(_Nullable id)cache callBackBlock:(BNNetCacheBlock)callBackBlock;
- (void)processResponseObj:(_Nullable id)obj callBackBlock:(BNNetProcessBlock)callBackBlock;
- (void)processError:(NSError * _Nonnull )error callBackBlock:(BNNetProcessBlock)callBackBlock;
@end

NS_ASSUME_NONNULL_END
