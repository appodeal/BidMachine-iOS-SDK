
#import <Foundation/Foundation.h>
#import <Kiwi/Kiwi.h>
#import "BDMApiRequest.h"
#import "BDMAdTypePlacement.h"
#import "BDMSdk.h"
#import "BDMRequest+ParallelBidding.h"
#import "BDMAuctionBuilder.h"
#import "BDMAuctionSettings.h"

SPEC_BEGIN(BDMApiRequestSpec)

describe(@"BDMApiRequestSpec", ^{
    __block BDMRequest *userRequest = nil;
    __block NSURLSession *session = nil;
    __block BDMOpenRTBAuctionSettings<BDMAuctionSettings> * auctionSettingsMock;
    
    beforeAll(^{
        auctionSettingsMock = [BDMOpenRTBAuctionSettings new];
        
        [auctionSettingsMock stub:@selector(domainSpec) andReturn:@"blablabla"];
        [auctionSettingsMock stub:@selector(domainVersion) andReturn:@"blablabla"];
        [auctionSettingsMock stub:@selector(protocolVersion) andReturn:@"blablabla"];
        [auctionSettingsMock stub:@selector(auctionCurrency) andReturn:@"blablabla"];
        [auctionSettingsMock stub:@selector(tmax) andReturn:theValue(10000)];
        [auctionSettingsMock stub:@selector(auctionType) andReturn:theValue(BDMAuctionTypeFirstPrice)];
        
        session = [NSURLSession sessionWithConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration];
        
        [BDMSdk.sharedSdk setValue:@"testSellerID" forKey:@"sellerID"];
        
        userRequest             = BDMRequest.new;
        userRequest.priceFloors        = @[({
            BDMPriceFloor *bid = BDMPriceFloor.new;
            bid.ID = @"testID";
            bid.value = [NSDecimalNumber decimalNumberWithString:@"1.1"];
            bid;
        })];
        userRequest.targeting   = ({
            BDMTargeting *targeting = BDMTargeting.new;
            targeting.userId                = @"testUserID";
            targeting.gender                = kBDMUserGenderMale;
            targeting.yearOfBirth           = @2018;
            targeting.keywords              = @"test, test";
            targeting.blockedCategories     = @[@"BCAT33"];
            targeting.blockedAdvertisers    = @[@"BADV33"];
            targeting.blockedApps           = @[@"BAPPS33"];
            targeting.deviceLocation        = [[CLLocation alloc] initWithLatitude:10 longitude:11];
            targeting.country               = @"testCountry";
            targeting.city                  = @"testSity";
            targeting.zip                   = @"testZip";
            targeting.storeId               = @"testStoreId";
            targeting.storeURL              = [NSURL URLWithString:@"testStoreUrl"];
            targeting.paid                  = true;
            targeting;
        });
    });
    
    
    it(@"try send interstitial request", ^{
        BDMApiRequest *request = [BDMApiRequest request:^(BDMAuctionBuilder *builder) {
            builder.appendRequest(userRequest);
            builder.appendPlacementBuilder([BDMAdTypePlacement interstitialPlacementWithAdType:BDMFullscreenAdTypeAll]);
            builder.appendAuctionSettings(auctionSettingsMock);
        }];
        
        __block NSError *loadingError = nil;
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
                                                    loadingError = error;
                                                }];
        [task resume];
        [[loadingError shouldEventually] beNil];
    });
    it(@"try send session request", ^{
        BDMApiRequest *request = [BDMApiRequest sessionRequest:^(BDMSessionBuilder *builder) {
            builder.appendSellerID(@"SellerID");
        }];
        
        __block NSError *loadingError = nil;
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
                                                    loadingError = error;
                                                }];
        [task resume];
        [[loadingError shouldEventually] beNil];
    });
});

SPEC_END
