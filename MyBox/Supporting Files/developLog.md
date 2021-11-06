#  <#Title#>

9.26 解决相册限制访问时，重新选择的照片没能及时刷新
9.28 集成图片，视频的编辑功能
9.28解决视屏播放中跳转返回无法播放的问题，音频同样
9.30 优化了国际化语言，音视频播放集成起来
10.9 新增音频播放界面，视频编辑配音，拍照，视频录制后的编辑
        新增share扩展

1011：分享时：
1.集成了ShareExtension，不出现APP
解决：info.plist 中NSExtension->NSExtensionAttributes->NSExtensionActivationRule下添加分享规则没，添加还不出现，确认target下的info和工程info.plist 是否一致，未知情况下，修改不会同时更新
2. APP出现，点击卡死。解决：详见CDShareViewController，控制器本身open无效，uiapplication.shared在扩展中不可用，所以利用@avaliable实现uiapplication.shared

10.13：完成shareExtension集成通过
            完成url分享，存储，查看

10.27 修改相册预览界面，缩略图点击，主视图不滑动的问题：isPagingEnabled = true 时 scrollToItem 无效
            相册发送按钮重复点击，会多次发送。现修改为点击一次就禁用
            
