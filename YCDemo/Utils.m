//
//  Utils.m
//  YCDemo
//
//  Created by DJnet on 2017/8/28.
//  Copyright © 2017年 YueChao An. All rights reserved.
//

#import "Utils.h"
#import "OSCMenuItem.h"
#import "OSCModelHandler.h"

/** 根据此Key取得的是已选的menuItem的Token数组 */
#define kUserDefaults_ChooseMenus   @"UserDefaultsChooseMenus"
#define kUserDefaults_AppVersion    @"UserDefaultsAppVersion"

/** AppToken 通过请求头传递 */
#define Application_BundleID [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleIdentifier"]
#define Application_BuildNumber [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleVersion"]
#define Application_Version [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleShortVersionString"]

/* debug和release设置 */
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif

@implementation Utils
/** 定制化分栏*/
///获取全部本固定的 menuNames && meunTokens
+ (NSArray<NSString* >* )fixedLocalMenuNames{
    NSArray<NSString* >* fixedLocalTokens = [self fixedLocalMenuTokens];
    NSArray<OSCMenuItem* >* fixedLocalItems = [self conversionMenuItemsWithMenuTokens:fixedLocalTokens];
    NSArray<NSString* >* fixedLocalNames = [self conversionMenuNamesWithMenuItems:fixedLocalItems];
    return fixedLocalNames;
}
+ (NSArray<NSString* >* )fixedLocalMenuTokens{
    NSArray* fixedLocalTokens = @[
                                  //fixed
                                  @"d6112fa662bc4bf21084670a857fbd20",//开源资讯
                                  @"df985be3c5d5449f8dfb47e06e098ef9",//推荐博客
                                  @"98d04eb58a1d12b75d254deecbc83790",//技术问答
                                  @"1abf09a23a87442184c2f9bf9dc29e35",//每日一搏
                                  ];
    return fixedLocalTokens;
}

+ (NSArray<OSCMenuItem* >* )allLocalMenuItems{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"subMenuItems.plist" ofType:nil];
    NSArray* localMenusArr = [NSArray arrayWithContentsOfFile:filePath];
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:localMenusArr];
    return meunItems;
}

///获取全部本地的 menuNames && meunTokens
+ (NSArray<NSString* >* )allLocalMenuNames{
    NSArray* meunItems = [self allLocalMenuItems];
    NSMutableArray* allNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in meunItems) {
        [allNames addObject:curItem.name];
    }
    return allNames.copy;
}
+ (NSArray<NSString* >* )allLocalMenuTokens{
    NSArray* meunItems = [self allLocalMenuItems];
    NSMutableArray* allTokens = @[].mutableCopy;
    for (OSCMenuItem* curItem in meunItems) {
        [allTokens addObject:curItem.token];
    }
    return allTokens.copy;
}

///获取全部已选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allSelectedMenuNames{
    NSArray* chooseItemTokens = [self allSelectedMenuTokens];
    NSArray<OSCMenuItem* >* allChooseMenuItems = [self conversionMenuItemsWithMenuTokens:chooseItemTokens];
    NSMutableArray* allNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in allChooseMenuItems) {
        [allNames addObject:curItem.name];
    }
    return allNames.copy;
}
+ (NSArray<NSString* >* )allSelectedMenuTokens{
    NSMutableArray* mutableChooseItemTokens = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaults_ChooseMenus].mutableCopy;
    NSArray<NSString* >* allTokens = [self allLocalMenuTokens];
    if (!mutableChooseItemTokens || mutableChooseItemTokens.count == 0) {
        mutableChooseItemTokens = [self getNomalSelectedMenuItemTokens].mutableCopy;
        [self updateUserSelectedMenuListWithMenuTokens:mutableChooseItemTokens.copy];
    }
    NSMutableArray* deleteFixedLocalTokens = [NSMutableArray arrayWithCapacity:mutableChooseItemTokens.count];
    NSArray<NSString* >* fixedLocalTokens = [self fixedLocalMenuTokens];
    for (NSString* menuToken in mutableChooseItemTokens) {/** 去除fixed分栏 */
        if (![fixedLocalTokens containsObject:menuToken]) {
            [deleteFixedLocalTokens addObject:menuToken];
        }
    }
    mutableChooseItemTokens = deleteFixedLocalTokens;
    NSMutableArray* resultMuatbleArray = [NSMutableArray arrayWithCapacity:mutableChooseItemTokens.count];
    for (NSString* menuToken in mutableChooseItemTokens) {/** 去除不合法分栏 */
        if ([allTokens containsObject:menuToken]) {
            [resultMuatbleArray addObject:menuToken];
        }
    }
    mutableChooseItemTokens = resultMuatbleArray;
    [self updateUserSelectedMenuListWithMenuTokens:mutableChooseItemTokens.copy];
    return mutableChooseItemTokens.copy;
}

