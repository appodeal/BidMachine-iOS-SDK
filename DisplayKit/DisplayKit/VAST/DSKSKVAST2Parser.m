//
//  SKVAST2Parser.m
//  VAST
//
//  Created by Jay Tucker on 10/2/13.
//  Copyright (c) 2013 Nexage. All rights reserved.
//

#import "DSKSKVAST2Parser.h"
#import "DSKVASTXMLUtil.h"
#import "DSKSKVASTModel.h"
#import "DSKVASTSchema.h"
#import "DSKVASTSettings.h"



@interface DSKSKVAST2Parser ()

@property (nonatomic, strong) DSKSKVASTModel * vastModel;
@property (nonatomic, assign) dispatch_queue_t parseQueue;

@end

@implementation DSKSKVAST2Parser

- (id)init
{
    self = [super init];
    if (self) {
        _vastModel = [[DSKSKVASTModel alloc] init];
    }
    return self;
}

#pragma mark - Queue

- (dispatch_queue_t)parseQueue {
    static dispatch_once_t pred;
    static dispatch_queue_t sharedDispatchQueue;
    
    dispatch_once(&pred, ^{
        sharedDispatchQueue = dispatch_queue_create("com.bidmachine.vast-parsing-queue", NULL);
    });
    
    return sharedDispatchQueue;
}

#pragma mark - "public" methods

- (void)parseWithUrl:(NSURL *)url completion:(void (^)(DSKSKVASTModel *, DSKVASTErrorCode))block
{
    dispatch_async(self.parseQueue, ^{
        NSData *vastData = [NSData dataWithContentsOfURL:url];
        DSKVASTErrorCode vastError = [self parseRecursivelyWithData:vastData error:nil depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

- (void)parseWithData:(NSData *)vastData completion:(void (^)(DSKSKVASTModel *, DSKVASTErrorCode))block
{
    dispatch_async(self.parseQueue, ^{
        DSKVASTErrorCode vastError = [self parseRecursivelyWithData:vastData error:nil depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

#pragma mark - "private" method

- (DSKVASTErrorCode)parseRecursivelyWithData:(NSData *)vastData error:(NSError *)error depth:(int)depth
{
    if (depth >= kDSKMaxRecursiveDepth) {
        _vastModel = nil;
        return DSKVASTUndefinedError;
    }
    
    // Validate the basic XML syntax of the VAST document.
    BOOL isValid;
    isValid = DSK_validateXMLDocSyntax(vastData);
    
    if (error) {
        return (DSKVASTErrorCode)error.code;
    } else if (!isValid) {
        return DSKVASTParsingError;
    }
    
    if (kDSKValidateWithSchema) {
        // Using header data
        NSData *vastSchemaData = [NSData dataWithBytesNoCopy:DSK_nexage_vast_2_0_1_xsd
                                                      length:DSK_nexage_vast_2_0_1_xsd_len
                                                freeWhenDone:NO];
        isValid = DSK_validateXMLDocAgainstSchema(vastData, vastSchemaData);
        if (!isValid) {
            _vastModel = nil;
            return DSKVASTParsingError;
        }
    }
    
    [_vastModel addVASTDocument:vastData];
    
    // Check to see whether this is a wrapper ad. If so, process it.
    NSString *query = @"//VASTAdTagURI";
    NSArray *results = DSK_performXMLXPathQuery(vastData, query);
    if ([results count] > 0) {
        NSString * url = @"";
        NSDictionary *node = results[0];
        if ([node[@"nodeContent"] length] > 0) {
            // this is for string data
            url = node[@"nodeContent"];
        } else {
            // this is for CDATA
            NSArray *childArray = node[@"nodeChildArray"];
            if ([childArray count] > 0) {
                // we assume that there's only one element in the array
                url = ((NSDictionary *)childArray[0])[@"nodeContent"];
            }
        }
        
        NSError * downloadError;
        vastData = [self synchronyousDownloadedDataFromURL:[NSURL URLWithString:url] error:&downloadError];
        if (downloadError) {
            downloadError = [NSError DSK_vastErrorWithCode:DSKVASTURIConnectionError];
        }
        return [self parseRecursivelyWithData:vastData error:downloadError depth:(depth + 1)];
    }
    
    return DSKVASTNoError;
}

- (NSData *)synchronyousDownloadedDataFromURL:(NSURL*)URL error:(NSError **)error {
    NSURLRequest * request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    __block NSData * downloadedData;
    __block NSError * blockError;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * recivedError) {
        downloadedData = data;
        blockError = recivedError;
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    *error != nil ? *error = blockError : nil;
    
    return downloadedData;
}

- (NSString *)content:(NSDictionary *)node
{
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }
    
    // this is for CDATA
    NSArray *childArray = node[@"nodeChildArray"];
    if ([childArray count] > 0) {
        // we assume that there's only one element in the array
        return ((NSDictionary *)childArray[0])[@"nodeContent"];
    }
    
    return nil;
}

@end
