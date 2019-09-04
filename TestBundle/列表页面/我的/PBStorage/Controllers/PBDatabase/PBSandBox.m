//
//  PBSandBox.m
//  TestBundle
//
//  Created by DaMaiIOS on 16/3/31.
//  Copyright © 2016年 朱善波. All rights reserved.
//

#import "PBSandBox.h"
#import <sys/stat.h>

@implementation PBSandBoxFileInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"path = %@, type = %lu, size = %lld, modifyTime = %lld", self.path, self.type, self.size, self.modifyTime];
}

@end

@implementation PBSandBox

#pragma mark - 沙盒文件操作
+ (NSArray *)fileOrDirectoryInfosAboutContentsOfDirectoryAtPath:(NSString *)directoryPath {
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
        return nil;
    }
    
    NSMutableArray *fileInfoArr = [NSMutableArray array];
    for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:directoryPath error:nil]) {
        NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullFilePath isDirectory:&isDirectory]) {
            PBSandBoxFileInfo *fileInfo = [self fileOrDirectoryInfoAtPath:fullFilePath];
            if (fileInfo) {
                [fileInfoArr addObject:fileInfo];
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"modifyTime" ascending:NO];
    NSArray *sortFileInfoArr = [fileInfoArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return sortFileInfoArr;
}

+ (PBSandBoxFileInfo *)fileOrDirectoryInfoAtPath:(NSString *)fileOrDirectoryPath {
    struct stat st;
    if (lstat([fileOrDirectoryPath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        PBSandBoxFileInfo *fileInfo = [[PBSandBoxFileInfo alloc] init];
        fileInfo.size = st.st_size;
        fileInfo.modifyTime = st.st_mtime;
        fileInfo.path = fileOrDirectoryPath;
        if (S_ISDIR(st.st_mode)) {
            fileInfo.type = PBSandBoxFileTypeDirectory;
            fileInfo.size = [self directorySizeAtPath:fileOrDirectoryPath];
        } else {
            fileInfo.type = PBSandBoxFileTypeNonDirectory;
        }
        return fileInfo;
    }
    return nil;
}

+ (BOOL)deleteContentsOfDirectoryAtPath:(NSString *)directoryPath {
    @autoreleasepool {
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
            return NO;
        }
        
        for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:directoryPath error:nil]) {
            NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:fullFilePath error:nil];
        }
    }
    return YES;
}

+ (long long)directorySizeAtPath:(NSString *)directoryPath {
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
        return 0;
    }
    
    long long size = 0;
    for (NSString *subFilePath in [fileManager enumeratorAtPath:directoryPath]) {
        NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:subFilePath];
        if ([fileManager fileExistsAtPath:fullFilePath isDirectory:&isDirectory] && !isDirectory) {
            size += [self fileSizeAtPath:fullFilePath];
        }
    }
    return size;
}

+ (long long)fileSizeAtPath:(NSString *)filePath {
    struct stat st;
    if (lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        return st.st_size;
    }
    return 0;
}

+ (BOOL)createFileAtPath:(NSString *)filePath {
    BOOL result = NO;
    NSError *error = nil;
    NSString *fullFilePath = [[PBSandBox path4Home] stringByAppendingString:filePath];
    NSString *path = [fullFilePath stringByDeletingLastPathComponent];
    
    // 自动创建父目录,不会覆盖已有目录
    result = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    // 无法自动创建父目录
    result = [[NSFileManager defaultManager] createFileAtPath:fullFilePath contents:nil attributes:nil];
    return result;
}

+ (BOOL)createDirectoryAtPath:(NSString *)directoryPath {
    BOOL result = NO;
    NSError *error = nil;
    NSString *fullFilePath = [[PBSandBox path4Home] stringByAppendingString:directoryPath];
    
    result = [[NSFileManager defaultManager] createDirectoryAtPath:fullFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    return result;
}

#pragma mark - 沙盒目录
+ (NSString *)path4Home {
    return NSHomeDirectory();
}

+ (NSString *)path4Documents {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4Library {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4LibraryCaches {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
}

+ (NSString *)path4Tmp {
    return NSTemporaryDirectory();
}

@end
