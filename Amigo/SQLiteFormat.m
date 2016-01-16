//
//  SQLiteFormat.m
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "SQLiteFormat.h"

@implementation SQLiteFormat
+ (nonnull NSString *)format:(nullable char *)format, ...{
    va_list ap;
    va_start(ap, format);

    char *result = sqlite3_vmprintf(format, ap);
    NSString * string = @(result);
    sqlite3_free(result);

    va_end(ap);
    return string;
}

+ (nonnull NSString *)escapeWithQuotes:(nullable NSString *)value{
    const char* utf8 = value.UTF8String;
    return [SQLiteFormat format:"%Q", utf8];
}

+ (nonnull NSString *)escapeWithoutQuotes:(nullable NSString *)value{
    const char* utf8 = value.UTF8String;
    return [SQLiteFormat format:"%q", utf8];
}

@end
