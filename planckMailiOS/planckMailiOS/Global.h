//
//  Global.h
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#ifndef planckMailiOS_Global_h
#define planckMailiOS_Global_h

#define SLOG(_str_) NSLog(@"fast log %@", _str_)

#define LLLOG(_longlong_) NSLog(@"fast ll log %lli", _longlong_)

#define STRING_FROM_DATA(_data_) [[NSString alloc] initWithData:_data_ encoding:NSUTF8StringEncoding]

#define TRIM_STRING(_string_) [ _string_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

#define KEYBOARD_HEIGHT_OFFSET  (([UIScreen mainScreen].bounds.size.height < 568.0f) ? 175.0f : 90.0f)

//save to userdefauls
#define SAVE_VALUE(obj,key)[[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];
#define GET_VALUE(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define BUNDLE_VERSION @"CFBundleVersion"

#define safeStringWithKey(key, object) ([NSNull null] != [object objectForKey:key] && [object objectForKey:key] != nil) ? [NSString stringWithFormat:@"%@",[object objectForKey:key]] : @""

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define STORYBOARD [UIStoryboard storyboardWithName:@"Main" bundle:nil]

//debug log
#ifdef DEBUG
# define DLog(...) NSLog(__VA_ARGS__)
#else
# define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)

#define WSELF   __weak typeof(self) wself = self

#endif
//---
