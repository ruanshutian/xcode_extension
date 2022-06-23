Xcode source editor——Xcode插件制作

https://developer.apple.com/documentation/xcodekit?language=objc

​	使用XcodeKit框架，您可以使用源代码编辑器扩展定制Xcode，以向源代码编辑器添加功能和专用行为。源编辑器扩展提供了一组编辑器命令，以及Xcode中编辑器菜单中的内置命令。源编辑器扩展可以读取和修改源文件的内容，也可以读取和修改编辑器中的当前文本选择。在Mac App Store上发布的开发者应用中包括源代码编辑器扩展。

一、**First Steps**

将源编辑器扩展目标添加到Xcode项目并激活其方案。

1、在Xcode项目中添加并配置源代码编辑器扩展。source editor extension

您可以使用XcodeKit在Xcode中构建源代码编辑器的扩展。源编辑器扩展可以读取和修改源文件的内容，也可以读取和修改编辑器中的当前文本选择。

File-new-target--macOS-Xcode Source Editor Extention

添加到自己的项目目录中即可。

--------------------------------------------------------------------------------------------------------

问题：可能run之后出现问题，editor下面没有显示插件。

解决：Frameworks and Libraries 添加XcodeKit.framework失败，需要手动添加。

—————————————————————————————————

 [XCSourceEditorCommand](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommand?language=objc) protocol中有

XCSourceEditorCommandDefinitionKey和

