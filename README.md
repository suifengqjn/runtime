# runtime

####runtime 7种常用方法

![image](https://raw.githubusercontent.com/suifengqjn/demoimages/master/runtime/2.png)
# runtime详解

公司项目用到一个三方开源库，里面有个bug，不能改动源码，我想来想去，只能通过runtime这个万能的手段来解决。但是runtime 并不怎么会用，怎么办，马上学习呗。说到runtime，它是Objective-c里面最核心的技术，被人们传呼的神乎其神，但是感觉有一层神秘的面纱笼罩其上，毕竟使用场景不多，相信大多数开发者都不会熟练的运用。而网络上也有无数的文章来讲解runtime，但是真的非常的乱，非常的碎片化，很少有讲解的比较全面的。
   
最初是在onevcat的博客上看到runtime的[runtime的博客](https://onevcat.com/2012/04/objective-c-runtime/)，说句实话，看完后我还是蒙的，这里面主要讲了一下runtime 比较核心的功能-Method Swizzling，不过看完后还是有些不知如何下手的感觉。下面是我自己对runtime的整理，从零开始，由浅入深，并且带了几个runtime实际的应用场景。看完之后，你可以再回过头来看喵神的这篇文章，应该就能看的懂了。

###一：基本概念
Runtime基本是用C和汇编写的，可见苹果为了动态系统的高效而作出的努力。你可以在[这里](http://opensource.apple.com//source/objc4/)下到苹果维护的开源代码。苹果和GNU各自维护一个开源的runtime版本，这两个版本之间都在努力的保持一致。Objective-C 从三种不同的层级上与 Runtime 系统进行交互，分别是通过 Objective-C 源代码，通过 Foundation 框架的NSObject类定义的方法，通过对 runtime 函数的直接调用。大部分情况下你就只管写你的Objc代码就行，runtime 系统自动在幕后辛勤劳作着。

* RunTime简称运行时,就是系统在运行的时候的一些机制，其中最主要的是消息机制。
* 对于C语言，函数的调用在编译的时候会决定调用哪个函数，编译完成之后直接顺序执行，无任何二义性。
* OC的函数调用成为消息发送。属于动态调用过程。在编译的时候并不能决定真正调用哪个函数（事实证明，在编 译阶段，OC可以调用任何函数，即使这个函数并未实现，只要申明过就不会报错。而C语言在编译阶段就会报错）。
* 只有在真正运行的时候才会根据函数的名称找 到对应的函数来调用。

###二：runtime的具体实现
我们写的oc代码，它在运行的时候也是转换成了runtime方式运行的，更好的理解runtime，也能帮我们更深的掌握oc语言。
每一个oc的方法，底层必然有一个与之对应的runtime方法。

![image](https://raw.githubusercontent.com/suifengqjn/demoimages/master/runtime/1.png)

- 当我们用OC写下这样一段代码
`[tableView cellForRowAtIndexPath:indexPath];`

- 在编译时RunTime会将上述代码转化成[发送消息]
`objc_msgSend(tableView, @selector(cellForRowAtIndexPath:),indexPath);`

###三:常见方法

 `unsigned int count; `
 
 - 获取属性列表
 
 ```
objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property---->%@", [NSString stringWithUTF8String:propertyName]);
    }
```

 - 获取方法列表
 
 ```
    Method *methodList = class_copyMethodList([self class], &count);
    for (unsigned int i; i<count; i++) {
        Method method = methodList[i];
        NSLog(@"method---->%@", NSStringFromSelector(method_getName(method)));
    }
```

- 获取成员变量列表
    
  ```  
  Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i; i<count; i++) {
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSLog(@"Ivar---->%@", [NSString stringWithUTF8String:ivarName]);
    } 
  ```
 
- 获取协议列表
 
 ```   
 __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for (unsigned int i; i<count; i++) {
        Protocol *myProtocal = protocolList[i];
        const char *protocolName = protocol_getName(myProtocal);
        NSLog(@"protocol---->%@", [NSString stringWithUTF8String:protocolName]);
    }
  ``` 
  
>现在有一个Person类，和person创建的xiaoming对象,有test1和test2两个方法

- 获得类方法

```
Class PersonClass = object_getClass([Person class]);
SEL oriSEL = @selector(test1);
Method oriMethod = class_getInstanceMethod(xiaomingClass, oriSEL);
```   

- 获得实例方法
  
```
Class PersonClass = object_getClass([xiaoming class]);
SEL oriSEL = @selector(test2);
Method cusMethod = class_getInstanceMethod(xiaomingClass, oriSEL);
```   
- 添加方法

```
BOOL addSucc = class_addMethod(xiaomingClass, oriSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
```

- 替换原方法实现

```
class_replaceMethod(toolClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
```
- 交换两个方法

```
method_exchangeImplementations(oriMethod, cusMethod);
```
    
    
    
###四：常见作用
- 动态的添加对象的成员变量和方法
- 动态交换两个方法的实现
- 拦截并替换方法
- 在方法上增加额外功能
- 实现NSCoding的自动归档和解档
- 实现字典转模型的自动转换

###五：代码实现
要使用runtime，要先引入头文件`#import <objc/runtime.h>`
这些代码的实例有浅入深逐步讲解，最后附上一个我在公司项目中遇到的一个实际问题。

####1. 动态变量控制
   在程序中，xiaoming的age是10，后来被runtime变成了20，来看看runtime是怎么做到的。
   
1.动态获取XiaoMing类中的所有属性[当然包括私有]  

	`Ivar *ivar = class_copyIvarList([self.xiaoming class], &count);`  

2.遍历属性找到对应name字段  

	`const char *varName = ivar_getName(var);`

3.修改对应的字段值成20 
	
	`object_setIvar(self.xiaoMing, var, @"20");`  
	
4.代码参考

```
-(void)answer{
    	unsigned int count = 0;
    	Ivar *ivar = class_copyIvarList([self.xiaoMing class], &count);
    	for (int i = 0; i<count; i++) {
        	Ivar var = ivar[i];
        	const char *varName = ivar_getName(var);
        	NSString *name = [NSString stringWithUTF8String:varName];
        	if ([name isEqualToString:@"_age"]) {
            	object_setIvar(self.xiaoMing, var, @"20");
            	break;
        	}
    	}
    	NSLog(@"XiaoMing's age is %@",self.xiaoMing.age);
	}
```

####2.动态添加方法

在程序当中，假设XiaoMing的中没有`guess`这个方法，后来被Runtime添加一个名字叫guess的方法，最终再调用guess方法做出相应。那么，Runtime是如何做到的呢？  
  
1.动态给XiaoMing类中添加guess方法：  

```
	class_addMethod([self.xiaoMing class], @selector(guess), (IMP)guessAnswer, "v@:");
```

这里参数地方说明一下：

>(IMP)guessAnswer 意思是guessAnswer的地址指针;
>"v@:" 意思是，v代表无返回值void，如果是i则代表int；@代表 id sel; : 代表 SEL _cmd;
>“v@:@@” 意思是，两个参数的没有返回值。  


2.调用guess方法响应事件：  

	[self.xiaoMing performSelector:@selector(guess)];

3.编写guessAnswer的实现：  
	
	
	void guessAnswer(id self,SEL _cmd){
    	NSLog(@"i am from beijing");   
	} 
	

这个有两个地方留意一下：
* void的前面没有+、-号，因为只是C的代码。
* 必须有两个指定参数(id self,SEL _cmd)  

4.代码参考

```  
	-(void)answer{
    	class_addMethod([self.xiaoMing class], @selector(guess), (IMP)guessAnswer, "v@:");
    	if ([self.xiaoMing respondsToSelector:@selector(guess)]) {
        
        	[self.xiaoMing performSelector:@selector(guess)];
        
    	} else{
        	NSLog(@"Sorry,I don't know");
    	}
	}

	void guessAnswer(id self,SEL _cmd){
   
    	NSLog(@"i am from beijing");
    
	}
```

####3：动态交换两个方法的实现

在程序当中，假设XiaoMing的中有`test1` 和 `test2`这两个方法，后来被Runtime交换方法后，每次调动`test1` 的时候就会去执行`test2`，调动`test2` 的时候就会去执行`test1`， 。那么，Runtime是如何做到的呢？

1. 获取这个类中的两个方法并交换

```
Method m1 = class_getInstanceMethod([self.xiaoMing class], @selector(test1));
    Method m2 = class_getInstanceMethod([self.xiaoMing class], @selector(test2));
    method_exchangeImplementations(m1, m2);
```
交换方法之后，以后每次调用这两个方法都会交换方法的实现

####4：拦截并替换方法

在程序当中，假设XiaoMing的中有`test1`这个方法，但是由于某种原因，我们要改变这个方法的实现，但是又不能去动它的源代码(正如一些开源库出现问题的时候)，这个时候runtime就派上用场了。

我们先增加一个tool类，然后写一个我们自己实现的方法-change，
通过runtime把test1替换成change。

```
Class PersionClass = object_getClass([Person class]);
Class toolClass = object_getClass([tool class]);

    ////源方法的SEL和Method
    
    SEL oriSEL = @selector(test1);
    Method oriMethod = class_getInstanceMethod(PersionClass, oriSEL);
    
    ////交换方法的SEL和Method
    
    SEL cusSEL = @selector(change);
    Method cusMethod = class_getInstanceMethod(toolClass, cusSEL);
    
    ////先尝试給源方法添加实现，这里是为了避免源方法没有实现的情况
    
    BOOL addSucc = class_addMethod(PersionClass, oriSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
    if (addSucc) {
          // 添加成功：将源方法的实现替换到交换方法的实现     
        class_replaceMethod(toolClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
               
    }else {
    //添加失败：说明源方法已经有实现，直接将两个方法的实现交换即
method_exchangeImplementations(oriMethod, cusMethod);  
  }
 
```

####5：在方法上增加额外功能

有这样一个场景，出于某些需求，我们需要跟踪记录APP中按钮的点击次数和频率等数据，怎么解决？当然通过继承按钮类或者通过类别实现是一个办法，但是带来其他问题比如别人不一定会去实例化你写的子类，或者其他类别也实现了点击方法导致不确定会调用哪一个，runtime可以这样解决：

```
@implementation UIButton (Hook)

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        Class selfClass = [self class];

        SEL oriSEL = @selector(sendAction:to:forEvent:);
        Method oriMethod = class_getInstanceMethod(selfClass, oriSEL);

        SEL cusSEL = @selector(mySendAction:to:forEvent:);
        Method cusMethod = class_getInstanceMethod(selfClass, cusSEL);

        BOOL addSucc = class_addMethod(selfClass, oriSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        if (addSucc) {
            class_replaceMethod(selfClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
        }else {
            method_exchangeImplementations(oriMethod, cusMethod);
        }

    });
}

- (void)mySendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [CountTool addClickCount];
    [self mySendAction:action to:target forEvent:event];
}

@end
```

load方法会在类第一次加载的时候被调用,调用的时间比较靠前，适合在这个方法里做方法交换,方法交换应该被保证，在程序中只会执行一次。

####6.实现NSCoding的自动归档和解档

如果你实现过自定义模型数据持久化的过程，那么你也肯定明白，如果一个模型有许多个属性，那么我们需要对每个属性都实现一遍`encodeObject` 和 `decodeObjectForKey`方法，如果这样的模型又有很多个，这还真的是一个十分麻烦的事情。下面来看看简单的实现方式。
假设现在有一个Movie类，有3个属性，它的`h`文件这这样的

```
#import <Foundation/Foundation.h>

//1. 如果想要当前类可以实现归档与反归档，需要遵守一个协议NSCoding
@interface Movie : NSObject<NSCoding>

@property (nonatomic, copy) NSString *movieId;
@property (nonatomic, copy) NSString *movieName;
@property (nonatomic, copy) NSString *pic_url;

@end

```

如果是正常写法， `m`文件应该是这样的：

```
#import "Movie.h"
@implementation Movie

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_movieId forKey:@"id"];
    [aCoder encodeObject:_movieName forKey:@"name"];
    [aCoder encodeObject:_pic_url forKey:@"url"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.movieId = [aDecoder decodeObjectForKey:@"id"];
        self.movieName = [aDecoder decodeObjectForKey:@"name"];
        self.pic_url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}
@end
```
如果这里有100个属性，那么我们也只能把100个属性都给写一遍。
不过你会使用runtime后，这里就有更简便的方法。
下面看看runtime的实现方式：

```
#import "Movie.h"
#import <objc/runtime.h>
@implementation Movie

- (void)encodeWithCoder:(NSCoder *)encoder

{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([Movie class], &count);
    
    for (int i = 0; i<count; i++) {
        // 取出i位置对应的成员变量
        Ivar ivar = ivars[i];
        // 查看成员变量
        const char *name = ivar_getName(ivar);
        // 归档
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [encoder encodeObject:value forKey:key];
    }
    free(ivars);
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([Movie class], &count);
        for (int i = 0; i<count; i++) {
        // 取出i位置对应的成员变量
        Ivar ivar = ivars[i];
        // 查看成员变量
        const char *name = ivar_getName(ivar);
       // 归档
       NSString *key = [NSString stringWithUTF8String:name];
      id value = [decoder decodeObjectForKey:key];
       // 设置到成员变量身上
        [self setValue:value forKey:key];
            
        }
        free(ivars);
    } 
    return self;
}
@end
```

这样的方式实现，不管有多少个属性，写这几行代码就搞定了。怎么，还嫌麻烦，下面看看更加简便的方法：两句代码搞定。
我们把`encodeWithCoder` 和 `initWithCoder`这两个方法抽成宏

```
#import "Movie.h"
#import <objc/runtime.h>

#define encodeRuntime(A) \
\
unsigned int count = 0;\
Ivar *ivars = class_copyIvarList([A class], &count);\
for (int i = 0; i<count; i++) {\
Ivar ivar = ivars[i];\
const char *name = ivar_getName(ivar);\
NSString *key = [NSString stringWithUTF8String:name];\
id value = [self valueForKey:key];\
[encoder encodeObject:value forKey:key];\
}\
free(ivars);\
\



#define initCoderRuntime(A) \
\
if (self = [super init]) {\
unsigned int count = 0;\
Ivar *ivars = class_copyIvarList([A class], &count);\
for (int i = 0; i<count; i++) {\
Ivar ivar = ivars[i];\
const char *name = ivar_getName(ivar);\
NSString *key = [NSString stringWithUTF8String:name];\
id value = [decoder decodeObjectForKey:key];\
[self setValue:value forKey:key];\
}\
free(ivars);\
}\
return self;\
\


@implementation Movie

- (void)encodeWithCoder:(NSCoder *)encoder

{
    encodeRuntime(Movie)
}

- (id)initWithCoder:(NSCoder *)decoder
{
    initCoderRuntime(Movie)
}
@end
```
我们可以把这两个宏单独放到一个文件里面，这里以后需要进行数据持久化的模型都可以直接使用这两个宏。

####7.实现字典转模型的自动转换

字典转模型的应用可以说是每个app必然会使用的场景,虽然实现的方式略有不同，但是原理都是一致的：遍历模型中所有属性，根据模型的属性名，去字典中查找key，取出对应的值，给模型的属性赋值。
像几个出名的开源库：JSONModel,MJExtension等都是通过这种方式实现的。

- 先实现最外层的属性转换

```
   // 创建对应模型对象
    id objc = [[self alloc] init];

    unsigned int count = 0;

    // 1.获取成员属性数组
    Ivar *ivarList = class_copyIvarList(self, &count);

    // 2.遍历所有的成员属性名,一个一个去字典中取出对应的value给模型属性赋值
    for (int i = 0; i < count; i++) {

        // 2.1 获取成员属性
        Ivar ivar = ivarList[i];

        // 2.2 获取成员属性名 C -> OC 字符串
       NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];

        // 2.3 _成员属性名 => 字典key
        NSString *key = [ivarName substringFromIndex:1];

        // 2.4 去字典中取出对应value给模型属性赋值
        id value = dict[key];

        // 获取成员属性类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        }
```

如果模型比较简单，只有NSString，NSNumber等，这样就可以搞定了。但是如果模型含有NSArray，或者NSDictionary等，那么我们还需要进行第二步转换。

- 内层数组，字典的转换

```
if ([value isKindOfClass:[NSDictionary class]] && ![ivarType containsString:@"NS"]) { 

             //  是字典对象,并且属性名对应类型是自定义类型
            // 处理类型字符串 @\"User\" -> User
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            // 自定义对象,并且值是字典
            // value:user字典 -> User模型
            // 获取模型(user)类对象
            Class modalClass = NSClassFromString(ivarType);

            // 字典转模型
            if (modalClass) {
                // 字典转模型 user
                value = [modalClass objectWithDict:value];
            }

        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            // 判断对应类有没有实现字典数组转模型数组的协议
            if ([self respondsToSelector:@selector(arrayContainModelClass)]) {

                // 转换成id类型，就能调用任何对象的方法
                id idSelf = self;

                // 获取数组中字典对应的模型
                NSString *type =  [idSelf arrayContainModelClass][key];

                // 生成模型
                Class classModel = NSClassFromString(type);
                NSMutableArray *arrM = [NSMutableArray array];
                // 遍历字典数组，生成模型数组
                for (NSDictionary *dict in value) {
                    // 字典转模型
                    id model =  [classModel objectWithDict:dict];
                    [arrM addObject:model];
                }

                // 把模型数组赋值给value
                value = arrM;

            }
        }
```
我自己觉得系统自带的KVC模式字典转模型就挺好的，假设movie是一个模型对象，dict 是一个需要转化的 `[movie setValuesForKeysWithDictionary:dict];` 这个是系统自带的字典转模型方法，个人感觉也还是挺好用的，不过使用这个方法的时候需要在模型里面再实现一个方法才行，
`- (void)setValue:(id)value forUndefinedKey:(NSString *)key` 重写这个方法为了实现两个目的：1. 模型中的属性和字典中的key不一致的情况，比如字典中有个`id`,我们需要把它赋值给`uid`属性；2. 字典中属性比模型的属性还多的情况。
如果出现以上两种情况而没有实现这个方法的话，程序就会崩溃。
这个方法的实现：

```
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.uid = value;
    }
}
```
###六.几个参数概念

以上的几种方法应该算是runtime在实际场景中所应用的大部分的情况了，平常的编码中差不多足够用了。
如果从头仔细看到尾，相信你基本的用法应该会了，虽然会用是主要的目的，有几个基本的参数概念还是要了解一下的。

####1.objc_msgSend 
 
 ```
 /* Basic Messaging Primitives
 *
 * On some architectures, use objc_msgSend_stret for some struct return types.
 * On some architectures, use objc_msgSend_fpret for some float return types.
 * On some architectures, use objc_msgSend_fp2ret for some float return types.
 *
 * These functions must be cast to an appropriate function pointer type 
 * before being called. 
 */
 ```

这是官方的声明，从这个函数的注释可以看出来了，这是个最基本的用于发送消息的函数。另外，这个函数并不能发送所有类型的消息，只能发送基本的消息。比如，在一些处理器上，我们必须使用`objc_msgSend_stret`来发送返回值类型为结构体的消息，使用`objc_msgSend_fpret`来发送返回值类型为浮点类型的消息，而又在一些处理器上，还得使用objc_msgSend_fp2ret来发送返回值类型为浮点类型的消息。
最关键的一点：无论何时，要调用`objc_msgSend`函数，必须要将函数强制转换成合适的函数指针类型才能调用。
从`objc_msgSend`函数的声明来看，它应该是不带返回值的，但是我们在使用中却可以强制转换类型，以便接收返回值。另外，它的参数列表是可以任意多个的，前提也是要强制函数指针类型。
其实编译器会根据情况在`objc_msgSend`, `objc_msgSend_stret`, `objc_msgSendSuper`, 或 `objc_msgSendSuper_stret`四个方法中选择一个来调用。如果消息是传递给超类，那么会调用名字带有`”Super”`的函数；如果消息返回值是数据结构而不是简单值时，那么会调用名字带有`”stret”`的函数。

####2.SEL

`objc_msgSend`函数第二个参数类型为SEL，它是`selector在Objc`中的表示类型（Swift中是Selector类）。selector是方法选择器，可以理解为区分方法的 ID，而这个 ID 的数据结构是SEL:
`typedef struct objc_selector *SEL`;
其实它就是个映射到方法的C字符串，你可以用 Objc 编译器命令`@selector()`或者 Runtime 系统的`sel_registerName`函数来获得一个SEL类型的方法选择器。
不同类中相同名字的方法所对应的方法选择器是相同的，即使方法名字相同而变量类型不同也会导致它们具有相同的方法选择器，于是 Objc 中方法命名有时会带上参数类型(NSNumber一堆抽象工厂方法)，Cocoa 中有好多长长的方法哦。
####3.id
`objc_msgSend`第一个参数类型为id，大家对它都不陌生，它是一个指向类实例的指针：
`typedef struct objc_object *id`;
那objc_object又是啥呢：
`struct objc_object { Class isa; }`;
`objc_object`结构体包含一个isa指针，根据isa指针就可以顺藤摸瓜找到对象所属的类。
PS:isa指针不总是指向实例对象所属的类，不能依靠它来确定类型，而是应该用class方法来确定实例对象的类。因为KVO的实现机理就是将被观察对象的isa指针指向一个中间类而不是真实的类，这是一种叫做 isa-swizzling 的技术，详见[官方文档](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html).
####4.Class
之所以说isa是指针是因为Class其实是一个指向objc_class结构体的指针：
`typedef struct objc_class *Class`;
objc_class里面的东西多着呢：

```
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;
#if  !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;
    const char *name                                         OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
```
可以看到运行时一个类还关联了它的超类指针，类名，成员变量，方法，缓存，还有附属的协议。
在`objc_class`结构体中：`ivars是objc_ivar_list`指针；`methodLists`是指向`objc_method_list`指针的指针。也就是说可以动态修改 `*methodLists` 的值来添加成员方法，这也是Category实现的原理.

上面讲到的所有东西都在Demo里，如果你觉得不错，还请为我的Demo star一个。
####[demo下载](https://github.com/suifengqjn/runtime)





