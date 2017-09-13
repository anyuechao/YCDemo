//
//  Utils.h
//  YCDemo
//
//  Created by DJnet on 2017/8/28.
//  Copyright © 2017年 YueChao An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSCMenuItem.h"

@interface Utils : NSObject
+ (NSArray<NSString* >* )fixedLocalMenuNames;
+ (NSArray<NSString* >* )allSelectedMenuNames;
+ (void)updateUserSelectedMenuListWithMenuNames:(NSArray<NSString* >* )newUserMenuList_names;
+ (NSArray<NSString* >* )allUnselectedMenuNames;
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuNames:(NSArray<NSString* >* )menuNames;
@end
