//
//  AWSAppleSignInProvider.m
//  AWSAuthCore
//
//  Created by Roy, Jithin on 6/28/20.
//  Copyright © 2020 Amazon Web Services. All rights reserved.
//

#import "AWSAppleSignInProvider.h"
#import<AuthenticationServices/AuthenticationServices.h>

@interface AWSAppleSignInProvider()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@property (strong, nonatomic) UIViewController *signInViewController;

@end

@implementation AWSAppleSignInProvider

+ (instancetype)sharedInstance {
    static AWSAppleSignInProvider *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AWSAppleSignInProvider alloc] init];
    });
    return _sharedInstance;
}

- (void)setViewControllerForAppleSignIn:(UIViewController *)signInViewController {
    self.signInViewController = signInViewController;
}

#pragma mark - AWSIdentityProvider

- (NSString *)identityProviderName {
    return AWSIdentityProviderApple;
}

- (AWSTask<NSString *> *)token {

    return nil;

}

#pragma mark - AWSSignInProvider

- (BOOL)isLoggedIn {
    return NO;
}

- (void)login:(void (^)(id _Nullable result, NSError * _Nullable error))completionHandler {
    if (@available(iOS 13, *)) {
        [self appleLogin:completionHandler];
    } else {
        // Fallback on earlier versions
    }
}


- (void)appleLogin:(void (^)(id _Nullable result, NSError * _Nullable error))completionHandler API_AVAILABLE(ios(13)){
    if (@available(iOS 13.0, *)) {

        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        controller.delegate = self;
        controller.presentationContextProvider = self;
        [controller performRequests];
    }


}

- (void)logout {

}

- (void)reloadSession {

}

#pragma mark -

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)){

    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", controller);
    NSLog(@"%@", authorization);

    NSLog(@"authorization.credential：%@", authorization.credential);

}


- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0)){

    NSLog(@"%s", __FUNCTION__);
    NSLog(@"error ：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"ASAuthorizationErrorCanceled";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"ASAuthorizationErrorFailed";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"ASAuthorizationErrorInvalidResponse";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"ASAuthorizationErrorNotHandled";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"ASAuthorizationErrorUnknown";
            break;
    }


    NSLog(@"controller requests：%@", controller.authorizationRequests);
}

 - (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
     return self.signInViewController.view.window;
}

@end
