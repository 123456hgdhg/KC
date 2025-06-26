#!/system/bin/sh

# ========== 初始化部分 ==========
# 颜色配置
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# 常量配置
CONFIG_BASE="/storage/emulated/0/kc配置文件"
FUNCTION_FILE="${CONFIG_BASE}/Function.sh"

# 初始化界面
clear
echo -e "\n          KC 网络工具箱"
echo -e "\n                 \033[1;36m--@BrotherHua--\033[0m"
# ========== 函数加载逻辑 ==========
load_functions() {
    # 确保配置目录存在
    mkdir -p "$CONFIG_BASE" 2>/dev/null

if [ "$(getprop persist.sys.timezone)" = "Asia/Shanghai" ]; then
   BASE_URL="https://gitee.com/BOT_141_2580/KC/raw/main/KC's%20shell%20script"
else
   BASE_URL="https://raw.githubusercontent.com/123456hgdhg/KC/refs/heads/main/KC's%20shell%20script"
fi                                                                
    if [ -f "$FUNCTION_FILE" ]; then
        echo -e "${YELLOW}检测到已存在的Function.sh，正在删除...${NC}"
        echo -e "${YELLOW} $UTC_1 ${NC}"
        if rm -f "$FUNCTION_FILE"; then
            echo -e "${GREEN}✓ 旧版函数库已删除${NC}"
        else
            echo -e "${RED}✗ 删除旧版函数库失败${NC}"
            exit 1
        fi
    fi
    
    # 尝试下载函数库
    echo -e "\n${BLUE}正在加载函数库...${NC}"
    if curl -sL --connect-timeout 15 "${BASE_URL}/Function.sh" -o "$FUNCTION_FILE"; then
        if [ -s "$FUNCTION_FILE" ]; then
            source "$FUNCTION_FILE" && {
                echo -e "${GREEN}✓ 函数库加载成功${NC}"
                # 函数库加载成功后才显示公告
                sleep 1
                echo -e "\n${CYAN}=== 正在获取公告信息 ===${NC}"
                sleep 1
                show_announcement
                return 0
            }
        fi
    fi
    
    echo -e "${RED}错误: 无法加载函数库${NC}"
    echo -e "${YELLOW}请检查网络连接后重试${NC}"
    exit 1
}

# 完全兼容的公告显示函数（带动态倒计时）
show_announcement() {
    clear    

 if [ "$(getprop persist.sys.timezone)" = "Asia/Shanghai" ]; then
   ANNOUNCE_URL="https://gitee.com/BOT_141_2580/KC/raw/main/KC's%20shell%20script/announcement.txt"
else
   ANNOUNCE_URL="https://raw.githubusercontent.com/123456hgdhg/KC/refs/heads/main/KC's%20shell%20script/announcement.txt"        
fi   
        ANNOUNCE_FILE="/data/local/tmp/kc_announce.txt"    
    if curl -sL --connect-timeout 10 "$ANNOUNCE_URL" -o "$ANNOUNCE_FILE"; then
        if [ -s "$ANNOUNCE_FILE" ]; then
            # 显示公告内容
            echo -e "\n${YELLOW}================================"
            echo -e "         最新公告 / ANNOUNCEMENT"
            echo -e "================================${NC}\n"
            cat "$ANNOUNCE_FILE"
            echo -e "\n${YELLOW}================================${NC}"
            
            # 改进的倒计时实现（带动态颜色和可靠按键检测）
            echo -e "\n${CYAN}按任意键跳过公告 (7秒后自动关闭)...${NC}"
            count=7
            skipped=0
            
            while [ $count -gt 0 ]; do
                # 根据剩余时间计算颜色（从绿色渐变到红色）
                if [ $count -gt 4 ]; then
                    COLOR="${GREEN}"
                elif [ $count -gt 2 ]; then
                    COLOR="${YELLOW}"
                else
                    COLOR="${RED}"
                fi
                
                # 显示带颜色的剩余时间
                printf "\r剩余时间: ${COLOR}%2d${NC} 秒 " $count
                
                # 改进的按键检测 - 使用更可靠的方式
                if read -t 1 -n 1; then
                    skipped=1
                    break
                fi
                
                count=$((count-1))
            done
            
            # 清除倒计时行
            printf "\r%-30s\n" " "
            
            if [ $skipped -eq 1 ]; then
                sleep 0.4
                echo -e "${YELLOW}跳过公告...${NC}"
                sleep 1
            fi
            
            clear
            rm -f "$ANNOUNCE_FILE"
        else
            echo -e "${YELLOW}暂无最新公告${NC}"
            sleep 2
        fi
    else
        echo -e "${YELLOW}无法获取公告信息${NC}"
        sleep 2
    fi
}

