//
//  DBHAllInformationModelData.m
//
//  Created by   on 2017/11/17
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "DBHAllInformationModelData.h"


NSString *const kDBHAllInformationModelDataAuthor = @"author";
NSString *const kDBHAllInformationModelDataContent = @"content";
NSString *const kDBHAllInformationModelDataStyle = @"style";
NSString *const kDBHAllInformationModelDataStatus = @"status";
NSString *const kDBHAllInformationModelDataClickRate = @"click_rate";
NSString *const kDBHAllInformationModelDataTitle = @"title";
NSString *const kDBHAllInformationModelDataUserId = @"user_id";
NSString *const kDBHAllInformationModelDataImg = @"img";
NSString *const kDBHAllInformationModelDataUpdatedAt = @"updated_at";
NSString *const kDBHAllInformationModelDataSort = @"sort";
NSString *const kDBHAllInformationModelDataCommentsCount = @"comments_count";
NSString *const kDBHAllInformationModelDataEnable = @"enable";
NSString *const kDBHAllInformationModelDataVideo = @"video";
NSString *const kDBHAllInformationModelDataSeoTitle = @"seo_title";
NSString *const kDBHAllInformationModelDataSaveUser = @"save_user";
NSString *const kDBHAllInformationModelDataType = @"type";
NSString *const kDBHAllInformationModelDataIsScroll = @"is_scroll";
NSString *const kDBHAllInformationModelDataIsTop = @"is_top";
NSString *const kDBHAllInformationModelDataId = @"id";
NSString *const kDBHAllInformationModelDataSubTitle = @"sub_title";
NSString *const kDBHAllInformationModelDataIsExtendAttr = @"is_extend_attr";
NSString *const kDBHAllInformationModelDataSeoKeyworks = @"seo_keyworks";
NSString *const kDBHAllInformationModelDataCreatedAt = @"created_at";
NSString *const kDBHAllInformationModelDataSeoDesc = @"seo_desc";
NSString *const kDBHAllInformationModelDataDesc = @"desc";
NSString *const kDBHAllInformationModelDataCategoryId = @"category_id";
NSString *const kDBHAllInformationModelDataIsHot = @"is_hot";
NSString *const kDBHAllInformationModelDataIsComment = @"is_comment";


@interface DBHAllInformationModelData ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DBHAllInformationModelData

