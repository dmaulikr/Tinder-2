//
//  DDApiProxy.m
//  Tinder
//
//  Created by 张德荣 on 16/6/2.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import "DDApiProxy.h"
#import <AFNetworking/AFNetworking.h>

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
//    NSURLRequest *request = [ddre]
}
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(AXCallback)success fail:(AXCallback)fail {
    NSLog(@"%@",request.URL);
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @(dataTask.taskIdentifier);
        
    }];
    return @0;
}
@end
