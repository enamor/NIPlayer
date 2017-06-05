//
//  NIPlayerMacro.h
//  NIPlayer
//
//  Created by zhouen on 2017/6/2.
//  Copyright © 2017年 zhouen. All rights reserved.
//

#ifndef NIPlayerMacro_h
#define NIPlayerMacro_h

/** 获取NIPlayer.bundle中图片 */
#define BUNDLE_PATH [[NSBundle mainBundle] pathForResource:@"NIPlayer" ofType:@"bundle"]
#define IMAGE_PATH(img) [BUNDLE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",img]]
#define BUNDLE_IMAGE(img) [UIImage imageWithContentsOfFile:IMAGE_PATH(img)]


//十六进制颜色
#define UIColorFrom0xRGBA(rgbValue ,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define HEX_COLOR(rgbValue) UIColorFrom0xRGBA(rgbValue,1.0)

#endif /* NIPlayerMacro_h */
