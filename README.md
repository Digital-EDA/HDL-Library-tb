本仓库基于Digital-IDE 0.4.0开发

针对DIDE开放IP库的仿真例程仓库

# 普通用户


# 开发用户

## iverilog仿真环境

由于DIDE支持iverilog的直接快速仿真，无需写运行脚本，只需要注明是否支持iverilog即可。

## vcs仿真环境

使用的是ucli的仿真模式，通过 *.f 文件加makefile命令组成对应顶层模块的仿真。
【注】：对于文件路径均使用相对路径。此时vcs的运行路径为 `./prj/SIM${SIM_VERSION}` 所以其他路径都是相对于该路径的。