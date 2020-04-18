//
//  TestActionKeyLayer.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/17.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestActionKeyLayer.h"
#import "TestActionProgressAction.h"

@interface TestActionKeyLayer () <CALayerDelegate>

/**
我们把改变属性时CALayer自动应用的动画称作行为，当CALayer的属性被修改时候，它会调用-actionForKey:方法，传递属性的名称。剩下的操作都在CALayer的头文件中有详细的说明，实质上是如下几步：

1. 图层首先检测它是否有委托，并且是否实现CALayerDelegate协议指定的-actionForLayer:forKey方法。如果有，直接调用并返回结果。
2. 如果没有委托，或者委托没有实现-actionForLayer:forKey方法，图层接着检查包含属性名称对应行为映射的actions字典。
3. 如果actions字典没有包含对应的属性，那么图层接着在它的style字典接着搜索属性名。（style字典中有一个actions的key，其value为一个字典，layer就是在这个字典中去寻找key对应的action object）
4. 最后，如果在style里面也找不到对应的行为，那么图层将会直接调用定义了每个属性的标准行为的-defaultActionForKey:方法。
所以一轮完整的搜索结束之后，-actionForKey:要么返回空（这种情况下将不会有动画发生），要么是CAAction协议对应的对象，最后CALayer拿这个结果去对先前和当前的值做动画。
*/

@end

@implementation TestActionKeyLayer
/**
 1. arcLenght的值一定要有变化才能引起actionForKey :进行搜索。
 2. arcLenght需要用关键字@dynamic修饰。
 3. actionForKey :和actionForLayer:会在属性值发生变化前调用，而runActionForKey:会在属性值发生变化后调用，需要注意。
 */
@dynamic arcLenght;

- (instancetype)initWithFrame:(CGRect)frame {
    if(self == [super init]){
        [self setupLayers:frame];
    }
    return self;
}

- (void)setupLayers:(CGRect)frame{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(frame.size.width/2, frame.size.height/2) radius:frame.size.width*0.48 startAngle:0 endAngle:2*M_PI clockwise:NO];
    
    self.path = path.CGPath;
    self.lineWidth = 3;
    self.delegate = self;
    self.strokeStart = 0;
    self.strokeEnd = 0;
    
    //下面两个可以注释掉，看看不同结果
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = [UIColor greenColor].CGColor;
}

- (id<CAAction>)actionForKey:(NSString *)event{
    NSLog(@"TestActionKeyLayer. actionForKey: %@",event);
    return [super actionForKey:event];
}

#pragma mark - < delegate >
- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event{
    TestActionProgressAction *action = nil;
    if ([event isEqualToString:@"arcLenght"]) {
        action = [[TestActionProgressAction alloc] init];
        action.oldValue = self.arcLenght;
    }
    return action;
}

@end
