//
//  BNHTTPManager.h
//  BNNetMoudle
//
//  Created by jiuying on 2019/3/12.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface BNHTTPManager : AFHTTPSessionManager
+ (instancetype)sharedManager;
@end

NS_ASSUME_NONNULL_END
