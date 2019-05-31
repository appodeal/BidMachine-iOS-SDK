//
//  DSKVastCompanionView.m
//  OpenBids
//

//  Copyright © 2016 OpenBids, Inc. All rights reserved.
//

#import "DSKVASTCompanionView.h"
#import <ASKDiskUtils/ASKDataCacher.h>
#import <NexageSourceKitMRAID/SKMRAIDView.h>
#import <NexageSourceKitMRAID/SKMRAIDServiceDelegate.h>

#import "NSString+DSKExtensions.h"
#import "DSKThirdPartyEventTracker.h"

@interface DSKVASTCompanionView () <UIGestureRecognizerDelegate, SKMRAIDServiceDelegate, SKMRAIDViewDelegate>

@property (nonatomic, assign, getter=isFullscreen) BOOL fullscreen;

@property (nonatomic, strong) UIImage * localStaticImage;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSURL * contentURL;

@property (nonatomic, strong) DSKVASTCompanion * companion;
@property (nonatomic, assign, readwrite) DSKVASTAspectRatio aspectRatio;

@property (nonatomic, strong) SKMRAIDView * mraidView;

@property (nonatomic, weak) UIViewController * rootViewController;

@end

@implementation DSKVASTCompanionView

#pragma mark - Life cicle

- (instancetype) initWithCompanion:(DSKVASTCompanion *)companion
                        fullscreen:(BOOL)fullscreen
                rootViewController:(UIViewController *)controller{
    
    return [self initWithCompanion:companion
                       staticImage:nil
            fullscreen:fullscreen
                rootViewController:controller
                       aspectRatio:companion.aspectRatio];
}

- (instancetype) initWithStaticImage:(UIImage *)staticImage
                          fullscreen:(BOOL)fullscreen
                  rootViewController:(UIViewController *)controller
                         aspectRatio:(DSKVASTAspectRatio)aspectRatio{
    
    return [self initWithCompanion:nil
                       staticImage:staticImage
                        fullscreen:fullscreen
                rootViewController:controller
                       aspectRatio:aspectRatio];
}

- (instancetype) initWithCompanion:(DSKVASTCompanion *)companion
                       staticImage:(UIImage *)staticImage
                        fullscreen:(BOOL)fullscreen
                rootViewController:(UIViewController *)controller
                       aspectRatio:(DSKVASTAspectRatio)aspectRatio{
    
    self = [super initWithFrame: CGRectMake(0, 0, companion.width, companion.heigth)];
    self.rootViewController = controller;
    self.fullscreen = fullscreen;
    
    if (self && companion){
        self.companion = companion;
        self.aspectRatio = companion.aspectRatio;
       
        switch (companion.type) {
            case    DSKVASTCompanionTypeStatic:    [self configureForStatic];      break;
            case    DSKVASTCompanionTypeHTML:      [self configureForHtml];        break;
            case    DSKVASTCompanionTypeIFrame:    [self configureForIframe];      break;
            default: break;
        }
    } else if (self && staticImage) {
        self.localStaticImage = staticImage;
        self.aspectRatio = aspectRatio;
        
        [self configureForLocalStatic];
    } else if (self) {
        self.backgroundColor = UIColor.whiteColor;
    }
    
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [DSKThirdPartyEventTracker sendTrackingEvents: [self.companion creativeViewTrackingURLs]];
}

#pragma mark - Create instance

+ (DSKVASTCompanionView *)extentionCompanionFromCompanion:(DSKVASTCompanion *)companion
                                 rootViewController:(UIViewController *)controller{
    
    if (companion) {
        DSKVASTCompanionView* bannerView = [[DSKVASTCompanionView alloc] initWithCompanion:companion fullscreen:NO rootViewController:controller];
        return bannerView;
    }
    return nil;
}

+ (DSKVASTCompanionView *) bannerCompanionFromArray:(NSArray *)companionArray
                                 rootViewController:(UIViewController *)controller{
    
    for (DSKVASTCompanion* companion in companionArray) {
        if (companion.aspectRatio == DSKVASTAspectRatioBanner){
            DSKVASTCompanionView* bannerView = [[DSKVASTCompanionView alloc] initWithCompanion:companion fullscreen:NO rootViewController:controller];
            return bannerView;
        }
    }
    
    return nil;
}

+ (DSKVASTCompanionView *)companionViewFromArray:(NSArray *)companions rootViewController:(UIViewController *)controller aspectRatio:(DSKVASTAspectRatio)aspectRatio {
    if (![companions count]) {
        return nil;
    }
    
    DSKVASTCompanion * companion = [self searchCompanion:nil companions:companions aspectRatio:aspectRatio score:0 idx:0];
    return [[DSKVASTCompanionView alloc] initWithCompanion:companion fullscreen:YES rootViewController:controller];
}

