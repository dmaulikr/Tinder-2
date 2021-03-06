//
//  DDApiProxy.m
//  Tinder
//
//  Created by 张德荣 on 16/6/2.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import "DDApiProxy.h"
#import <AFNetworking/AFNetworking.h>
#import "DDRequestGenerator.h"
#import "DDLogger.h"

@interface DDApiProxy ()
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation DDApiProxy
#pragma mark - getter and setters
- (NSMutableDictionary *)dispatchTable
{
    if (!_dispatchTable) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}
- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}
#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static DDApiProxy* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DDApiProxy new];
    });

    return instance;
}
#pragma mark - public methods
- (NSInteger)callGetWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail
{
    NSURLRequest *request = [[DDRequestGenerator sharedInstance] generateGETRequestWithServiceIdentifier:servieIdentifier requestParams:params methodName:methodName];
    
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}
- (NSInteger)callPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail
{
    NSURLRequest *request = [[DDRequestGenerator sharedInstance] generatePOSTRequestWithServiceIdentifier:servieIdentifier requestParams:params methodName:methodName];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
    
}
- (NSInteger)callPUTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)serviedIdentifier methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail
{
    NSURLRequest *request = [[DDRequestGenerator sharedInstance] generatePUTRequestWithServiceIdentifier:serviedIdentifier requestParams:params methodName:methodName];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}
- (NSInteger)callDELETEWithParams:(NSDictionary *)params serviceIdetifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail
{
    NSURLRequest *request = [[DDRequestGenerator sharedInstance] generateDeleteRequestWithServiceIdentifier:servieIdentifier requestParams:params methodName:methodName];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];

    return requestId.integerValue;
}
- (void)cancelRequestWithRequestID:(NSNumber *)requestID {
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}
- (void)cancelRequestWithRequestList:(NSArray *)requestList
{
    for (NSNumber *requestId in requestList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(AXCallback)success fail:(AXCallback)fail {
    NSLog(@"%@",request.URL);
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @(dataTask.taskIdentifier);
        [self.dispatchTable removeObjectForKey:requestID];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSData *responseData = responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if (error) {
            [DDLogger logDebugInfoWithResponse:httpResponse responseString:responseString request:request error:error];
            DDURLResponse *ddResponse = [[DDURLResponse alloc] initWithResonseString:responseString requestId:requestID request:request responseData:responseData error:error];
            fail?fail(ddResponse):nil;
        } else {
            //检测http response是否成立
            [DDLogger logDebugInfoWithResponse:httpResponse responseString:responseString request:request error:NULL];
            DDURLResponse *ddResponse = [[DDURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData status:DDURLResponseStatusSuccess];
            success?success(ddResponse):nil;
        }
    }];
    
    NSNumber *requestId = @(dataTask.taskIdentifier);
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    return requestId;
}
@end