///获取全部未选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allUnselectedMenuNames{
    NSArray<NSString* >* allUnselectedMenuTokens = [self allUnselectedMenuTokens];
    NSArray<OSCMenuItem* >* allUnselectedMenuItems = [self conversionMenuItemsWithMenuTokens:allUnselectedMenuTokens];
    allUnselectedMenuItems = [self sortTransformation:allUnselectedMenuItems];
    NSMutableArray* allUnselectedNames = @[].mutableCopy;
    for (OSCMenuItem* curMenuItem in allUnselectedMenuItems) {
        [allUnselectedNames addObject:curMenuItem.name];
    }
    return allUnselectedNames.copy;
}
+ (NSArray<NSString* >* )allUnselectedMenuTokens{
    NSArray* allTokens = [self allLocalMenuTokens];
    NSArray* allSelectedMenuTokens = [self allSelectedMenuTokens];
    
    NSMutableArray* unselectedTokens = @[].mutableCopy;
    for (NSString* curToken in allTokens) {
        if (![allSelectedMenuTokens containsObject:curToken]) {
            [unselectedTokens addObject:curToken];
        }
    }
    NSMutableArray* deleteFixedLocalTokens = [NSMutableArray arrayWithCapacity:unselectedTokens.count];
    NSArray<NSString* >* fixedLocalTokens = [self fixedLocalMenuTokens];
    for (NSString* menuToken in unselectedTokens) {/** 去除fixed分栏 */
        if (![fixedLocalTokens containsObject:menuToken]) {
            [deleteFixedLocalTokens addObject:menuToken];
        }
    }
    unselectedTokens = deleteFixedLocalTokens;
    
    return unselectedTokens.copy;
}
/** name token item 相互转换*/
///用name转换成具体menuItem
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuNames:(NSArray<NSString* >* )menuNames{
    NSArray<OSCMenuItem* >* allMeunItems = [self allLocalMenuItems];
    NSMutableArray* conversionMenuItem = @[].mutableCopy;
    //    for (OSCMenuItem* curMenuItem in allMeunItems) {
    //        if ([menuNames containsObject:curMenuItem.name]) {
    //            [conversionMenuItem addObject:curMenuItem];
    //        }
    //        if (conversionMenuItem.count == menuNames.count) {
    //            return conversionMenuItem.copy;
    //        }
    //    }
    NSMutableArray *allName = [NSMutableArray array];
    for(OSCMenuItem* curMenuItem in allMeunItems){
        [allName addObject:curMenuItem.name];
    }
    for (NSString *name in menuNames) {
        NSInteger index = [allName indexOfObject:name];
        OSCMenuItem *item = allMeunItems[index];
        [conversionMenuItem addObject:item];
    }
    return conversionMenuItem.copy;
}
///用token转换成具体menuItem
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuTokens:(NSArray<NSString* >* )menuTokens{
    NSArray<OSCMenuItem* >* allMeunItems = [self allLocalMenuItems];
    NSMutableArray* conversionMenuItem = @[].mutableCopy;
    //    for (OSCMenuItem* curMenuItem in allMeunItems) {
    //        if ([menuTokens containsObject:curMenuItem.token]) {
    //            [conversionMenuItem addObject:curMenuItem];
    //        }
    //        if (conversionMenuItem.count == menuTokens.count) {
    //            return conversionMenuItem.copy;
    //        }
    //    }
    NSMutableArray *allToken = [NSMutableArray array];
    for(OSCMenuItem* curMenuItem in allMeunItems){
        [allToken addObject:curMenuItem.token];
    }
    for (NSString *token in menuTokens) {
        NSInteger index = [allToken indexOfObject:token];
        OSCMenuItem *item = allMeunItems[index];
        [conversionMenuItem addObject:item];
    }
    return conversionMenuItem.copy;
}
///用menuItem转换成token
+ (NSArray<NSString* >* )conversionMenuTokensWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems{
    NSMutableArray* meunTokens = @[].mutableCopy;
    for (OSCMenuItem* menuItem in menuItems) {
        [meunTokens addObject:menuItem.token];
    }
    return meunTokens.copy;
}
///用menuItem转换成name
+ (NSArray<NSString* >* )conversionMenuNamesWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems{
    NSMutableArray* meunNames = @[].mutableCopy;
    for (OSCMenuItem* menuItem in menuItems) {
        [meunNames addObject:menuItem.name];
    }
    return meunNames.copy;
}


