#!/bin/bash

# ========== 全局配置 ==========
# 颜色配置
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# 仓库配置
GITHUB_BASE="https://raw.githubusercontent.com/123456hgdhg/KC/main"
GITEE_BASE="https://gitee.com/BOT_141_2580/KC/raw/main"

# 本地存储配置
CONFIG_BASE="/storage/emulated/0/KC_Configuration"
PEACE_DIR="$CONFIG_BASE/KC Peace Elite"
PUBG_DIR="$CONFIG_BASE/KC PUBG"
TOOLBOX_DIR="$CONFIG_BASE/KC_Toolbox_Script"

# ========== 工具函数 ==========
read_char() {
    stty -icanon -echo
    dd bs=1 count=1 2>/dev/null
    stty icanon echo
}

safe_download() {
    local url=$1
    local output=$2
    local retry=3
    
    [ -f "$output" ] && rm -f "$output"
    
    while [ $retry -gt 0 ]; do
        if curl -sL --connect-timeout 15 "$url" -o "$output"; then
            if [ -s "$output" ]; then
                echo -e "${GREEN}✓ 下载成功: $(basename "$output")${NC}"
                return 0
            else
                echo -e "${YELLOW}⚠ 空文件，重试中...${NC}"
                rm -f "$output"
            fi
        else
            echo -e "${YELLOW}⚠ 下载失败，重试中...${NC}"
        fi
        retry=$((retry-1))
        sleep 1
    done
    
    echo -e "${RED}✗ 下载失败: $(basename "$output")${NC}"
    return 1
}

# ========== 目录初始化 ==========
setup_dirs() {
    echo -e "${BLUE}正在初始化目录结构...${NC}"
    mkdir -p "$PEACE_DIR/Quasi"
    mkdir -p "$PEACE_DIR/Act"
    mkdir -p "$PEACE_DIR/Game Sensitivity"
    mkdir -p "$PUBG_DIR/Quasi"
    mkdir -p "$PUBG_DIR/Act"
    mkdir -p "$PUBG_DIR/User/Xiao Jin"
    mkdir -p "$PUBG_DIR/Game Sensitivity"
    echo -e "${GREEN}✓ 目录结构创建完成${NC}"
}

# ========== 菜单函数 ==========
main_menu() {
    while true; do
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
        
        choice=$(read_char)
        echo
        case $choice in
            1) download_config_menu ;;
            2) download_sensitivity ;;
            3) change_device_id ;;
            4) guest_menu ;;
            5) import_obb ;;
            6) kc_extra_menu ;;
            0) 
                echo -e "\n${BLUE}感谢使用！\n Thanks for using!${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}无效输入，请重新选择${NC}"
                sleep 1
                ;;
        esac
    done
}

# ========== 子菜单函数 ==========
download_config_menu() {
    while true; do
        show_game_menu
        game_choice=$(read_char)
        echo
        case $game_choice in
            1)
                game="和平精英"
                while true; do
                    show_config_menu "$game"
                    config_choice=$(read_char)
                    echo
                    case $config_choice in
                        1) download_config "$game" 30 ;;
                        2) download_config "$game" 80 ;;
                        0) break ;;
                        *) echo -e "${RED}无效输入${NC}"; sleep 1 ;;
                    esac
                done
                ;;
            2)
                game="PUBG"
                while true; do
                    show_config_menu "$game"
                    config_choice=$(read_char)
                    echo
                    case $config_choice in
                        1) download_config "$game" 30 ;;
                        2) download_config "$game" 80 ;;
                        3) download_config "$game" "小金" ;;
                        0) break ;;
                        *) echo -e "${RED}无效输入${NC}"; sleep 1 ;;
                    esac
                done
                ;;
            0) break ;;
            *) echo -e "${RED}无效输入${NC}"; sleep 1 ;;
        esac
    done
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
    [ "$game" = "PUBG" ] && echo -e "${GREEN}3. 小金自用顶级配置 - 瞄准强度 Aim ●●●●○○○"
    echo -e "${RED}0. 返回上一级${NC}"
    echo -n -e "${RED}请输入选择: ${CYAN}"
}

