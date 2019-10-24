#import "MapLauncherPlugin.h"
#import <map_launcher/map_launcher-Swift.h>

@implementation MapLauncherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMapLauncherPlugin registerWithRegistrar:registrar];
}
@end
