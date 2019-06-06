#import <Kiwi/Kiwi.h>
#import "Openrtb.pbobjc.h"
#import "Adcom.pbobjc.h"
#import <CoreLocation/CoreLocation.h>
#import <ASKExtension/ASKExtension.h>

#import "BDMAuctionBuilder.h"
#import "BDMAdTypePlacement.h"
#import "BDMTransformers.h"
#import "BDMSdk+Project.h"

@interface BDMAuctionBuilder ()

@property (nonatomic, strong) BDMRequest * request;
@property (nonatomic, strong) id<BDMAuctionSettings> auctionSettings;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, copy) NSString * sellerID;
@property (nonatomic, strong) id<BDMPlacementRequestBuilder> placementBuilder;
@property (nonatomic, strong) BDMUserRestrictions *restrictions;

@end

SPEC_BEGIN(AuctionBuilderSpec)

describe(@"AuctionBuilderSpec", ^{
    __block BDMAuctionBuilder *builder;
    __block BDMRequest *request;
    __block BDMTargeting *targeting;
    __block BDMUserRestrictions *restriction;
    __block NSObject<BDMAuctionSettings> * auctionSettingsMock;
    __block NSObject<BDMPlacementRequestBuilder> * placementBuilderMock;
    __block ADCOMPlacement * placementMock;
    
    
    beforeEach(^{
        builder = BDMAuctionBuilder.new;
        request = BDMRequest.nullMock;
        targeting = BDMTargeting.nullMock;
        restriction = BDMUserRestrictions.nullMock;
        
        auctionSettingsMock = [KWMock nullMockForProtocol:@protocol(BDMAuctionSettings)];
        placementBuilderMock = [KWMock nullMockForProtocol:@protocol(BDMPlacementRequestBuilder)];
        placementMock = [ADCOMPlacement nullMock];
        
        [builder stub:@selector(auctionSettings) andReturn:auctionSettingsMock];
        [builder stub:@selector(placementBuilder) andReturn:placementBuilderMock];
        [builder stub:@selector(restrictions) andReturn:restriction];
        
        [request stub:@selector(targeting) andReturn:targeting];
        [auctionSettingsMock stub:@selector(auctionCurrency) andReturn:@"USD"];
        [auctionSettingsMock stub:@selector(tmax) andReturn:theValue(1)];
        [auctionSettingsMock stub:@selector(auctionType) andReturn:theValue(BDMAuctionTypeFirstPrice)];
        [placementBuilderMock stub:@selector(placement) andReturn:placementMock];
    });
    
    it(@"try append nullable model without exception", ^{
        builder.appendRequest(nil);
        builder.appendPlacementBuilder(nil);
    });
    it(@"should return valid message", ^{
        [auctionSettingsMock stub:@selector(protocolVersion) andReturn:@"blablabla"];
        [auctionSettingsMock stub:@selector(domainSpec) andReturn:@"blablabla"];
        [auctionSettingsMock stub:@selector(domainVersion) andReturn:@"blablabla"];
        
        ORTBOpenrtb * message = (ORTBOpenrtb *)builder.message;
        
        [[message.ver should] equal:auctionSettingsMock.protocolVersion];
        [[message.domainspec should] equal:auctionSettingsMock.domainSpec];
        [[message.domainver should] equal:auctionSettingsMock.domainVersion];
        
    });
    it(@"should be valid request item", ^{
        NSError *error = nil;
        builder.appendRequest(request);
        
        BDMPriceFloor *oneBid = BDMPriceFloor.nullMock;
        [oneBid stub:@selector(ID) andReturn:@"id"];
        [oneBid stub:@selector(value) andReturn:@1.1];
        [request stub:@selector(priceFloors) andReturn:@[oneBid]];
        
        ORTBOpenrtb * message = (ORTBOpenrtb *)builder.message;
        
        [[error should] beNil];
        ORTBRequest_Item * item = message.request.itemArray.firstObject;
        [[item shouldNot] beNil];
        
        [[item.id_p shouldNot] beNil];
        [[item.dealArray.firstObject.id_p should] equal:oneBid.ID];
        [[theValue(item.dealArray.firstObject.flr) should] equal:theValue(oneBid.value.doubleValue)];
    });
    it(@"should be valid placement", ^{
        NSError *error = nil;
        id placement = [KWMock nullMockForProtocol:@protocol(BDMPlacementRequestBuilder)];
        
        ADCOMPlacement *anyPlacement = [ADCOMPlacement message];
        [placement stub:@selector(placement) andReturn:anyPlacement];
        builder.appendPlacementBuilder(placement);
        
        ADCOMPlacement *adComPlacement = [ADCOMPlacement message];
        
        [[error should] beNil];
        [[adComPlacement shouldNot] beNil];
        [[adComPlacement should] equal:anyPlacement];
    });
    it(@"should be valid fields from request model", ^{
        NSError *error = nil;
        
        ORTBOpenrtb *rtb = (ORTBOpenrtb *)builder.message;
        
        [[error should] beNil];
        [[rtb.ver shouldNot] beNil];
        [[rtb.domainspec shouldNot] beNil];
        [[rtb.domainver shouldNot] beNil];
        [[theValue(rtb.request.tmax) should] equal:theValue(1)];
        [[theValue(rtb.request.at) should] equal:theValue(1)];
        [[rtb.request.curArray should] equal:@[@"USD"]];
    });
    it(@"should be valid restricted field from context", ^{
        NSError *error = nil;
        
        NSArray *bCat = @[@"cat"];
        NSArray *bAdv = @[@"adv"];
        NSArray *bApp = @[@"app"];
        
        [targeting stub:@selector(blockedCategories) andReturn:bCat];
        [targeting stub:@selector(blockedAdvertisers) andReturn:bAdv];
        [targeting stub:@selector(blockedApps) andReturn:bApp];
        
        builder.appendRequest(request);
        
        ORTBOpenrtb *rtb = (ORTBOpenrtb *)builder.message;
        ADCOMContext *context = [[ADCOMContext alloc] initWithData:rtb.request.context.value error:&error];
        
        [[error should] beNil];
        [[context shouldNot] beNil];
        
        [[context.restrictions.bcatArray should] equal:bCat];
        [[context.restrictions.badvArray should] equal:bAdv];
        [[context.restrictions.bappArray should] equal:bApp];
    });
    it(@"should be valid app messages from context", ^{
        NSError *error = nil;
        
        [targeting stub:@selector(storeId) andReturn:@"storeID"];
        [targeting stub:@selector(storeURL) andReturn:[NSURL URLWithString:@"http://url"]];
        [targeting stub:@selector(paid) andReturn:theValue(true)];
        
        builder.appendRequest(request);
        
        ORTBOpenrtb *rtb = (ORTBOpenrtb *)builder.message;
        ADCOMContext *context = [[ADCOMContext alloc] initWithData:rtb.request.context.value error:&error];
        
        [[error should] beNil];
        [[context shouldNot] beNil];
        
        [[context.app.storeid should] equal:@"storeID"];
        [[context.app.storeurl should] equal:@"http://url"];
        [[theValue(context.app.paid) should] beTrue];
    });
    it(@"should be valid device messages from context", ^{
        NSError *error = nil;
        
        builder.appendRequest(request);
        
        ORTBOpenrtb *rtb = (ORTBOpenrtb *)builder.message;
        ADCOMContext *context = [[ADCOMContext alloc] initWithData:rtb.request.context.value error:&error];
        
        [[error should] beNil];
        [[context shouldNot] beNil];
        
        [[theValue(context.device.type) should] equal:theValue(4)];
        [[context.device.ua shouldNot] beNil];
        [[theValue(context.device.lmt) should] beFalse];
        [[theValue(context.device.contype) should] equal:theValue(BDMTransformers.connectionType(ask_connectionTypeString()))];
        [[context.device.mccmnc shouldNot] beNil];
        [[context.device.carrier shouldNot] beNil];
        [[theValue(context.device.w) should] equal:theValue(UIScreen.mainScreen.bounds.size.width * UIScreen.mainScreen.scale)];
        [[theValue(context.device.h) should] equal:theValue(UIScreen.mainScreen.bounds.size.height * UIScreen.mainScreen.scale)];
        [[theValue(context.device.ppi) should] beGreaterThan:theValue(1.0)];
        [[theValue(context.device.pxratio) should] beGreaterThan:theValue(1.0)];
        [[theValue(context.device.os) should] equal:theValue(13)];
        [[context.device.osv shouldNot] beNil];
        [[context.device.hwv shouldNot] beNil];
        [[context.device.make shouldNot] beNil];
        [[context.device.model shouldNot] beNil];
        [[context.device.lang shouldNot] beNil];
        [[context.device.geo shouldNot] beNil];
        
        if (BDMSdk.sharedSdk.restrictions.subjectToGDPR && BDMSdk.sharedSdk.restrictions.consentString == nil) {
            [[context.device.ifa should] equal:@"00000000-0000-0000-0000-000000000000"];
        } else {
            [[context.device.ifa should] equal:ask_advertisingID()];
        }
    });
    context(@"user data", ^{
        
        beforeEach(^{
            [targeting stub:@selector(gender) andReturn:kBDMUserGenderFemale];
            [targeting stub:@selector(yearOfBirth) andReturn:@2018];
            [targeting stub:@selector(keywords) andReturn:@"one, two"];
            [targeting stub:@selector(userId) andReturn:@"userID"];
            [restriction stub:@selector(consentString) andReturn:@"restrict"];
            
            builder.appendRequest(request);
        });
        
        it(@"should be valid user messages from context // without coppa", ^{
            NSError * error;
            ORTBOpenrtb *rtb = (ORTBOpenrtb *)builder.message;
            ADCOMContext *context = [[ADCOMContext alloc] initWithData:rtb.request.context.value error:&error];
            
            [[error should] beNil];
            [[context shouldNot] beNil];
            
            [[context.user.gender should] equal:@"F"];
            [[theValue(context.user.yob) should] equal:theValue(2018)];
            [[context.user.keywords should] equal:@"one, two"];
            [[context.user.id_p should] equal:@"userID"];
            [[context.user.consent should] equal:@"restrict"];
        });
        
        it(@"should be valid user messages from context // with consent", ^{
            NSError *error = nil;
            
            [restriction stub:@selector(coppa) andReturn:theValue(YES)];
            
            ORTBOpenrtb *rtb = (ORTBOpenrtb *)builder.message;
            ADCOMContext *context = [[ADCOMContext alloc] initWithData:rtb.request.context.value error:&error];
            
            [[error should] beNil];
            [[context shouldNot] beNil];
            
            [[context.user.gender should] equal:@""];
            [[theValue(context.user.yob) should] equal:theValue(0)];
            [[context.user.keywords should] equal:@""];
            [[context.user.id_p should] equal:@""];
            [[context.user.consent should] equal:@"restrict"];
        });
    });
    
    it(@"should be valid regs messages from context", ^{
        NSError *error = nil;
        
        [restriction stub:@selector(coppa) andReturn:theValue(YES)];
        [restriction stub:@selector(subjectToGDPR) andReturn:theValue(YES)];
        
        builder.appendRequest(request);
        
        ORTBOpenrtb *rtb = (ORTBOpenrtb *)builder.message;
        ADCOMContext *context = [[ADCOMContext alloc] initWithData:rtb.request.context.value error:&error];
        
        [[error should] beNil];
        [[context shouldNot] beNil];
        
        [[theValue(context.regs.coppa) should] beTrue];
        [[theValue(context.regs.gdpr) should] beTrue];
    });
});

SPEC_END