\- (void)performCommandWithInvocation:([XCSourceEditorCommandInvocation](dash-apple-api://load?request_key=lc/documentation/xcodekit/xcsourceeditorcommandinvocation) *)invocation completionHandler:(void (^)([NSError](dash-apple-api://load?request_key=lc/documentation/foundation/nserror) *nilOrError))completionHandler;

—————————————————————————————————

XCSourceEditorCommandClassNameKey——类名

XCSourceEditorCommandIdentifierKey——Identifier标识

XCSourceEditorCommandNameKey——按钮的名字

--------------------------------------------------------------------------------------------------------

SourceEditorExtension中

\- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions

函数返回editor下拉显示的按钮

（也可以通过info.plist设置这些参数）



—————————————————————————————————

performCommandWithInvocation中写命令action

  NSMutableArray<NSString *> *lines= invocation.buffer.lines;

  NSArray<NSString *> *updatedText=[[lines reverseObjectEnumerator] allObjects];

  [lines removeAllObjects];

  **for**(NSString* NSArray_i **in** updatedText)

  {

​    [lines addObject:NSArray_i];

  }



2、启动一个特殊的Xcode实例来测试源代码编辑器扩展。test



3、用于创建Xcode源代码编辑器扩展的协议。[XCSourceEditorExtension](https://developer.apple.com/documentation/xcodekit/xcsourceeditorextension?language=objc)——



[commandDefinitions——](https://developer.apple.com/documentation/xcodekit/xcsourceeditorextension/2097048-commanddefinitions?language=objc)返回editor下拉按钮的属性数组

[Xcode用于将命令名与其在扩展中的实现相关联的命令定义数组。](https://developer.apple.com/documentation/xcodekit/xcsourceeditorextension/2097048-commanddefinitions?language=objc)



[- extensionDidFinishLaunching——通知函数](https://developer.apple.com/documentation/xcodekit/xcsourceeditorextension/2097050-extensiondidfinishlaunching?language=objc)

[通知扩展已成功启动，并可能开始接收编辑器命令。](https://developer.apple.com/documentation/xcodekit/xcsourceeditorextension/2097050-extensiondidfinishlaunching?language=objc)



二、**Editor Commands**

通过更改源编辑器中的文本内容和文本选择来响应命令。



1、[XCSourceEditorCommand](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommand?language=objc)

[用于在源编辑器扩展中处理命令调用的协议。](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommand?language=objc)



三个字段：[`XCSourceEditorCommandDefinitionKey`](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommanddefinitionkey?language=objc)

[`XCSourceEditorCommandClassNameKey`](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandclassnamekey?language=objc)——类名

The class of the source editor command, in its attributes.

[`XCSourceEditorCommandIdentifierKey`](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandidentifierkey?language=objc)——标识名

The identifier of the source editor command in its attributes.

[`XCSourceEditorCommandNameKey`](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandnamekey?language=objc)——显示名

The name of the source editor command in its attributes.



相应事件：[`- performCommandWithInvocation:completionHandler:`](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommand/2097278-performcommandwithinvocation?language=objc)

invocation——editor之后执行
The invocation of the command to be invoked.

completionHandler——命令调用结束要执行的block
A block to be executed when the command finishes.



2、[XCSourceEditorCommandInvocation](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation?language=objc)

[一个对象，用于标识向扩展发出的命令，并提供活动源编辑器的内容。](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation?language=objc)



[buffer](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation/2097284-buffer?language=objc)

[命令可以操作的源文本缓冲区。](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation/2097284-buffer?language=objc)



[commandIdentifier](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation/2097285-commandidentifier?language=objc)

[用户调用的命令的标识符。](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation/2097285-commandidentifier?language=objc)



[cancellationHandler](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation/2097273-cancellationhandler?language=objc)

[Xcode调用的处理程序，用于指示用户已取消调用。](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommandinvocation/2097273-cancellationhandler?language=objc)



三、**Source Text**

**1**、

[XCSourceTextBuffer](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer?language=objc)

[用于访问和修改源编辑器中的文本内容和文本选择的缓冲区。](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer?language=objc)



[completeBuffer](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097271-completebuffer?language=objc)

[完整缓冲区的字符串表示形式。](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097271-completebuffer?language=objc)

[contentUTI](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097266-contentuti?language=objc)

[缓冲区中内容的唯一类型标识符（UTI）。](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097266-contentuti?language=objc)





[lines](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097272-lines?language=objc)

[缓冲区中的文本行，包括行尾。](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097272-lines?language=objc)

[selections](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097281-selections?language=objc)

[缓冲区中的文本选择。](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097281-selections?language=objc)



[indentationWidth](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097268-indentationwidth?language=objc)

[缓冲区中用于缩进文本的空格字符数。](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097268-indentationwidth?language=objc)



[usesTabsForIndentation](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097276-usestabsforindentation?language=objc)

一个布尔值，指示制表符是否用于缩进。



[tabWidth](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097280-tabwidth?language=objc)

[缓冲区中由制表符表示的空格字符数。](https://developer.apple.com/documentation/xcodekit/xcsourcetextbuffer/2097280-tabwidth?language=objc)



2、

[XCSourceTextPosition](https://developer.apple.com/documentation/xcodekit/xcsourcetextposition?language=objc)

[源编辑器中基于零的位置，由行号和列号定义。](https://developer.apple.com/documentation/xcodekit/xcsourcetextposition?language=objc)



[XCSourceTextPositionMake](https://developer.apple.com/documentation/xcodekit/2269726-xcsourcetextpositionmake?language=objc)

[为指定的行和列创建新的文本位置。](https://developer.apple.com/documentation/xcodekit/2269726-xcsourcetextpositionmake?language=objc)



[column](https://developer.apple.com/documentation/xcodekit/xcsourcetextposition/2095124-column?language=objc)

[源文本位置的水平分量。](https://developer.apple.com/documentation/xcodekit/xcsourcetextposition/2095129-line?language=objc)



[line](https://developer.apple.com/documentation/xcodekit/xcsourcetextposition/2095129-line?language=objc)

[源文本位置的垂直分量。](https://developer.apple.com/documentation/xcodekit/xcsourcetextposition/2095129-line?language=objc)









3、

[XCSourceTextRange](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange?language=objc)

[缓冲区中半开放的文本范围，用于选择文本或指定新文本的插入点。](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange?language=objc)



[- initWithStart:end:](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange/2242782-initwithstart?language=objc)

[创建由起始和结束位置定义的新源文本范围。](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange/2242782-initwithstart?language=objc)



[start](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange/2097282-start?language=objc)

[范围的起始位置。](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange/2097282-start?language=objc)



[end](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange/2097270-end?language=objc)

[范围的结束位置。](https://developer.apple.com/documentation/xcodekit/xcsourcetextrange/2097270-end?language=objc)



4\

[XcodeKit Version Constants](https://developer.apple.com/documentation/xcodekit/xcodekit_version_constants?language=objc)

[确定Xcode实例中可用的Xcode工具包的版本。](https://developer.apple.com/documentation/xcodekit/xcodekit_version_constants?language=objc)



[XCXcodeKitVersionNumber](https://developer.apple.com/documentation/xcodekit/xcxcodekitversionnumber?language=objc)

XcodeKit的当前版本。

[XCXcodeKitVersionNumber_Xcode_8_0](https://developer.apple.com/documentation/xcodekit/xcxcodekitversionnumber_xcode_8_0?language=objc)

Xcode 8.0中包含的Xcode工具包版本。









[XTExtension](https://github.com/wuwen1030/XTExtension)

https://github.com/wuwen1030/XTExtension

在该行前添加注释//



**Snowonder-swift**

https://github.com/Karetski/Snowonder

import头文件去重