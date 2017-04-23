/********* YswNavigation.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <CoreLocation/CLLocation.h>
#import <MapKit/MKMapItem.h>


@interface YswNavigation : CDVPlugin {
    // Member variables go here.
}

- (void)showNav:(CDVInvokedUrlCommand*)command;

@end

@implementation YswNavigation

- (void)showNav:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* params = [command.arguments objectAtIndex:0];

    if (params != nil) {
        int mapType = [[params objectForKey:@"mapType"] intValue];
        NSString *sname = [params objectForKey:@"sname"];
        double slat = [[params objectForKey:@"slat"] doubleValue];
        double slng = [[params objectForKey:@"slng"] doubleValue];
        NSString *dname = [params objectForKey:@"dname"];
        double dlat = [[params objectForKey :@"dlat"] doubleValue];
        double dlng = [[params objectForKey:@"dlng"] doubleValue];
        CLLocationCoordinate2D startLocation = CLLocationCoordinate2DMake(slat, slng);
        CLLocationCoordinate2D endLocation = CLLocationCoordinate2DMake(dlat, dlng);
        
        bool isAppInstalled = true;
        if(mapType == 1) {
            isAppInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
        } else if(mapType == 2) {
            isAppInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
        }
        
        if(isAppInstalled) {
            // 高德
            if(mapType == 1) {
                CLLocationCoordinate2D start = [self bdToGcj02: startLocation];
                CLLocationCoordinate2D end = [self bdToGcj02: endLocation];
                
                NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=com.yaoshangwang.com&poiname=%@&lat=%f&lon=%f&dev=0&style=2", @"药尚网", dname, end.latitude, end.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
            }
            // 百度
            else if(mapType == 2) {
                NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name=%@&destination=latlng:%f,%f|name=%@&mode=driving&src=com.yaoshangwang.yswapp", startLocation.latitude, startLocation.longitude, sname, endLocation.latitude, endLocation.longitude, dname] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
            }
            // 苹果
            else if(mapType == 0) {
                CLLocationCoordinate2D start = [self bdToGcj02: startLocation];
                CLLocationCoordinate2D end = [self bdToGcj02: endLocation];
                
                //MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
                MKMapItem *currentLoc = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:start addressDictionary:nil]];
                currentLoc.name = sname;
                MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:end addressDictionary:nil]];
                toLocation.name = dname;
                NSArray *items = @[currentLoc, toLocation];
                NSDictionary *dic = @{
                                      MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                                      MKLaunchOptionsShowsTrafficKey : @(YES)
                                      };
                [MKMapItem openMapsWithItems:items launchOptions:dic];
            }
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @""];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"false"];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (CLLocationCoordinate2D)bdToGcj02:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D resPoint;
    double PI = 3.14159265358979324 * 3000.0 / 180.0;
    double x = location.longitude - 0.0065, y = location.latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * PI);
    resPoint.latitude = z * sin(theta);
    resPoint.longitude =  z * cos(theta);;
    
    return resPoint;
}
@end