@synthesize author = _author;
@synthesize content = _content;
@synthesize style = _style;
@synthesize status = _status;
@synthesize clickRate = _clickRate;
@synthesize title = _title;
@synthesize userId = _userId;
@synthesize img = _img;
@synthesize updatedAt = _updatedAt;
@synthesize sort = _sort;
@synthesize commentsCount = _commentsCount;
@synthesize enable = _enable;
@synthesize video = _video;
@synthesize seoTitle = _seoTitle;
@synthesize saveUser = _saveUser;
@synthesize type = _type;
@synthesize isScroll = _isScroll;
@synthesize isTop = _isTop;
@synthesize dataIdentifier = _dataIdentifier;
@synthesize subTitle = _subTitle;
@synthesize isExtendAttr = _isExtendAttr;
@synthesize seoKeyworks = _seoKeyworks;
@synthesize createdAt = _createdAt;
@synthesize seoDesc = _seoDesc;
@synthesize desc = _desc;
@synthesize categoryId = _categoryId;
@synthesize isHot = _isHot;
@synthesize isComment = _isComment;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
            self.author = [self objectOrNilForKey:kDBHAllInformationModelDataAuthor fromDictionary:dict];
            self.content = [self objectOrNilForKey:kDBHAllInformationModelDataContent fromDictionary:dict];
            self.style = [self objectOrNilForKey:kDBHAllInformationModelDataStyle fromDictionary:dict];
            self.status = [[self objectOrNilForKey:kDBHAllInformationModelDataStatus fromDictionary:dict] doubleValue];
            self.clickRate = [[self objectOrNilForKey:kDBHAllInformationModelDataClickRate fromDictionary:dict] doubleValue];
            self.title = [self objectOrNilForKey:kDBHAllInformationModelDataTitle fromDictionary:dict];
            self.userId = [[self objectOrNilForKey:kDBHAllInformationModelDataUserId fromDictionary:dict] doubleValue];
            self.img = [self objectOrNilForKey:kDBHAllInformationModelDataImg fromDictionary:dict];
            self.updatedAt = [self objectOrNilForKey:kDBHAllInformationModelDataUpdatedAt fromDictionary:dict];
            self.sort = [[self objectOrNilForKey:kDBHAllInformationModelDataSort fromDictionary:dict] doubleValue];
            self.commentsCount = [[self objectOrNilForKey:kDBHAllInformationModelDataCommentsCount fromDictionary:dict] doubleValue];
            self.enable = [[self objectOrNilForKey:kDBHAllInformationModelDataEnable fromDictionary:dict] doubleValue];
            self.video = [self objectOrNilForKey:kDBHAllInformationModelDataVideo fromDictionary:dict];
            self.seoTitle = [self objectOrNilForKey:kDBHAllInformationModelDataSeoTitle fromDictionary:dict];
            self.saveUser = [[self objectOrNilForKey:kDBHAllInformationModelDataSaveUser fromDictionary:dict] doubleValue];
            self.type = [[self objectOrNilForKey:kDBHAllInformationModelDataType fromDictionary:dict] doubleValue];
            self.isScroll = [[self objectOrNilForKey:kDBHAllInformationModelDataIsScroll fromDictionary:dict] doubleValue];
            self.isTop = [[self objectOrNilForKey:kDBHAllInformationModelDataIsTop fromDictionary:dict] doubleValue];
            self.dataIdentifier = [[self objectOrNilForKey:kDBHAllInformationModelDataId fromDictionary:dict] doubleValue];
            self.subTitle = [self objectOrNilForKey:kDBHAllInformationModelDataSubTitle fromDictionary:dict];
            self.isExtendAttr = [[self objectOrNilForKey:kDBHAllInformationModelDataIsExtendAttr fromDictionary:dict] doubleValue];
            self.seoKeyworks = [self objectOrNilForKey:kDBHAllInformationModelDataSeoKeyworks fromDictionary:dict];
            self.createdAt = [self objectOrNilForKey:kDBHAllInformationModelDataCreatedAt fromDictionary:dict];
            self.seoDesc = [self objectOrNilForKey:kDBHAllInformationModelDataSeoDesc fromDictionary:dict];
            self.desc = [self objectOrNilForKey:kDBHAllInformationModelDataDesc fromDictionary:dict];
            self.categoryId = [[self objectOrNilForKey:kDBHAllInformationModelDataCategoryId fromDictionary:dict] doubleValue];
            self.isHot = [[self objectOrNilForKey:kDBHAllInformationModelDataIsHot fromDictionary:dict] doubleValue];
            self.isComment = [[self objectOrNilForKey:kDBHAllInformationModelDataIsComment fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.author forKey:kDBHAllInformationModelDataAuthor];
    [mutableDict setValue:self.content forKey:kDBHAllInformationModelDataContent];
    [mutableDict setValue:self.style forKey:kDBHAllInformationModelDataStyle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.status] forKey:kDBHAllInformationModelDataStatus];
    [mutableDict setValue:[NSNumber numberWithDouble:self.clickRate] forKey:kDBHAllInformationModelDataClickRate];
    [mutableDict setValue:self.title forKey:kDBHAllInformationModelDataTitle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userId] forKey:kDBHAllInformationModelDataUserId];
    [mutableDict setValue:self.img forKey:kDBHAllInformationModelDataImg];
    [mutableDict setValue:self.updatedAt forKey:kDBHAllInformationModelDataUpdatedAt];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sort] forKey:kDBHAllInformationModelDataSort];
    [mutableDict setValue:[NSNumber numberWithDouble:self.commentsCount] forKey:kDBHAllInformationModelDataCommentsCount];
    [mutableDict setValue:[NSNumber numberWithDouble:self.enable] forKey:kDBHAllInformationModelDataEnable];
    [mutableDict setValue:self.video forKey:kDBHAllInformationModelDataVideo];
    [mutableDict setValue:self.seoTitle forKey:kDBHAllInformationModelDataSeoTitle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.saveUser] forKey:kDBHAllInformationModelDataSaveUser];
    [mutableDict setValue:[NSNumber numberWithDouble:self.type] forKey:kDBHAllInformationModelDataType];
    [mutableDict setValue:[NSNumber numberWithDouble:self.isScroll] forKey:kDBHAllInformationModelDataIsScroll];
    [mutableDict setValue:[NSNumber numberWithDouble:self.isTop] forKey:kDBHAllInformationModelDataIsTop];
    [mutableDict setValue:[NSNumber numberWithDouble:self.dataIdentifier] forKey:kDBHAllInformationModelDataId];
    [mutableDict setValue:self.subTitle forKey:kDBHAllInformationModelDataSubTitle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.isExtendAttr] forKey:kDBHAllInformationModelDataIsExtendAttr];
    [mutableDict setValue:self.seoKeyworks forKey:kDBHAllInformationModelDataSeoKeyworks];
    [mutableDict setValue:self.createdAt forKey:kDBHAllInformationModelDataCreatedAt];
    [mutableDict setValue:self.seoDesc forKey:kDBHAllInformationModelDataSeoDesc];
    [mutableDict setValue:self.desc forKey:kDBHAllInformationModelDataDesc];
    [mutableDict setValue:[NSNumber numberWithDouble:self.categoryId] forKey:kDBHAllInformationModelDataCategoryId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.isHot] forKey:kDBHAllInformationModelDataIsHot];
    [mutableDict setValue:[NSNumber numberWithDouble:self.isComment] forKey:kDBHAllInformationModelDataIsComment];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description  {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    self.author = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataAuthor];
    self.content = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataContent];
    self.style = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataStyle];
    self.status = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataStatus];
    self.clickRate = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataClickRate];
    self.title = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataTitle];
    self.userId = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataUserId];
    self.img = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataImg];
    self.updatedAt = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataUpdatedAt];
    self.sort = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataSort];
    self.commentsCount = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataCommentsCount];
    self.enable = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataEnable];
    self.video = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataVideo];
    self.seoTitle = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataSeoTitle];
    self.saveUser = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataSaveUser];
    self.type = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataType];
    self.isScroll = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataIsScroll];
    self.isTop = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataIsTop];
    self.dataIdentifier = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataId];
    self.subTitle = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataSubTitle];
    self.isExtendAttr = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataIsExtendAttr];
    self.seoKeyworks = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataSeoKeyworks];
    self.createdAt = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataCreatedAt];
    self.seoDesc = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataSeoDesc];
    self.desc = [aDecoder decodeObjectForKey:kDBHAllInformationModelDataDesc];
    self.categoryId = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataCategoryId];
    self.isHot = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataIsHot];
    self.isComment = [aDecoder decodeDoubleForKey:kDBHAllInformationModelDataIsComment];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_author forKey:kDBHAllInformationModelDataAuthor];
    [aCoder encodeObject:_content forKey:kDBHAllInformationModelDataContent];
    [aCoder encodeObject:_style forKey:kDBHAllInformationModelDataStyle];
    [aCoder encodeDouble:_status forKey:kDBHAllInformationModelDataStatus];
    [aCoder encodeDouble:_clickRate forKey:kDBHAllInformationModelDataClickRate];
    [aCoder encodeObject:_title forKey:kDBHAllInformationModelDataTitle];
    [aCoder encodeDouble:_userId forKey:kDBHAllInformationModelDataUserId];
    [aCoder encodeObject:_img forKey:kDBHAllInformationModelDataImg];
    [aCoder encodeObject:_updatedAt forKey:kDBHAllInformationModelDataUpdatedAt];
    [aCoder encodeDouble:_sort forKey:kDBHAllInformationModelDataSort];
    [aCoder encodeDouble:_commentsCount forKey:kDBHAllInformationModelDataCommentsCount];
    [aCoder encodeDouble:_enable forKey:kDBHAllInformationModelDataEnable];
    [aCoder encodeObject:_video forKey:kDBHAllInformationModelDataVideo];
    [aCoder encodeObject:_seoTitle forKey:kDBHAllInformationModelDataSeoTitle];
    [aCoder encodeDouble:_saveUser forKey:kDBHAllInformationModelDataSaveUser];
    [aCoder encodeDouble:_type forKey:kDBHAllInformationModelDataType];
    [aCoder encodeDouble:_isScroll forKey:kDBHAllInformationModelDataIsScroll];
    [aCoder encodeDouble:_isTop forKey:kDBHAllInformationModelDataIsTop];
    [aCoder encodeDouble:_dataIdentifier forKey:kDBHAllInformationModelDataId];
    [aCoder encodeObject:_subTitle forKey:kDBHAllInformationModelDataSubTitle];
    [aCoder encodeDouble:_isExtendAttr forKey:kDBHAllInformationModelDataIsExtendAttr];
    [aCoder encodeObject:_seoKeyworks forKey:kDBHAllInformationModelDataSeoKeyworks];
    [aCoder encodeObject:_createdAt forKey:kDBHAllInformationModelDataCreatedAt];
    [aCoder encodeObject:_seoDesc forKey:kDBHAllInformationModelDataSeoDesc];
    [aCoder encodeObject:_desc forKey:kDBHAllInformationModelDataDesc];
    [aCoder encodeDouble:_categoryId forKey:kDBHAllInformationModelDataCategoryId];
    [aCoder encodeDouble:_isHot forKey:kDBHAllInformationModelDataIsHot];
    [aCoder encodeDouble:_isComment forKey:kDBHAllInformationModelDataIsComment];
}