///更新本地plist表(含全部分栏信息)
+ (void)updateLocalMenuList{
    /**
     NSString* requestURL = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_INFORMATION_SUB_ENUM];
     
     AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
     [manger GET:requestURL
     parameters:nil
     success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
     if ([responseObject[@"code"] integerValue] == 1) {
     
     }
     }
     failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
     NSLog(@"%@",error);
     }];
     */
}
+ (void)usingLocatMenuListUpdateUserMenuList{
    NSArray<NSString* >* allSelectedMenuTokens = [self allSelectedMenuTokens];
    NSArray<NSString* >* allLocalMenuTokens = [self allLocalMenuTokens];
    NSMutableArray* updateUserList = @[].mutableCopy;
    for (NSString* curToken in allSelectedMenuTokens) {
        if ([allLocalMenuTokens containsObject:curToken]) {
            [updateUserList addObject:curToken];
        }
    }
    [self updateUserSelectedMenuListWithMenuTokens:updateUserList.copy];
}
///更新UserSelectedMeunList(包含用户选中的分栏信息)
+ (void)updateUserSelectedMenuListWithMenuItems:(NSArray<OSCMenuItem* >* )newUserMenuList_items{
    NSArray<NSString* >* menuTokens = [self conversionMenuTokensWithMenuItems:newUserMenuList_items];
    [self updateUserSelectedMenuListWithMenuTokens:menuTokens];
}
+ (void)updateUserSelectedMenuListWithMenuTokens:(NSArray<NSString* >* )newUserMenuList_tokens{
    [[NSUserDefaults standardUserDefaults] setObject:newUserMenuList_tokens forKey:kUserDefaults_ChooseMenus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)updateUserSelectedMenuListWithMenuNames:(NSArray<NSString* >* )newUserMenuList_names{
    NSArray<OSCMenuItem* >* menuItems = [self conversionMenuItemsWithMenuNames:newUserMenuList_names];
    NSArray<NSString* >* menuTokens = [self conversionMenuTokensWithMenuItems:menuItems];
    [self updateUserSelectedMenuListWithMenuTokens:menuTokens];
}


+ (NSArray<NSString* >* )getNomalSelectedMenuItemTokens{
    NSArray* nomalToken = [self fixedLocalMenuTokens];
    return nomalToken;
}

///根据item的order进行排序
+ (NSArray<OSCMenuItem* >* )sortTransformation:(NSArray<OSCMenuItem* >* )items{
    NSMutableArray<OSCMenuItem* >* sortMutableArray = [NSMutableArray arrayWithCapacity:items.count];
    
    /**test
     NSMutableArray<NSNumber* >* orderArray = @[].mutableCopy;
     for (OSCMenuItem* item in items) {
     [orderArray addObject:@(item.order)];
     }
     NSLog(@"%@",orderArray);
     */
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    sortMutableArray = [items sortedArrayUsingDescriptors:@[sortDescriptor]].copy;
    
    /**
     for (OSCMenuItem* item in sortMutableArray) {
     [orderArray addObject:@(item.order)];
     }
     NSLog(@"%@",orderArray);
     */
    
    return sortMutableArray;
}

/** 过渡版分栏读写接口*/
+ (NSString* )originMenuFilePath{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_original.json" ofType:nil];
    return filePath;
}
+ (NSString* )activeMenuItemFilePath{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_active.json" ofType:nil];
    return filePath;
}
+ (NSArray<OSCMenuItem* >* )getOriginMenuItem{//获取全部分栏信息
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_original.json" ofType:nil];
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
    id localMenusArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:localMenusArr];
    return meunItems;
}
+ (NSArray<NSString* >* )getOriginMenuItemNames{
    NSArray<OSCMenuItem* >* originItems = [self getOriginMenuItem];
    
    NSMutableArray* originNames = @[].mutableCopy;
    for (OSCMenuItem* meunItem in originItems) {
        [originNames addObject:meunItem.name];
    }
    return originNames.copy;
}
+ (NSArray<OSCMenuItem* >* )getActiveMenuItem{//获取用户选择分栏信息
    NSArray* chooseMenus = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaults_ChooseMenus];
    if (chooseMenus.count == 0 || !chooseMenus) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_active.json" ofType:nil];
        NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
        chooseMenus = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    }
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:chooseMenus];
    return meunItems;
}

