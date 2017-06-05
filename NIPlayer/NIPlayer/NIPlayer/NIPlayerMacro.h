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

#endif /* NIPlayerMacro_h */