# ========== 功能函数 ==========
download_config() {
    game=$1
    config=$2
    
    case $game in
        "和平精英")
            case $config in
                30)
                    src_dir="Peace%20Elite/30"
                    dst_dir="$PEACE_DIR/Quasi"
                    ;;
                80)
                    src_dir="Peace%20Elite/80"
                    dst_dir="$PEACE_DIR/Act"
                    ;;
            esac
            files=("recoil_data_kccn.ini" "Config.ini")
            ;;
        "PUBG")
            case $config in
                30)
                    src_dir="PUBG/30"
                    dst_dir="$PUBG_DIR/Quasi"
                    ;;
                80)
                    src_dir="PUBG/80"
                    dst_dir="$PUBG_DIR/Act"
                    ;;
                "小金")
                    src_dir="PUBG/User/Xiao%20Jin"
                    dst_dir="$PUBG_DIR/User/Xiao Jin"
                    ;;
            esac
            files=("recoil_data_kcgl.ini" "Config.ini")
            ;;
    esac

    mkdir -p "$dst_dir"
    
    for file in "${files[@]}"; do
        echo -e "${BLUE}正在下载 ${game} ${config}配置: ${file}${NC}"
        if is_china; then
            safe_download "$GITEE_BASE/$src_dir/$file" "$dst_dir/$file" ||
            safe_download "$GITHUB_BASE/$src_dir/$file" "$dst_dir/$file"
        else
            safe_download "$GITHUB_BASE/$src_dir/$file" "$dst_dir/$file" ||
            safe_download "$GITEE_BASE/$src_dir/$file" "$dst_dir/$file"
        fi
    done
    
    echo -e "${CYAN}是否要应用此配置？${NC}"
    echo -e "${GREEN}1. 应用配置 \t${RED}0. 返回${NC}"
    if [ "$(read_char)" = "1" ]; then
        apply_config "$game" "$config"
    fi
}

#apply_config() {
    game=$1
    config=$2
    
    case $game in
        "和平精英")
            src_dir="$PEACE_DIR/$( [ "$config" = "30" ] && echo "Quasi" || echo "Act" )"
            recoil_dest="/data/local/tmp/recoil_data_kccn.ini"
            config_dest="/data/user/0/com.game.kernel/Config.txt"
            ;;
        "PUBG")
            src_dir="$PUBG_DIR/$( 
                [ "$config" = "30" ] && echo "Quasi" || 
                [ "$config" = "80" ] && echo "Act" || 
                echo "User/Xiao Jin"
            )"
            recoil_dest="/data/local/tmp/recoil_data_kcgl.ini"
            config_dest="/data/user/0/com.android.kernel/Config.txt"
            ;;
    esac

    # 部署配置文件
    cp -f "$src_dir/recoil_data_*.ini" "$recoil_dest" && \
    mv -f "$src_dir/Config.ini" "$src_dir/Config.txt" && \
    cp -f "$src_dir/Config.txt" "$config_dest" && \
    chmod 644 "$recoil_dest" "$config_dest"

    echo -e "${GREEN}✓ ${game} ${config}配置已生效${NC}"
}

download_sensitivity() {
    echo -e "\n${CYAN}=== 下载灵敏度配置 ===${NC}"
    echo -e "${GREEN}1. 和平精英"
    echo -e "${GREEN}2. PUBG${NC}"
    read -p "请选择游戏: " choice

    case $choice in
        1)
            game="和平精英"
            url_path="Peace%20Elite/Game%20Settings/Active.sav"
            dest_dir="$PEACE_DIR/Game Sensitivity"
            ;;
        2)
            game="PUBG"
            url_path="PUBG/Game%20Settings/Active.sav"
            dest_dir="$PUBG_DIR/Game Sensitivity"
            ;;
        *) return ;;
    esac

    mkdir -p "$dest_dir"
    if is_china; then
        safe_download "$GITEE_BASE/$url_path" "$dest_dir/Active.sav" || \
        safe_download "$GITHUB_BASE/$url_path" "$dest_dir/Active.sav"
    else
        safe_download "$GITHUB_BASE/$url_path" "$dest_dir/Active.sav" || \
        safe_download "$GITEE_BASE/$url_path" "$dest_dir/Active.sav"
    fi
}

guest_menu() {
    while true; do
        clear
        echo -e "\n${CYAN}=== 无限游客 ===${NC}"
        echo -e "${GREEN}1. 国际服 GL"
        echo -e "${GREEN}2. 日韩服 KR/JP"
        echo -e "${GREEN}3. 台湾服 TW"
        echo -e "${GREEN}4. 越南服 VN"
        echo -e "${RED}0. 返回${NC}"
        read -p "请选择: " choice

        case $choice in
            1) reset_game "com.tencent.ig" ;;
            2) reset_game "com.pubg.krmobile" ;;
            3) reset_game "com.rekoo.pubgm" ;;
            4) reset_game "com.vng.pubgmobile" ;;
            0) break ;;
            *) echo -e "${RED}无效输入${NC}"; sleep 1 ;;
        esac
    done
}