+ (NSArray<NSString* >* )allSelected_MenuNames{
    NSArray<OSCMenuItem* >* activeMenuItems = [self getActiveMenuItem];
    NSMutableArray* allSelected_MenuNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in activeMenuItems) {
        [allSelected_MenuNames addObject:curItem.name];
    }
    return allSelected_MenuNames.copy;
}

+ (NSArray<NSString* >* )allUnselected_MenuNames{
    NSArray<OSCMenuItem* >* originMenuItems = [self getOriginMenuItem];
    NSArray<OSCMenuItem* >* activeMenuItems = [self getActiveMenuItem];
    
    NSMutableArray<OSCMenuItem* >* allUnselected_MenuItems = @[].mutableCopy;
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < activeMenuItems.count; i++) {
        [nameArray addObject:activeMenuItems[i].name];
    }
    
    for (OSCMenuItem* curItem in originMenuItems) {
        if (![nameArray containsObject:curItem.name]) {
            [allUnselected_MenuItems addObject:curItem];
        }
    }
    
    //    NSArray<OSCMenuItem* >* allUnselected_Sort_MenuItems = [self sortTransformation:allUnselected_MenuItems.copy];
    NSArray<OSCMenuItem* >* allUnselected_Sort_MenuItems = allUnselected_MenuItems.copy;
    
    
    NSMutableArray<NSString* >* allUnselected_MenuNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in allUnselected_Sort_MenuItems) {
        [allUnselected_MenuNames addObject:curItem.name];
    }
    
    return allUnselected_MenuNames.copy;
}

+ (void)updateUserSelectedMenuList_With_MenuNames:(NSArray<NSString* >* )newUserMenuList_names{
    NSArray<OSCMenuItem* >* allOriginItems = [self getOriginMenuItem];
    NSArray<NSString* >* allOriginItemNames = [self getOriginMenuItemNames];
    
    NSMutableArray<OSCMenuItem* >* userSelectedArr = @[].mutableCopy;
    for (NSString* curItemName in newUserMenuList_names) {
        for (NSString* curOriginItemName in allOriginItemNames) {
            if ([curItemName isEqualToString:curOriginItemName]) {
                NSInteger index = [allOriginItemNames indexOfObject:curOriginItemName];
                OSCMenuItem* indexItem = [allOriginItems objectAtIndex:index];
                [userSelectedArr addObject:indexItem];
            }
        }
    }
    
    NSMutableArray* mstableDicArr = [NSMutableArray arrayWithCapacity:userSelectedArr.count];
    for (OSCMenuItem* menuItem in userSelectedArr.copy) {
        [mstableDicArr addObject:[menuItem osc_modelToJSONObject]];
    }
    
    NSArray* dicArray = mstableDicArr.copy;
    [[NSUserDefaults standardUserDefaults] setObject:dicArray forKey:kUserDefaults_ChooseMenus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray<OSCMenuItem* >* )conversionMenuItems_With_MenuNames:(NSArray<NSString* >* )menuNames{
    NSArray<OSCMenuItem* >* originMenuItem = [self getOriginMenuItem];
    NSArray<NSString* >* originMenuName = [self getOriginMenuItemNames];
    
    NSMutableArray<OSCMenuItem* >* conversionMenuItems = @[].mutableCopy;
    for (NSString* curName in menuNames) {
        for (NSString* originName in originMenuName) {
            if ([curName isEqualToString:originName]) {
                NSInteger index = [originMenuName indexOfObject:originName];
                OSCMenuItem* indexItem = [originMenuItem objectAtIndex:index];
                [conversionMenuItems addObject:indexItem];
            }
        }
    }
    return conversionMenuItems.copy;
}

@end
