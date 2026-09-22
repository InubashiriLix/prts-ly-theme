#!/bin/sh
# 该文件在启动 Ly 时执行（在接管 TTY 之前）
# 自定义启动代码可以写在这里，也可以把 start_cmd 变量指向另一个文件


# 取消下面示例的注释，即可在 Linux 上把默认 TTY 配色改成另一套调色板
# 颜色为红/绿/蓝十六进制值（当前这套比默认色更亮）
#
# if [ "$TERM" = "linux" ]; then
# 	BLACK="232323"
# 	DARK_RED="D75F5F"
# 	DARK_GREEN="87AF5F"
# 	DARK_YELLOW="D7AF87"
# 	DARK_BLUE="8787AF"
# 	DARK_MAGENTA="BD53A5"
# 	DARK_CYAN="5FAFAF"
# 	LIGHT_GRAY="E5E5E5"
# 	DARK_GRAY="2B2B2B"
# 	RED="E33636"
# 	GREEN="98E34D"
# 	YELLOW="FFD75F"
# 	BLUE="7373C9"
# 	MAGENTA="D633B2"
# 	CYAN="44C9C9"
# 	WHITE="FFFFFF"

# 	COLORS="${BLACK} ${DARK_RED} ${DARK_GREEN} ${DARK_YELLOW} ${DARK_BLUE} ${DARK_MAGENTA} ${DARK_CYAN} ${LIGHT_GRAY} ${DARK_GRAY} ${RED} ${GREEN} ${YELLOW} ${BLUE} ${MAGENTA} ${CYAN} ${WHITE}"

# 	i=0
# 	while [ $i -lt 16 ]; do
# 		printf "\033]P%x%s" ${i} "$(echo "$COLORS" | cut -d ' ' -f$(( i + 1)))"

# 		i=$(( i + 1 ))
# 	done

# 	clear # 用于修复更改颜色后背景出现的瑕疵
# fi
