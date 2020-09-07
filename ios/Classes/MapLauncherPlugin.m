#import "MapLauncherPlugin.h"

#if __has_include(<map_launcher/map_launcher-Swift.h>)
#import <map_launcher/map_launcher-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "map_launcher-Swift.h"
#endif

@implementation MapLauncherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMapLauncherPlugin registerWithRegistrar:registrar];
}
@end
