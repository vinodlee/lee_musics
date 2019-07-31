#import "LeeMusicsPlugin.h"
#import <lee_musics/lee_musics-Swift.h>

@implementation LeeMusicsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLeeMusicsPlugin registerWithRegistrar:registrar];
}
@end
