﻿finished by Wang Shu_PB19071472 2021.4.10 

本实验启动进入myMain

主要功能模块：
vga输出
uart输出
myPrintk
myPrintf

功能1：进入myMain；清屏；输出myMain的标识字符串

运行命令:
qemu-system-i386 -kernel myOS.elf -serial stdio
推荐使用脚本，一键编译运行：
./source2run.sh