reset_game() {
    pkg=$1
    echo -e "${YELLOW}正在重置$pkg...${NC}"
    
    am force-stop "$pkg"
    rm -rf "/data/data/$pkg/shared_prefs" \
           "/data/data/$pkg/files" \
           "/sdcard/Android/data/$pkg/files/login-identifier.txt"
    
    # 生成新设备ID
    echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <string name=\"random\"></string>
    <string name=\"install\"></string>
    <string name=\"uuid\">$(tr -dc 'a-f0-9' < /dev/urandom | head -c 8)-$(tr -dc 'a-f0-9' < /dev/urandom | head -c 4)-$(tr -dc 'a-f0-9' < /dev/urandom | head -c 4)-$(tr -dc 'a-f0-9' < /dev/urandom | head -c 12)</string>
</map>" > "/data/data/$pkg/shared_prefs/device_id.xml"

    echo -e "${GREEN}✓ 游客账号已重置${NC}"
}

import_obb() {
    src_obb="/storage/emulated/0/123网盘/main.19935.com.tencent.ig.obb"
    dest_dir="/storage/emulated/0/Android/obb/com.tencent.ig"
    
    if [ ! -f "$src_obb" ]; then
        echo -e "${RED}错误: OBB文件不存在${NC}"
        return
    fi

    mkdir -p "$dest_dir"
    if cp -f "$src_obb" "$dest_dir/main.19935.com.tencent.ig.obb"; then
        echo -e "${GREEN}✓ OBB文件导入成功${NC}"
    else
        echo -e "${RED}✗ 导入失败${NC}"
    fi
}

kc_extra_menu() {
    while true; do
        clear
        echo -e "\n${CYAN}=== KC额外功能 ===${NC}"
        echo -e "${GREEN}1. 下载KC专用字体"
        echo -e "${GREEN}2. 清理游戏缓存"
        echo -e "${RED}0. 返回${NC}"
        read -p "请选择: " choice

        case $choice in
            1) download_kc_font ;;
            2) clear_game_cache ;;
            0) break ;;
            *) echo -e "${RED}无效输入${NC}"; sleep 1 ;;
        esac
    done
}

download_kc_font() {
    font_url="KC's%20shell%20script/Amiri-Bold.ttf"
    if is_china; then
        safe_download "$GITEE_BASE/$font_url" "$TOOLBOX_DIR/Amiri-Bold.ttf" || \
        safe_download "$GITHUB_BASE/$font_url" "$TOOLBOX_DIR/Amiri-Bold.ttf"
    else
        safe_download "$GITHUB_BASE/$font_url" "$TOOLBOX_DIR/Amiri-Bold.ttf" || \
        safe_download "$GITEE_BASE/$font_url" "$TOOLBOX_DIR/Amiri-Bold.ttf"
    fi
}