+ (DSKVASTCompanionView *)companionViewFromImage:(UIImage *)staticImage rootViewController:(UIViewController *)controller aspectRatio:(DSKVASTAspectRatio)aspectRatio {
    return [[DSKVASTCompanionView alloc] initWithStaticImage:staticImage fullscreen:YES rootViewController:controller aspectRatio:aspectRatio];
}

#pragma mark - Instance extention

+ (DSKVASTCompanion *)searchCompanion:(DSKVASTCompanion *)currentCompanion companions:(NSArray *)companions aspectRatio:(DSKVASTAspectRatio)aspectRatio score:(NSUInteger)score idx:(NSInteger)idx{
    if ((idx + 1) > [companions count]) {
        return currentCompanion;
    }
    
    DSKVASTCompanion * companion = companions[idx];
    
    CGSize currentSize = [self transformedCurrentSizeFromRatio:aspectRatio];
    
    CGFloat scaleNext = ABS((companion.width / currentSize.width + companion.heigth / currentSize.height) / 2 - 1);
    CGFloat scalePrev = ABS((currentCompanion.width / currentSize.width + currentCompanion.heigth / currentSize.height) / 2 - 1);
    
    NSUInteger a = currentCompanion.aspectRatio != companion.aspectRatio && currentCompanion.aspectRatio != aspectRatio  ? 1 << 0 : 0;
    NSUInteger b = currentCompanion.aspectRatio != companion.aspectRatio && companion.aspectRatio == aspectRatio  ? 1 << 1 : 0;
    NSUInteger c = currentCompanion.aspectRatio == companion.aspectRatio && (scaleNext <= scalePrev) ? 1 << 2 : 0;
    NSUInteger d = aspectRatio == DSKVASTAspectRatioUnknown && (scaleNext <= scalePrev) ? 1 << 3 : 0;
    
    //if remove d parameter, then unknown orientation win, now win current postbanner with current size
    NSUInteger maxScore = a | b | c | d;
    
    return [self searchCompanion:(maxScore >= score) ? companion : currentCompanion
                      companions:companions
                     aspectRatio:aspectRatio
                           score:MAX(maxScore, score)
                             idx:(idx + 1)];
}

+ (CGSize)transformedCurrentSizeFromRatio:(DSKVASTAspectRatio)ratio{
    CGSize currentSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxLength = MAX(currentSize.width, currentSize.height);
    CGFloat minLenght = MIN(currentSize.width, currentSize.height);
    
    switch (ratio) {
        case DSKVASTAspectRatioLandscape:   currentSize = CGSizeMake(maxLength, minLenght); break;
        case DSKVASTAspectRatioPortrait:    currentSize = CGSizeMake(minLenght, maxLength); break;
        default: break;
    }
    return currentSize;
}

#pragma mark - Public

- (void)load{
    if (self.content) {
        [self.mraidView loadAdHTML:self.content];
    } else if (self.contentURL) {
        [self.mraidView preloadAdFromURL:self.contentURL];
    }
}

- (void)show {
    [self addMraidViewOnView:self.mraidView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.alpha = 1.0f;
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.mraidView setIsViewable:YES];
    }];
}

- (void)hide {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.alpha = 0.0f;
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.mraidView setIsViewable:NO];
    }];
}

- (void)sendImpression {
    //TODO: NO - OP
}

#pragma mark - Private

- (void)configureForStatic {
    UIImageView * staticView = [[UIImageView alloc] initWithFrame:self.frame];
    //TODO CONSTRAINTS
    //[staticView DSK_setImageFromURL:[NSURL URLWithString:self.companion.data]];
    [self addSubview:staticView];
//    [staticView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
    staticView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(staticCompanionTap)];
    [staticView addGestureRecognizer:tapGesture];
    
    [self addImageViewOnView:staticView isLocal:NO];
}

- (void)configureForLocalStatic{
    UIImageView* staticView = [[UIImageView alloc] initWithImage:self.localStaticImage];
    [self addImageViewOnView:staticView isLocal:YES];
}

- (void)configureForHtml {
    NSString * urlString = [self.companion.data DSK_clearParseString];
    if ([self isHTMLUrl:urlString]) {
        [self makeMRAIDViewWithURL:urlString];
    } else {
        [self makeMRAIDViewWithHTML:self.companion.data];
    }
}