# 加载函数库
load_functions

# 加载函数库


# ========== 主菜单函数 ==========
show_main_menu() {
  clear
  echo -e "\n          KC 网络工具箱 \ KC Network Toolbox"
  echo -e "\n                 \033[1;36m--@BrotherHua--\033[0m" 
  
  echo -e "\n${CYAN}--------------------------------${NC}"
  echo -e "${GREEN}1. 下载KC配置 * Download KC Configuration"
  echo -e "${YELLOW}2. 下载灵敏度配置 * Download Sensitivity Config"
  echo -e "${RED}3. 修改设备ID * Modify Device ID"
  echo -e "${CYAN}4. 无限游客 * Unlimited tourists"
  echo -e "${CYAN}5. 导入国际服OBB * < 更新不完善 * Incomplete update >"
  echo -e "${BLUE}6. KC额外功能 * KC Extra Features"
  echo -e "${BLUE}0. 退出程序 * Exit${NC}"
  echo -e "${CYAN}--------------------------------${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_game_menu() {
  clear
  echo -e "\n${CYAN}=== 选择游戏 ==="
  echo -e "${GREEN}1. 和平精英 - Peace Elite"
  echo -e "${GREEN}2. PUBG"
  echo -e "${RED}0. 返回主菜单${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_config_menu() {
  game=$1
  clear
  echo -e "\n${CYAN}=== ${game}配置 ==="
  echo -e "${GREEN}1. 下载30配置       - 瞄准强度 Aim ●●●●●○○"
  echo -e "${GREEN}2. 下载80配置       - 瞄准强度 Aim ●●●○○○○"
  echo -e "${GREEN}3. 小金自用顶级配置 - 瞄准强度 Aim ●●●●○○○"
  echo -e "${RED}0. 返回上一级${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_kc_extra_menu() {
  clear
  echo -e "\n${CYAN}=== KC额外功能 ==="
  echo -e "${GREEN}1. 下载KC专用字体"
  echo -e "${GREEN}2. 功能2 (待开发)"
  echo -e "${GREEN}3. 功能3 (待开发)"
  echo -e "${RED}0. 返回主菜单${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_guest_menu() {
  clear
  echo -e "\n${CYAN}=== 无限游客 ==="
  echo -e "${GREEN}1. 国际服 GL"
  echo -e "${GREEN}2. 日韩服 KR/JP"
  echo -e "${GREEN}3. 台湾服 TW"
  echo -e "${GREEN}4. 越南服 VN"
  echo -e "${GREEN}5. 体验服 BATA"
  echo -e "${RED}0. 返回${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

# ========== 主程序逻辑 ==========
# 初始化目录结构
setup_dirs

# 主循环
while true; do
  show_main_menu
  choice=$(read_char)
  echo  # 换行
  case $choice in
    1) # 下载KC配置
      while true; do
        show_game_menu
        game_choice=$(read_char)
        echo  # 换行
        case $game_choice in
          1)
            game="和平精英"
            while true; do
              show_config_menu "$game"
              config_choice=$(read_char)
              echo  # 换行
              case $config_choice in
                1) 
                  download_config "$game" 30
                  echo -e "\n${CYAN}是否要应用此配置？${NC}"
                  echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
                  apply_choice=$(read_char)
                  echo  # 换行
                  if [ "$apply_choice" = "1" ]; then
                    apply_config "$game" 30
                    break 2
                  fi
                  ;;
                2) 
                  download_config "$game" 80
                  echo -e "\n${CYAN}是否要应用此配置？${NC}"
                  echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
                  apply_choice=$(read_char)
                  echo  # 换行
                  if [ "$apply_choice" = "1" ]; then
                    apply_config "$game" 80
                    break 2
                  fi
                  ;;
                0) break ;;
                *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
              esac
            done
            ;;
          2)
            game="PUBG"
            while true; do
              show_config_menu "$game"
              config_choice=$(read_char)
              echo  # 换行
