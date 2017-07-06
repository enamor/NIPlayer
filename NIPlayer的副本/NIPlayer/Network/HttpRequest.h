//
//  HttpRequestHelper.h
//  fate
//
//  Created by 周恩 on 15/11/22.
//  Copyright © 2015年 zhouen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NetworkEnvironmentChangesNotification @"NetworkEnvironmentChangesNotification"


typedef void( ^ ResponseSuccess)(id response);
typedef void( ^ ResponseFailure)(id error);

typedef void( ^ UploadProgress)(int64_t bytesProgress,int64_t totalBytesProgress);
typedef void( ^ DownloadProgress)(int64_t bytesProgress,int64_t totalBytesProgress);

@interface HttpRequest : NSObject

@property (assign,nonatomic) BOOL isNetworkConnected;

+ (instancetype )shareInstance;


- (NSURLSessionTask *)getRequestWithURL:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                                success:(ResponseSuccess)success
                                failure:(ResponseFailure)failure;

- (NSURLSessionTask *)postRequestWithURL:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                                success:(ResponseSuccess)success
                                failure:(ResponseFailure)failure;

/**
 *  上传头像
 *
 *  @param url      url
 *  @param data     图片二进制数据
 *  @param name     对应后台参数名称
 *  @param fileName 文件名()
 *  @param params   其他参数
 *  @param success  －－
 *  @param failure  －－
 */
-(void)uploadWithURL:(NSString *)url
                data:(NSData *)data
                name:(NSString *)name
            fileName:(NSString *)fileName
              params:(NSDictionary *)params
             success:(ResponseSuccess)success
             failure:(ResponseFailure)failure;

/**
 默认处理200
 */
+ (void)handleResponse:(id)response
               success:(ResponseSuccess)success
               failure:(ResponseFailure)failure;

+ (void)handleResponse:(id)response
           successCode:(int)successCode
               success:(ResponseSuccess)success
               failure:(ResponseFailure)failure;

+ (void)handleError:(id)error
               failure:(ResponseFailure)failure;

@end
