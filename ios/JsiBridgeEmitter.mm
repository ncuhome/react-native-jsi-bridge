//
//  JsiBrigeEmitter.m
//  JsiBridge
//
//  Created by Sergei Golishnikov on 08/03/2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import "JsiBridgeEmitter.h"

@implementation CustomJsiBridgeEmitter

NSMutableDictionary<NSString*, CustomJsiBridgeCallback> *_nativeListeners;
__weak CustomJsiBridge *jsiBridge;

+ (CustomJsiBridgeEmitter*)shared {
    static CustomJsiBridgeEmitter *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (id)init {
    if (self = [super init]) {
        _nativeListeners = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)on:(NSString *)name with:(CustomJsiBridgeCallback)callback {
    [_nativeListeners setObject:callback forKey:name];
}

- (void)off:(NSString *)name {
    [_nativeListeners removeObjectForKey:name];
}

- (void)emit:(NSString *)name with:(id)data {
    if (jsiBridge) {
        [jsiBridge emitJs:name with:data];
    }
}

- (void)emitNative:(NSString *)name with:(id)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        CustomJsiBridgeCallback listener = [_nativeListeners objectForKey:name];
        if (listener) {
            @try {
                listener(data);
            }
            @catch (id err) {
#if DEBUG
                // 主要防止由于 js 层传入的参数类型与在 oc 中注册的不同，而导致的 crash
                NSString *str = [NSString stringWithFormat:@"[%@]: event error called", name];
                NSLog(@"%@", str);
#endif
            }
        };
    });
}

- (void)registerJsiBridge:(CustomJsiBridge *)bridge {
    jsiBridge = bridge;
}

@end
