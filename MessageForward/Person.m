//
//  Person.m
//  MessageForward
//
//  Created by Apple on 2018/5/4.
//  Copyright © 2018年 王全金. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>
#import "Car.h"

@implementation Person

/*
在一个函数找不到时，Objective-C提供了三种方式去补救：
1、调用resolveInstanceMethod给个机会让类添加这个实现这个函数
2、调用forwardingTargetForSelector让别的对象去执行这个函数
3、调用methodSignatureForSelector（函数符号制造器）和forwardInvocation（函数执行器）灵活的将目标函数以其他形式执行。
如果都不行，调用doesNotRecognizeSelector抛出异常。*/

void run(id self, SEL _cmd) {
    NSLog(@"%@ %s", self, sel_getName(_cmd));
}

//方案一 增加实现
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel==@selector(run)) {
//        class_addMethod([self class], sel, (IMP)run, "v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}

//方案二 将消息交给能处理的对象
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    Car *car = [[Car alloc] init];
//    if ([car respondsToSelector:aSelector]) {
//        return car;
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}

//方案三
//methodSignatureForSelector用来生成方法签名，这个签名就是给forwardInvocation中的参数NSInvocation调用的。
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSString *sel = NSStringFromSelector(aSelector);
    if ([sel isEqualToString:@"run"]) {
        //为你的转发方法手动生成签名
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    //拿到函数名
    SEL selector = anInvocation.selector;
    //新建需要转发消息的对象
    Car *car = [[Car alloc] init];
    if ([car respondsToSelector:selector]) {
        //唤醒这个方法
        [anInvocation invokeWithTarget:car];
    }
}

//作为找不到函数实现的最后一步，NSObject实现这个函数只有一个功能，就是抛出异常
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"%@ 没有这个方法 %@",self, NSStringFromSelector(aSelector));
}

@end
