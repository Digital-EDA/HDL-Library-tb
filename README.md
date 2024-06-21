在0.2.6版本下 将待测library添加到插件中的方式：

1. 找到插件的安装路径
   - 参考： $PATH := C:/Users/\<userName\>/.vscode/extensions/sterben.fpga-support-0.2.6/
2. 将 $PATH/lib/com/Hardware下原本的内容删除
3. 将Github中的HDL-library `clone` 到 `$PATH/lib/com/Hardware` 下
4. 此时使用插件中的`import library`指令即可导入想要的库文件了

Q: 如何在library中添加新的文件

A：
   1. 使用脚本：
      - python ./script.py -mk `library下的相对路径/\<moduleName\>`
   2. 使用插件中的`import library`指令导入刚刚创建的文件
   3. 此时文件就导入到工程中，可以在结构树中找到

Q: 如何在library中重命名文件
A：
   1. 使用插件中的`import library`指令找到需要重命名文件的相对路径
   2. 使用脚本：
      - python ./script.py -mv `library下的相对路径/\<oldModule\>` `library下的相对路径/\<newModule\>`
   3. 此时需要使用插件中的`import library`指令重新进行导入
   4. 此时文件就导入到工程中，可以在结构树中找到
   5. 自行更改property.json的配置

Q: 如何在library中删除文件
A：
   1. 使用插件中的`import library`指令找到需要重命名文件的相对路径
   2. 使用脚本：
      - python ./script.py -rm `library下的相对路径/\<moduleName\>`
   3. 自行更改property.json的配置

Q: 如何将library上传Github（未测试）
A：
   1. 使用脚本：
      - python ./script.py -push `commitMessage`

其余脚本相关内容请自行查看脚本