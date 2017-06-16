//
//  HttpRequestHelper.m
//  fate
//
//  Created by 周恩 on 15/11/22.
//  Copyright © 2015年 zhouen. All rights reserved.
//

#import "HttpRequest.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
//网络监控

typedef enum{
    POST = 0,
    GET = 1
}RequestType;
static NSMutableArray *tasks;

@implementation HttpRequest

+ (HttpRequest *)shareInstance
{
    static HttpRequest *requestUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestUtil = [[HttpRequest alloc] init];
        requestUtil.isNetworkConnected = YES;
    });
    return requestUtil;
}


- (NSMutableArray *)tasks{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}


- (NSURLSessionTask *)postRequestWithURL:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                                success:(ResponseSuccess)success
                                failure:(ResponseFailure)failure{
    return [self request:POST url:URLString parameters:parameters success:success failure:failure];
}


- (NSURLSessionTask *)getRequestWithURL:(NSString *)URLString
                            parameters:(NSDictionary *)parameters
                               success:(ResponseSuccess)success
                               failure:(ResponseFailure)failure{
    
    return [self request:GET url:URLString parameters:parameters success:success failure:failure];
    
}

- (NSURLSessionTask *)request:(RequestType)type
                          url:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(ResponseSuccess)success
                      failure:(ResponseFailure)failure{
    if (URLString == nil) {
        return nil;
    }
    NSString *urlStr = URLString;
    //检查地址中是否有中文
    urlStr = [NSURL URLWithString:urlStr]?urlStr:[self strUTF8Encoding:urlStr];
    AFHTTPSessionManager *manager = [self getAFNManager];
    NSURLSessionTask *sessionTask = nil;
    
    if (type==1) {
        sessionTask = [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(responseObject);
            }
            
            [[self tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error=%@",error);
            if (failure) {
                failure(error);
            }
            [[self tasks] removeObject:sessionTask];
            
        }];
        
    }else{
        
        sessionTask = [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(responseObject);
            }
            [[self tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error);
            }
            [[self tasks] removeObject:sessionTask];
            
        }];
    }
    
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
    
}

-(void)uploadWithURL:(NSString *)url
                 data:(NSData *)data
                 name:(NSString *)name
             fileName:(NSString *)fileName
               params:(NSDictionary *)params
              success:(ResponseSuccess)success
              failure:(ResponseFailure)failure{
    
    NSString *urlStr = url;
    //检查地址中是否有中文
    urlStr = [NSURL URLWithString:urlStr]?urlStr:[self strUTF8Encoding:urlStr];
    
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"multipart/form-data"];
        } error:nil];
        
//        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//        manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    
        AFHTTPSessionManager *manager = [self getAFNManager];
        NSURLSessionUploadTask *uploadTask;
        uploadTask = [manager
                      uploadTaskWithStreamedRequest:request
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          if (error) {
                              if (failure) failure(error);
                          } else {
                              if (success) {
                                  success(responseObject);
                              }
                          }
                          [[self tasks] removeObject:uploadTask];
                      }];
        
        
        [uploadTask resume];
    
    if (uploadTask) {
        [[self tasks] addObject:uploadTask];
    }
}



- (AFHTTPSessionManager *)getAFNManager{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//设置返回数据为json
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html",@"text/json",@"text/plain",@"text/javascript",@"text/xml",@"image/*"]];
    
    
#ifndef DEBUG
//    //设置证书模式，AFSSLPinningModeNone，代表前端包内不验证
//    //在单向认证时，前端不放证书，服务器去验证
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    // 如果是需要服务端验证证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = YES;
//    //validatesDomainName 是否需要验证域名，默认为YES；
//    securityPolicy.validatesDomainName = NO;
//    //设置验证模式
//    manager.securityPolicy = securityPolicy;
//
#endif
    
    
    
    return manager;
}

#pragma mark - 开始监听网络连接
- (void)startMonitoring
{
    //1.创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                self.isNetworkConnected = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                self.isNetworkConnected = NO;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据网");
                self.isNetworkConnected = YES;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
                self.isNetworkConnected = YES;
                break;
                
            default:
                [[NSNotificationCenter defaultCenter] postNotificationName:NetworkEnvironmentChangesNotification object:nil];
                break;
        }
        
    }] ;
    [manager startMonitoring];
}


- (NSString *)strUTF8Encoding:(NSString *)str{
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (void)handleResponse:(id)response success:(ResponseSuccess)success failure:(ResponseFailure)failure {
    [self handleResponse:response successCode:200 success:success failure:failure];

}

+ (void)handleResponse:(id)response successCode:(int)successCode success:(ResponseSuccess)success failure:(ResponseFailure)failure {
    successCode = (successCode == 0) ? 200:successCode;
    int code = [response[@"code"] intValue];
    __block NSString *message = response[@"message"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (code == successCode) {
            if (success) {
                success(response[@"data"]);
            }
        }else{
            if (failure) {
                message = message.length >0?message:@" ";
                NSError *error = [NSError errorWithDomain:@"http://" code:code userInfo:@{NSLocalizedDescriptionKey:message}];
                failure(error);
            }
            
        }
    });
}

+ (void)handleError:(id)error failure:(ResponseFailure)failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (failure) {
            failure(error);
        }
    });
}
@end
