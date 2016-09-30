/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic.h"
//#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK



@implementation Diagnostic

- (void)pluginInitialize {
    
    [super pluginInitialize];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
}

/*************
 * Plugin API
 *************/

// Location
- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([CLLocationManager locationServicesEnabled] && [self isLocationAuthorized]) {
            NSLog(@"Location is enabled.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            NSLog(@"Location is disabled.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isLocationEnabledSetting: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([CLLocationManager locationServicesEnabled]) {
            NSLog(@"Location Services is enabled");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            NSLog(@"Location Services is disabled");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isLocationAuthorized]) {
            NSLog(@"This app is authorized to use location.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        } else {
            NSLog(@"This app is not authorized to use location.");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status = [self getLocationAuthorizationStatusAsString:[CLLocationManager authorizationStatus]];
        NSLog([NSString stringWithFormat:@"Location authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)])
        {
            BOOL always = [[command argumentAtIndex:0] boolValue];
            if(always){
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationAlwaysUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationAlwaysUsageDescription in its Info.plist");
                [self.locationManager requestAlwaysAuthorization];
                NSLog(@"Requesting location authorization: always");
            }else{
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationWhenInUseUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationWhenInUseUsageDescription in its Info.plist");
                [self.locationManager requestWhenInUseAuthorization];
                NSLog(@"Requesting location authorization: when in use");
            }
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    self.locationRequestCallbackId = command.callbackId;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Camera
- (void) isCameraEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isCameraPresent] && [self isCameraAuthorized]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isCameraPresent: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isCameraPresent]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self isCameraAuthorized]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        NSString* status = @"unknown";
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == AVAuthorizationStatusAuthorized){
            status = @"authorized";
        }
        NSLog([NSString stringWithFormat:@"Camera authorization status is: %@", status]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            CDVPluginResult* pluginResult;
            if(granted){
                NSLog(@"Granted access to camera");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
            } else {
                NSLog(@"Not granted access to camera");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    @catch (NSException *exception) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command
{
}

- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
}

- (void) requestCameraRollAuthorization: (CDVInvokedUrlCommand*)command
{
}

// Wifi
- (void) isWifiEnabled: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if([self connectedToWifi]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Bluetooth
- (void) isBluetoothEnabled: (CDVInvokedUrlCommand*)command
{
}

- (void) getBluetoothState: (CDVInvokedUrlCommand*)command
{
    
}

// Settings
- (void) switchToSettings: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if (UIApplicationOpenSettingsURLString != nil && &UIApplicationOpenSettingsURLString != NULL){
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not supported below iOS 8"];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Audio
- (void) isMicrophoneAuthorized: (CDVInvokedUrlCommand*)command
{
}

- (void) getMicrophoneAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
}

- (void) requestMicrophoneAuthorization: (CDVInvokedUrlCommand*)command
{
}

// Remote (Push) Notifications
- (void) isRemoteNotificationsEnabled: (CDVInvokedUrlCommand*)command
{
}

- (void) getRemoteNotificationTypes: (CDVInvokedUrlCommand*)command
{
}

- (void) isRegisteredForRemoteNotifications: (CDVInvokedUrlCommand*)command
{
}

/*********************
 * Internal functions
 *********************/
- (void)jsCallback: (NSString*)jsString
{
    [self.commandDelegate evalJs:jsString];
}

- (NSString*) getLocationAuthorizationStatusAsString: (CLAuthorizationStatus)authStatus
{
    NSString* status = @"unknown";
    if(authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == kCLAuthorizationStatusNotDetermined){
        status = @"not_determined";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedAlways){
        status = @"authorized_always";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        status = @"authorized_when_in_use";
    }
    return status;
}

- (BOOL) isLocationAuthorized
{
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    if([status  isEqual: @"authorized_always"] || [status  isEqual: @"authorized_when_in_use"]) {
        return true;
    } else {
        return false;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)authStatus {
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    NSLog([NSString stringWithFormat:@"Location authorization status changed to: %@", status]);
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.locationRequestCallbackId];
    
    [self onLocationAuthorizationStatusChange:status]; // Deprecated
}


-(void)onLocationAuthorizationStatusChange:(NSString *)status __attribute__((deprecated))
{
    NSString* jsString = [NSString stringWithFormat:@"cordova.plugins.diagnostic._onLocationAuthorizationStatusChange(\"%@\");", status];
    [self jsCallback:jsString];
}

- (BOOL) isCameraPresent
{
    BOOL cameraAvailable =
    [UIImagePickerController
     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(cameraAvailable) {
        NSLog(@"Camera available");
        return true;
    }
    else {
        NSLog(@"Camera unavailable");
        return false;
    }
}

- (BOOL) isCameraAuthorized
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        return true;
    } else {
        return false;
    }
}

- (NSString*) getCameraRollAuthorizationStatus
{
    NSString* status = @"unknown";
    return status;
}

- (NSString*) getCameraRollAuthorizationStatusAsString: (PHAuthorizationStatus)authStatus
{
    NSString* status = @"unknown";
    return status;
}

- (BOOL) connectedToWifi  // Don't work on iOS Simulator, only in the device
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    
    if (getifaddrs(&addresses) != 0) {
        return NO;
    }
    
    cursor = addresses;
    while (cursor != NULL)  {
        if (cursor -> ifa_addr -> sa_family == AF_INET && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                
                NSLog(@"Wifi ON");
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    freeifaddrs(addresses);
    return wiFiAvailable;
}

- (NSString*) arrayToJsonString:(NSArray*)inputArray
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString*) objectToJsonString:(NSDictionary*)inputObject
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark - CBCentralManagerDelegate

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
}

@end
