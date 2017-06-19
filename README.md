---
title: 一句话实现AVPlayer视频播放
date: 2017-05-01 15:28:57
categories: "iOS"
tags:
- Objective-C
description: 由于近期项目和视频相关的比较多，而项目中别人封装的不甚满意，所以自己进行了封装，希望有更好的扩展性，同时希望大家多多提取意见，以便于更好的封装。
---

*基于AVPlaye封装的视频播放器 、一句话即可实现视频的播放 支持横屏、竖屏，监听屏幕旋转，上下滑动调节音量、屏幕亮度，左右滑动调节播放进度，快进画面预览等*

**使用说明：**

*播放器需要传入一view 自动适应view的尺寸 为了简化全屏模式统一使用屏幕旋转的方式进行适配全屏、目前控制层UI未做详细拆分，后期将逐步优化、只为做最简单的视频播放器*

* 单利模式

~~~objective-c
//此次一句话即可实现播放 同时适配横竖屏、竖立的视频
[[NIPlayer sharedPlayer] playWithUrl:_url onView:playView];

//单例需要手动释放
[[NIPlayer sharedPlayer] releasePlayer];
~~~

* 普通模式（自动释放内存）

~~~objective-c
_player = [[NIPlayer alloc] init];
[_player playWithUrl:_url onView:playView];
~~~

* 第三方法依赖

布局：Masonry

*状态栏旋转需要控制器中重写方法 且需要在info.Plist 添加 View controller-based status bar appearance 设置成No，默认为Yes*

~~~objective-c

- (BOOL)shouldAutorotate {
    return NO;
}
~~~



~~~objective-c
//对播放器内部对以下状态做了监听，可以更好的自己处理各种情况
typedef NS_ENUM(NSInteger, NIAVPlayerStatus) {
    NIAVPlayerStatusLoading = 0,     // 加载视频
    NIAVPlayerStatusReadyToPlay,     // 准备好播放
    NIAVPlayerStatusIsPlaying,       // 正在播放
    NIAVPlayerStatusIsPaused,        // 已经暂停
    NIAVPlayerStatusPlayEnd,         // 播放结束
    NIAVPlayerStatusCacheData,       // 缓冲视频
    NIAVPlayerStatusCacheEnd,        // 缓冲结束
    NIAVPlayerStatusPlayStop,        // 播放中断 （多是没网）
    NIAVPlayerStatusItemFailed,      // 视频资源问题
    NIAVPlayerStatusEnterBack,       // 进入后台
    NIAVPlayerStatusBecomeActive,    // 从后台返回
};
~~~



**温馨提示:**

1、为了处理视频全屏模式后台进入前台可以平滑的进入（无启动页）对AppDelegate 添加了分类处理 重写了以下方法

~~~objective-c
//一般状态此处用户无需处理
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (self.allowRotationType == AllowRotationMaskPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else if (self.allowRotationType == AllowRotationMaskAllButUpsideDown) {
        return  UIInterfaceOrientationMaskAllButUpsideDown;
    }else {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
}
~~~

2、APP支持方向设置为竖屏即可

![](https://raw.githubusercontent.com/enamor/ScreenImage/master/NIPlayer/show-waring.png)





**预览：**
![](https://raw.githubusercontent.com/enamor/ScreenImage/master/NIPlayer/show-how1.PNG)
![](https://raw.githubusercontent.com/enamor/ScreenImage/master/NIPlayer/show-how3.PNG)
![](https://raw.githubusercontent.com/enamor/ScreenImage/master/NIPlayer/show-how4.PNG)





**QQ交流群：518557977**

**博客地址：http://oxy.pub**

