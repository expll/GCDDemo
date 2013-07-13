//
//  foo.m
//  GCDDemo
//
//  Created by leiwang on 13-7-13.
//  Copyright (c) 2013年 bigdata. All rights reserved.
//

#import "fooBlock.h"

static int(^pBlock)(int, int) = ^(int a, int b){ return a > b ? a : b; };

void foo()
{
    __block int i = 1024; // i在栈区
    int j = 1; // j在栈区
    void (^blk)(void);
    void (^blkInHeap)(void);
    
    // 此时blk位于栈上， 其使用的变量也在栈上
    // 复制后的blk位于堆上， 标记__block的i 将被复制一份到堆上， j不变动，依旧在栈上。
    // 当函数foo返回后，栈上的j已经回收，那么blkInHeap怎么能继续使用它？这是因为没有__block标记的变量，会被当做实参传入block的底层实现函数中，当block中的代码被执行时，j已经不是原来的j了.
    // 如果使用到变量j的所有block都没有被复制至heap，那么这个变量j也不会被复制至heap。
    // 即使将j++这一句放到blk()这句之前，这段代码执行后，控制台打印结果也是：1024, 1。而不是1024, 2
    blk = ^{ printf("%d, %d\n", i, j);};
    blkInHeap = Block_copy(blk);
    printf("blkInHeap: %p\nblk: %p\n", blkInHeap, blk);

    // 理论： 
    // (1)对栈上的block调用copy，每次会返回新复制到堆上的block的指针，同时，所有__block变量都会被复制至堆一份(多次拷贝，只会生成一份)。
    // (2)对全局区的block调用copy，会返回原指针，并且这期间不处理任何东西（至少目前的内部实现是这样）；
    // (3)对已经位于heap上的block，再次调用copy，只会增加block的引用计数.
    // (4)objc里面的retain消息发送给block对象后，其内部实现是什么都不做。(do nothing)

    // 特例：
    // 如果block体里面没有变量（内存开销为0），将返回原指针。
    
    void (^kBlock)(void);
    void (^cBlock)(void);
    void (^yBlock)(void);
    int  (^qBlock)(int, int);

    kBlock = ^{ printf("%s, %s, %d\n", __FILE__, __FUNCTION__, __LINE__);};
    yBlock = [kBlock copy];
    cBlock = Block_copy(kBlock);
    qBlock =[pBlock copy];
    
    // 打印这5个block的地址
    // 根据以上的逻辑， kBlock, cBlock, yBlock 不应该相等
    // 但是下面的打印结果是：
    // kBlock: 0x100002240
    // cBlock: 0x100002240
    // yBlock: 0x100002240
    // pBlock: 0x1000021d0
    // qBlock: 0x1000021d0
    printf("kBlock: %p\ncBlock: %p\nyBlock: %p\npBlock: %p\nqBlock: %p", kBlock, cBlock, yBlock, pBlock, qBlock);
}




@implementation fooBlock

- (void)fooBar
{
    self.cup = @"cup";
    
    // 原则：
    // objc类实例方法中的block如果被复制至heap，那么当前实例会被增加引用计数，当这个block被释放时，此实例会被减少引用计数。
    // (前提是： block使用到了 类实例 中的成员变量)
    void (^tBlock)(void) = ^{NSLog(@"%@", _cup);};
    Block_copy(tBlock);
    
    // 我们要注意的一点是，我看到网上有很多人说block引起了实例与block之间的循环引用（retain-cycle），并且给出解决方案：不直接使用self而先将self赋值给一个临时变量，然后再使用这个临时变量。
    //但是，大家注意，我们一定要为这个临时变量增加__block标记（多谢第三篇文章回帖网友的提醒）。

    //foo();
    

}

@end