case $config_choice in
  1) 
    download_config "$game" 30
    echo -e "\n${CYAN}是否要应用此配置？${NC}"
    echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
    apply_choice=$(read_char)
    echo  # 换行
    if [ "$apply_choice" = "1" ]; then
      apply_config "$game" 30
      break 2
    fi
    ;;
  2) 
    download_config "$game" 80
    echo -e "\n${CYAN}是否要应用此配置？${NC}"
    echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
    apply_choice=$(read_char)
    echo  # 换行
    if [ "$apply_choice" = "1" ]; then
      apply_config "$game" 80
      break 2
    fi
    ;;
  3) 
    if [ "$game" = "PUBG" ]; then
      download_config "$game" "小金"
      echo -e "\n${CYAN}是否要应用此配置？${NC}"
      echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
      apply_choice=$(read_char)
      echo  # 换行
      if [ "$apply_choice" = "1" ]; then
        apply_config "$game" "小金"
        break 2
      fi
    else
      echo -e "${RED}小金配置仅适用于PUBG${NC}"
      sleep 1
    fi
    ;;
  0) break ;;
  *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
esac
            done
            ;;
          0) break ;;
          *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
        esac
      done
      ;;
    2) # 下载灵敏度配置
      download_sensitivity
      ;;
    3) # 修改设备ID
      change_device_id
      ;;
    4) # 无限游客
      show_guest_menu
      game_choice=$(read_char)
      echo  # 换行
      case $game_choice in
        1) reset_game "com.tencent.ig" ;;
        2) reset_game "com.pubg.krmobile" ;;
        3) reset_game "com.rekoo.pubgm" ;;
        4) reset_game "com.vng.pubgmobile" ;;
        5) reset_game "com.tencent.igce" ;;
        0) continue ;;
        *) echo -e "${RED}无效输入，请重新选择${NC}";;
      esac
      ;;
    5) # 导入国际服OBB
      import_obb
      ;;
    6) # KC额外功能
      while true; do
        show_kc_extra_menu
        extra_choice=$(read_char)
        echo  # 换行
        case $extra_choice in
          1) 
            download_kc_font
            ;;
          2) 
            echo -e "\n${GREEN}功能2 待实现${NC}"
            sleep 1
            ;;
          3) 
            echo -e "\n${GREEN}功能3 待实现${NC}"
            sleep 1
            ;;
          0) break ;;
          *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
        esac
      done
      ;;
    0) # 退出程序
      echo -e "\n${BLUE}感谢使用！\n Thanks for using!${NC}"
      exit 0 
      ;;
    *)
      echo -e "${RED}无效输入，请重新选择${NC}"
      sleep 1
      ;;
  esac
done  
###############●●●●●●●●●●●●●●●
  echo -e "${YELLOW}2. 下载灵敏度配置 * Download Sensitivity Config"
  echo -e "${RED}3. 修改设备ID * Modify Device ID"
  echo -e "${CYAN}4. 无限游客 * Unlimited tourists"
  echo -e "${CYAN}5. 导入国际服OBB * < 更新不完善 * Incomplete update >"
  echo -e "${BLUE}6. KC额外功能 * KC Extra Features"
  echo -e "${BLUE}0. 退出程序 * Exit${NC}"
  echo -e "${CYAN}--------------------------------${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_game_menu() {
  clear
  echo -e "\n${CYAN}=== 选择游戏 ==="
  echo -e "${GREEN}1. 和平精英 - Peace Elite"
  echo -e "${GREEN}2. PUBG"
  echo -e "${RED}0. 返回主菜单${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_config_menu() {
  game=$1
  clear
  echo -e "\n${CYAN}=== ${game}配置 ==="
  echo -e "${GREEN}1. 下载30配置       - 瞄准强度 Aim ●●●●●○○"
  echo -e "${GREEN}2. 下载80配置       - 瞄准强度 Aim ●●●○○○○"
  echo -e "${GREEN}3. 小金自用顶级配置 - 瞄准强度 Aim ●●●●○○○"
  echo -e "${RED}0. 返回上一级${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_kc_extra_menu() {
  clear
  echo -e "\n${CYAN}=== KC额外功能 ==="
  echo -e "${GREEN}1. 下载KC专用字体"
  echo -e "${GREEN}2. 功能2 (待开发)"
  echo -e "${GREEN}3. 功能3 (待开发)"
  echo -e "${RED}0. 返回主菜单${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

