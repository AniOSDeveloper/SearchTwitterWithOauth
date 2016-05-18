//
//  NSString+URL.h
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/15.
//  Copyright © 2016年 Larry. All rights reserved.
//


#import <Foundation/Foundation.h>

//url编码解码
@interface NSString (URL)
-(NSString *)URLEncodedString;

-(NSString *)URLDecodedString;
@end
