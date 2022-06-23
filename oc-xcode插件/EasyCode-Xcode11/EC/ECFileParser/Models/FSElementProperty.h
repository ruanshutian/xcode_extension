//
//  FSElementProperty.h
//  FastStub
//
//  Created by gao feng on 16/5/27.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FSElementPropertyActionInit,
    FSElementPropertyActionGetterSetter,
} FSElementPropertyAction;

@interface FSElementProperty : NSObject

@property (nonatomic, strong) NSString*                                 propertyName;
@property (nonatomic, strong) NSString*                                 propertyType;
@property (nonatomic, assign) FSElementPropertyAction                   action;

@end