- (id)copyWithZone:(NSZone *)zone {
    DBHAllInformationModelData *copy = [[DBHAllInformationModelData alloc] init];
    
    
    
    if (copy) {

        copy.author = [self.author copyWithZone:zone];
        copy.content = [self.content copyWithZone:zone];
        copy.style = [self.style copyWithZone:zone];
        copy.status = self.status;
        copy.clickRate = self.clickRate;
        copy.title = [self.title copyWithZone:zone];
        copy.userId = self.userId;
        copy.img = [self.img copyWithZone:zone];
        copy.updatedAt = [self.updatedAt copyWithZone:zone];
        copy.sort = self.sort;
        copy.commentsCount = self.commentsCount;
        copy.enable = self.enable;
        copy.video = [self.video copyWithZone:zone];
        copy.seoTitle = [self.seoTitle copyWithZone:zone];
        copy.saveUser = self.saveUser;
        copy.type = self.type;
        copy.isScroll = self.isScroll;
        copy.isTop = self.isTop;
        copy.dataIdentifier = self.dataIdentifier;
        copy.subTitle = [self.subTitle copyWithZone:zone];
        copy.isExtendAttr = self.isExtendAttr;
        copy.seoKeyworks = [self.seoKeyworks copyWithZone:zone];
        copy.createdAt = [self.createdAt copyWithZone:zone];
        copy.seoDesc = [self.seoDesc copyWithZone:zone];
        copy.desc = [self.desc copyWithZone:zone];
        copy.categoryId = self.categoryId;
        copy.isHot = self.isHot;
        copy.isComment = self.isComment;
    }
    
    return copy;
}


@end
