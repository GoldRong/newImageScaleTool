# newImageScaleTool
使用大图创建@2x和@3x等图片

支持拖拽(到顶部的文本框)

支持多线程

自动识别和去掉文件名中的@x

自动修正分辨率

    比如@4x为162x300时
    会修正@2x为82x150,@3x为123x225
    以防止iPhone plus出现Misaligned Images的情况
    

# 计划
增加png压缩

实现拖拽文件(夹)到tableview

当同一个文件夹下存在同名图片的@2x和@3x等尺寸时,自动选择最大的尺寸,忽略小的尺寸

记忆上次的设置

# 使用方法:
左边选择来源分辨率倍率,右边选择目标分辨率倍率,点击右下角开始转换(如图)

![image](https://github.com/miku1958/newImageScaleTool/blob/master/截图.jpg?raw=true)