show_guest_menu() {
  clear
  echo -e "\n${CYAN}=== 无限游客 ==="
  echo -e "${GREEN}1. 国际服 GL"
  echo -e "${GREEN}2. 日韩服 KR/JP"
  echo -e "${GREEN}3. 台湾服 TW"
  echo -e "${GREEN}4. 越南服 VN"
  echo -e "${GREEN}5. 体验服 BATA"
  echo -e "${RED}0. 返回${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
}

# ========== 主程序逻辑 ==========
# 初始化目录结构
setup_dirs

# 主循环
while true; do
  show_main_menu
  choice=$(read_char)
  echo  # 换行
  case $choice in
    1) # 下载KC配置
      while true; do
        show_game_menu
        game_choice=$(read_char)
        echo  # 换行
        case $game_choice in
          1)
            game="和平精英"
            while true; do
              show_config_menu "$game"
              config_choice=$(read_char)
              echo  # 换行
              case $config_choice in
                1) 
                  download_config "$game" 30
                  echo -e "\n${CYAN}是否要应用此配置？${NC}"
                  echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
                  apply_choice=$(read_char)
                  echo  # 换行
                  if [ "$apply_choice" = "1" ]; then
                    apply_config "$game" 30
                    break 2
                  fi
                  ;;
                2) 
                  download_config "$game" 80
                  echo -e "\n${CYAN}是否要应用此配置？${NC}"
                  echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
                  apply_choice=$(read_char)
                  echo  # 换行
                  if [ "$apply_choice" = "1" ]; then
                    apply_config "$game" 80
                    break 2
                  fi
                  ;;
                0) break ;;
                *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
              esac
            done
            ;;
          2)
            game="PUBG"
            while true; do
              show_config_menu "$game"
              config_choice=$(read_char)
              echo  # 换行
case $config_choice in
  1) 
    download_config "$game" 30
    echo -e "\n${CYAN}是否要应用此配置？${NC}"
    echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
    apply_choice=$(read_char)
    echo  # 换行
    if [ "$apply_choice" = "1" ]; then
      apply_config "$game" 30
      break 2
    fi
    ;;
  2) 
    download_config "$game" 80
    echo -e "\n${CYAN}是否要应用此配置？${NC}"
    echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
    apply_choice=$(read_char)
    echo  # 换行
    if [ "$apply_choice" = "1" ]; then
      apply_config "$game" 80
      break 2
    fi
    ;;
  3) 
    if [ "$game" = "PUBG" ]; then
      download_config "$game" "小金"
      echo -e "\n${CYAN}是否要应用此配置？${NC}"
      echo -e "${GREEN}1. 应用配置 YES \t${RED}0. 返回 NO${NC}"
      apply_choice=$(read_char)
      echo  # 换行
      if [ "$apply_choice" = "1" ]; then
        apply_config "$game" "小金"
        break 2
      fi
    else
      echo -e "${RED}小金配置仅适用于PUBG${NC}"
      sleep 1
    fi
    ;;
  0) break ;;
  *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
esac
            done
            ;;
          0) break ;;
          *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
        esac
      done
      ;;
    2) # 下载灵敏度配置
      download_sensitivity
      ;;
    3) # 修改设备ID
      change_device_id
      ;;
    4) # 无限游客
      show_guest_menu
      game_choice=$(read_char)
      echo  # 换行
      case $game_choice in
        1) reset_game "com.tencent.ig" ;;
        2) reset_game "com.pubg.krmobile" ;;
        3) reset_game "com.rekoo.pubgm" ;;
        4) reset_game "com.vng.pubgmobile" ;;
        5) reset_game "com.tencent.igce" ;;
        0) continue ;;
        *) echo -e "${RED}无效输入，请重新选择${NC}";;
      esac
      ;;
    5) # 导入国际服OBB
      import_obb
      ;;
    6) # KC额外功能
      while true; do
        show_kc_extra_menu
        extra_choice=$(read_char)
        echo  # 换行
        case $extra_choice in
          1) 
            download_kc_font
            ;;
          2) 
            echo -e "\n${GREEN}功能2 待实现${NC}"
            sleep 1
            ;;
          3) 
            echo -e "\n${GREEN}功能3 待实现${NC}"
            sleep 1
            ;;
          0) break ;;
          *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1 ;;
        esac
      done
      ;;
    0) # 退出程序
      echo -e "\n${BLUE}感谢使用！\n Thanks for using!${NC}"
      exit 0 
      ;;
    *)
      echo -e "${RED}无效输入，请重新选择${NC}"
      sleep 1
      ;;
  esac
done