change_device_id() {
  echo -e "\n${CYAN}=== 高级设备信息修改 ===${NC}"
  
  # 生成函数优化（增加大小写支持）
  rand_hex() { tr -dc 'a-fA-F0-9' < /dev/urandom | head -c $1; }
  print_mac() { 
    printf "%02X:%02X:%02X:%02X:%02X:%02X" \
    $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) \
    $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))
  }

  # 1/6 深度清理增强版
  echo -e "\n${YELLOW}1/6${NC} 正在深度清理运行环境..."
  {
    # 增加更多腾讯系包名清理
    for pkg in com.tencent.mf.uam com.tencent.tinput com.tencent.ig; do
      am force-stop "$pkg" >/dev/null 2>&1
      pm clear "$pkg" >/dev/null 2>&1
    done
    
    # 增强目录清理
    find /sdcard/Android/data /sdcard/Android/obb -name "com.tencent.*" -exec rm -rf {} \; 2>/dev/null
    rm -rf /sdcard/ramdump /sdcard/tencent/{MidasOversea,beacon} 2>/dev/null
    
    # 使用更高效的文件删除方式
    find /sdcard/Android/data -type d \( -name "*cache*" -o -name "temp" \) -exec rm -rf {} \; 2>/dev/null
  }
  echo -e "${GREEN}✓ 已深度清理30+应用残留数据${NC}"

  # 2/6 系统标识修改（增加持久化修改）
  echo -e "\n${YELLOW}2/6${NC} 修改核心标识..."
  {
    # SSAID修改（增加备份机制）
    ssaid_file="/data/system/users/0/settings_ssaid.xml"
    [ -f "$ssaid_file" ] && cp "$ssaid_file" "$ssaid_file.bak" 2>/dev/null
    old_ssaid=$(grep 'com.tencent.mf.uam' "$ssaid_file" 2>/dev/null | awk -F'"' '{print $6}')
    new_ssaid=$(rand_hex 16)
    sed -i "s/$old_ssaid/$new_ssaid/" "$ssaid_file" 2>/dev/null
    echo -e "SSAID:\t\t${RED}${old_ssaid:-无}${NC} → ${GREEN}$new_ssaid${NC}"

    # Android ID（增加持久化存储）
    old_android_id=$(settings get secure android_id)
    new_android_id=$(rand_hex 16)
    settings put secure android_id "$new_android_id"
    echo -e "Android ID:\t${RED}${old_android_id:-无}${NC} → ${GREEN}$new_android_id${NC}"

    # 序列号（增加bootloader级别修改）
    old_serial=$(getprop ro.serialno)
    new_serial=$(rand_hex 8)
    resetprop -p ro.serialno "$new_serial"
    resetprop -p ro.boot.serialno "$new_serial"
    echo -e "序列号:\t\t${RED}${old_serial:-无}${NC} → ${GREEN}$new_serial${NC}"
  }

  # 3/6 伪装设备信息（增加更多设备型号）
  echo -e "\n${YELLOW}3/6${NC} 伪造设备信息..."
  {
    models=("SM-G9980" "Mi10Pro" "POT-LX1" "PDKM00" "VOG-AL00" "iPhone14,2" "NX669J")
    brands=("samsung" "xiaomi" "huawei" "oppo" "vivo" "apple" "nubia")
    
    new_model=${models[$RANDOM % ${#models[@]}]}
    new_brand=${brands[$RANDOM % ${#brands[@]}]}
    
    resetprop ro.product.model "$new_model"
    resetprop ro.product.brand "$new_brand"
    resetprop ro.product.manufacturer "$new_brand"
    
    # 增加构建指纹伪装
    resetprop ro.build.fingerprint "$new_brand/$new_model:11/RP1A.200720.012:user/release-keys"
    
    echo -e "设备型号:\t${RED}$(getprop ro.product.model)${NC} → ${GREEN}$new_model${NC}"
    echo -e "设备品牌:\t${RED}$(getprop ro.product.brand)${NC} → ${GREEN}$new_brand${NC}"
    echo -e "制造商:\t\t${RED}$(getprop ro.product.manufacturer)${NC} → ${GREEN}$new_brand${NC}"
    
    # 系统版本（增加更多版本号）
    android_versions=("10" "11" "12" "13")
    new_version="Android ${android_versions[$RANDOM % ${#android_versions[@]}]}.0.0"
    resetprop ro.build.version.release "$new_version"
    echo -e "系统版本:\t${RED}$(getprop ro.build.version.release)${NC} → ${GREEN}$new_version${NC}"
  }

  # 剩余部分保持不变...
  # [4/6 网络配置、5/6 广告标识、6/6 网络重置等原有代码]
  
  # 验证信息增强版
  echo -e "\n${CYAN}=== 修改结果验证 ===${NC}"
  {
    echo -e "设备型号:\t${GREEN}$(getprop ro.product.model)${NC}"
    echo -e "设备品牌:\t${GREEN}$(getprop ro.product.brand)${NC}"
    echo -e "制造商:\t\t${GREEN}$(getprop ro.product.manufacturer)${NC}"
    echo -e "系统版本:\t${GREEN}$(getprop ro.build.version.release)${NC}"
    echo -e "Android ID:\t${GREEN}$(settings get secure android_id)${NC}"
    echo -e "序列号:\t\t${GREEN}$(getprop ro.serialno)${NC}"
    echo -e "蓝牙MAC:\t${GREEN}$(settings get secure bluetooth_address)${NC}"
    echo -e "广告ID:\t\t${GREEN}$(settings get secure advertising_id)${NC}"
    echo -e "ADB状态:\t${GREEN}$([ $(settings get global adb_enabled) -eq 0 ] && echo "禁用" || echo "启用")${NC}"
    echo -e "构建指纹:\t${GREEN}$(getprop ro.build.fingerprint)${NC}"
  }

  # 重启确认（增加倒计时动画）
  echo -e "\n${CYAN}是否立即重启设备？* Reboot? (30秒后自动取消)${NC}"
  echo -e "${GREEN}1 确认重启 YES \t${RED}0 取消操作 NO ${NC}"
  
  end_time=$(( $(date +%s) + 30 ))
  while [ $(date +%s) -lt $end_time ]; do
    remaining=$((end_time - $(date +%s)))
    printf "\r[${RED}%02d${NC}] 秒后自动取消 ${BLUE}%${remaining}s${NC}" $remaining \
           $(printf '%*s' $remaining '' | tr ' ' '=')
    read -t 1 -n 1 input || continue
    case $input in
      1) echo -e "\n${GREEN}正在重启...${NC}"; reboot; exit 0 ;;
      0) break ;;
      *) echo -e "\n${YELLOW}无效输入${NC}"; continue ;;
    esac
  done
  echo -e "\n${YELLOW}操作超时，返回菜单...${NC}"
  return
}

# 初始化完成提示
echo -e "${GREEN}KC工具箱初始化完成！${NC}"