- (void)configureForIframe {
    NSString* html = [NSString stringWithFormat:@"<IFRAME> src = \"%@\" frameborder=none </IRAME>", self.companion.data];
    [self makeMRAIDViewWithHTML:html];
}

- (BOOL)isHTMLUrl:(NSString *)html{
    return html && [NSURL URLWithString:html];
}

- (void)makeMRAIDViewWithURL:(NSString *)url{
    [self makeDefaultMraidView];
    self.contentURL = [NSURL URLWithString:url];
    
}

- (void) makeMRAIDViewWithHTML:(NSString *)html {
    [self makeDefaultMraidView];
    self.content = html;
}

- (void)makeDefaultMraidView{
    @try {
        
        NSArray *mraidFeatures = @[MRAIDSupportsTel,MRAIDSupportsCalendar, MRAIDSupportsSMS, MRAIDSupportsInlineVideo, MRAIDSupportsStorePicture];
        self.mraidView = [[SKMRAIDView alloc] initWithFrame:(CGRect){.size = self.frame.size}
                            asInterstitial:self.fullscreen
                         supportedFeatures:mraidFeatures
                                  delegate:self
                           serviceDelegate:self
                             customScripts:nil
                        rootViewController:self.rootViewController];
    }
    @catch (NSException *exception) {
        if ([self.delegate respondsToSelector:@selector(mraidCompanionDidFailToLoad:)]) {
            [self.delegate mraidCompanionDidFailToLoad:self];
        }
    }
}

- (void)addMraidViewOnView:(SKMRAIDView *)mraidView{
    if (mraidView.superview == self) return;

    [self addSubview:mraidView];
    //TODO CONSTRAINTS
//    [mraidView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
}

- (void)addImageViewOnView:(UIImageView *)imageView isLocal:(BOOL)isLocal{
    [self addSubview:imageView];
    //TODO CONSTRAINTS
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
    
    imageView.userInteractionEnabled = YES;
    
    SEL selector = isLocal ? @selector(localStaticCompanionTap) : @selector(staticCompanionTap);
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [imageView addGestureRecognizer:tapGesture];
}

#pragma mark - Action

- (void)staticCompanionTap {
    [DSKThirdPartyEventTracker sendTrackingEvents:[self.companion clickTrackingURLs]];
    if ([self.companion clickThroughURL] && [self.delegate respondsToSelector:@selector(companionViewDidReciveTap:destanationURL:)]) {
        [self.delegate companionViewDidReciveTap:self destanationURL:[self.companion clickThroughURL]];
    }
}

- (void)localStaticCompanionTap {
    if ([self.delegate respondsToSelector:@selector(staticCompanionViewDidReciveTap:)]) {
        [self.delegate staticCompanionViewDidReciveTap:self];
    }
}

#pragma mark - SKMRAIDViewDelegate

- (void)mraidView:(SKMRAIDView *)mraidView preloadedAd:(NSString *)preloadedAd{
    self.content = preloadedAd;
    [mraidView loadAdHTML:preloadedAd];
}

- (void)mraidView:(SKMRAIDView *)mraidView didFailToPreloadAd:(NSError *)preloadError{
    if ([self.delegate respondsToSelector:@selector(mraidCompanionDidFailToLoad:)]) {
        [self.delegate mraidCompanionDidFailToLoad:self];
    }
}

- (void)mraidViewAdReady:(SKMRAIDView *)mraidView{
    if ([self.delegate respondsToSelector:@selector(mraidCompanionViewDidLoad:)]) {
        [self.delegate mraidCompanionViewDidLoad:self];
    }
}

- (void)mraidView:(SKMRAIDView *)mraidView failToLoadAdThrowError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(mraidCompanionDidFailToLoad:)]) {
        [self.delegate mraidCompanionDidFailToLoad:self];
    }
}

- (void)mraidViewWillExpand:(SKMRAIDView *)mraidView{
    
}

- (void)mraidViewDidClose:(SKMRAIDView *)mraidView{
    if ([self.delegate respondsToSelector:@selector(mraidCompanionViewDidDismiss:)]) {
        [self.delegate mraidCompanionViewDidDismiss:self];
    }
}

- (void)mraidViewNavigate:(SKMRAIDView *)mraidView withURL:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(companionViewDidReciveTap:destanationURL:)]) {
        [self.delegate companionViewDidReciveTap:self destanationURL:url];
    }
}

- (void)mraidView:(SKMRAIDView *)mraidView useCustomClose:(BOOL)customClose{
    if ([self.delegate respondsToSelector:@selector(mraidCompanion:useCustomClose:)]) {
        [self.delegate mraidCompanion:self useCustomClose:customClose];
    }
}


@end
