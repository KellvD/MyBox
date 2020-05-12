//
//  CDDefines.h
//  MyBox
//
//  Created by changdong cwx889303 on 2020/5/7.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

#ifndef CDDefines_h
#define CDDefines_h


#define iOS8 (([[[UIDevice currentDevice] systemVersion]floatValue]<8.0)? NO:YES)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#define iOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)
#define iOS12Later ([UIDevice currentDevice].systemVersion.floatValue >= 12.0f)
#define iOS13Later ([UIDevice currentDevice].systemVersion.floatValue >= 13.0f)

#endif /* CDDefines_h */
