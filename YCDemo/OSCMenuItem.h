//
//  OSCMenuItem.h
//  iosapp
//
//  Created by Graphic-one on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "enumList.h"


typedef NS_ENUM(NSUInteger, InformationType)
{
    InformationTypeLinkNews = 0,//链接新闻
    InformationTypeSoftWare = 1,//软件推荐
    InformationTypeForum = 2,//讨论区帖子（问答）
    InformationTypeBlog = 3,//博客
    InformationTypeTranslation = 4,//翻译文章
    InformationTypeActivity = 5,//活动类型
    InformationTypeInfo = 6,//资讯
    
    InformationTypeUserCenter = 11,//用户中心
    
    InformationTypeTweet = 100//动弹（评论）类型
};

typedef NS_ENUM(NSInteger,OSCInformationListBannerType) {
    OSCInformationListBannerTypeNone = 0,//没有banner
    OSCInformationListBannerTypeSimple = 1,//通用banner (UIImageView显示图片 + UILabel显示title)
    OSCInformationListBannerTypeSimple_Blogs = 2,//自定义banner (用于blog列表展示)
    OSCInformationListBannerTypeCustom_Activity = 3,//自定义banner (用于activity列表展示)
};

@class OSCMenuItem_Banner;
@interface OSCMenuItem : NSObject

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, assign, getter=isFixed) BOOL fixed;

@property (nonatomic, assign, getter=isNeedLogin) BOOL needLogin;

@property (nonatomic, strong) NSString* tag;

@property (nonatomic, assign) InformationType type;

@property (nonatomic, strong) NSString* subtype;

@property (nonatomic, assign) NSInteger order;

@property (nonatomic, strong) NSString* href;

@property (nonatomic, strong) OSCMenuItem_Banner* banner;

@end


@interface OSCMenuItem_Banner : NSObject

@property (nonatomic, assign) OSCInformationListBannerType catalog;

@property (nonatomic, strong) NSString* href;

@end




/**
 {
    "token":"1a320f65e0de3f3d5e2b",
    "name":"栏目名称",
    "fixed":true,
    "needLogin":true,
    "tag":"hot",
    "type":1,
    "subtype":1,
    "order":2,
    "href":"https://www.oschina.net/action/apiv2/sub_list?token=1a320f65e0de3f3d5e2b",
    "banner":{
        "catalog":1,
        "href":"https://www.oschina.net/action/apiv2/banner?catalog=1"
    }
 }
 */
