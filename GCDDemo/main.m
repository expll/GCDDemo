//
//  main.m
//  GCDDemo
//
//  Created by leiwang on 13-7-13.
//  Copyright (c) 2013年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fooBlock.h"


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        fooBlock *fb = [[fooBlock alloc] init];
        [fb fooBar];
        NSLog(@"fb retain count: %ld", [fb retainCount]);
    }
    return 0;
}


