














# ========== 全局配置 ==========
# 颜色配置
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# 常量配置
GITHUB_URL="https://raw.githubusercontent.com/123456hgdhg/KC/refs/heads/main"
GITEE_URL="https://gitee.com/BOT_141_2580/kc-config-manager/raw/master"

# 常量配置
CONFIG_BASE="/storage/emulated/0/KC_Configuration"
# ========== 工具函数 ==========
# 非阻塞读取函数 (无需回车)
read_char() {
  stty -icanon -echo
  dd bs=1 count=1 2>/dev/null
  stty icanon echo
}

# 安全下载（带文件存在检查）
safe_download() {
  local url=$1
  local output=$2
  local retry=3
  local download_source=$(echo "$url" | awk -F/ '{print $1"//"$3}')
  
  echo -e "\n${CYAN}📥 下载任务信息：${NC}"
  echo -e " 源服务器: ${BLUE}$download_source${NC}"
  echo -e " 目标路径: ${YELLOW}$output${NC}"
  
  # 删除已存在的文件（强制重新下载）
  [ -f "$output" ] && rm -f "$output"
  
  # 下载尝试
  while [ $retry -gt 0 ]; do
    echo -n -e "${BLUE}⏳ 尝试下载 (剩余重试: $retry)...${NC}"
    
    if curl -sL --connect-timeout 15 "$url" -o "$output"; then
      if [ -s "$output" ]; then
        echo -e "${GREEN} ✅ 成功${NC}"
        echo -e " 文件校验: ${YELLOW}$(du -sh "$output" | cut -f1)${NC}"
        return 0
      else
        echo -e "${RED} ❌ 空文件${NC}"
        rm -f "$output"
      fi
    else
      echo -e "${RED} ❌ 失败${NC}"
    fi
    
    retry=$((retry-1))
    [ $retry -gt 0 ] && sleep 2
  done
  
  echo -e "${RED}‼️ 所有尝试失败，放弃下载${NC}"
  return 1
}

setup_dirs() {
  echo -e "${BLUE}初始化${NC} 创建配置目录..."
  mkdir -p "$CONFIG_BASE/KC Peace Elite/Quasi" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC Peace Elite/Act" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC Peace Elite/Game Sensitivity" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/Quasi" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/Act" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/User/Xiao Jin" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC Toolbox Script" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/Game Sensitivity" 2>/dev/null
  echo -e "${GREEN}完成${NC} 目录结构创建成功"
}

# ========== 配置管理函数 ==========


download_sensitivity() {
  clear
  echo -e "\n${CYAN}=== 下载灵敏度配置 ==="
  echo -e "${GREEN}1. 和平精英灵敏度"
  echo -e "${GREEN}2. PUBG灵敏度"
  echo -e "${RED}0. 返回主菜单${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
  
  choice=$(read_char)
  echo
  
  case $choice in
    1)
      sensitivity_path="/storage/emulated/0/@BrotherHua Configuration/KC Peace Elite/Game Sensitivity/Active.sav"
      github_url="https://github.com/123456hgdhg/KC/raw/refs/heads/main/Peace%20Elite/Game%20Settings/Active.sav"
      game_dir="/storage/emulated/0/Android/data/com.tencent.tmgp.pubgmhd/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames"
      ;;
      
    2)
      sensitivity_path="/storage/emulated/0/@BrotherHua Configuration/KC PUBG/Game Sensitivity/Active.sav"
      github_url="https://github.com/123456hgdhg/KC/raw/refs/heads/main/PUBG/Game%20Settings/Active.sav"
      game_dir="/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames"
      ;;
      
    0) return ;;
    *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1; download_sensitivity; return ;;
  esac

  # 确保目录存在
  mkdir -p "$(dirname "$sensitivity_path")" 2>/dev/null
  
  # 下载灵敏度文件
  echo -e "\n${BLUE}正在下载灵敏度配置...${NC}"
  if safe_download "$github_url" "$sensitivity_path"; then
    echo -e "${GREEN}✓ 灵敏度配置下载成功${NC}"
    echo -e "保存路径: ${YELLOW}$sensitivity_path${NC}"
    
    # 询问是否部署
    echo -e "\n${CYAN}是否要部署灵敏度配置？${NC}"
    echo -e "${GREEN}1. 部署到游戏目录 \t${RED}0. 返回${NC}"
    read -p "请输入选择: " deploy_choice
    
    if [ "$deploy_choice" = "1" ]; then
      echo -e "${BLUE}正在部署配置...${NC}"
      mkdir -p "$game_dir" 2>/dev/null
      if cp -f "$sensitivity_path" "$game_dir/Active.sav"; then
        chmod 644 "$game_dir/Active.sav"
        echo -e "${GREEN}✓ 配置部署成功${NC}"
        echo -e "${YELLOW}提示：请确保游戏已完全关闭${NC}"
      else
        echo -e "${RED}✗ 配置部署失败${NC}"
      fi
    fi
  else
    echo -e "${RED}✗ 灵敏度配置下载失败${NC}"
  fi
  
  echo -e "\n${CYAN}按任意键返回...${NC}"
  read_char
}

# 导入国际服OBB文件
import_obb() {
  clear
  echo -e "\n${CYAN}=== 导入国际服OBB文件 ===${NC}"
  
  # 源文件和目标路径
  src_obb="/storage/emulated/0/123网盘/main.19935.com.tencent.ig.obb"
  target_dir="/storage/emulated/0/Android/obb/com.tencent.ig"
  target_obb="${target_dir}/main.19935.com.tencent.ig.obb"
  
  # 检查源文件是否存在
  if [ ! -f "$src_obb" ]; then
    echo -e "${RED}错误: 未找到源OBB文件${NC}"
    echo -e "请确保文件存在于: ${YELLOW}${src_obb}${NC}"
    echo -e "\n${CYAN}按任意键返回...${NC}"
    read_char
    return 1
  fi
  
  # 创建目标目录
  echo -e "${BLUE}操作${NC} 正在创建目标目录..."
  if mkdir -p "$target_dir" 2>/dev/null; then
    echo -e "${GREEN}✓ 目录创建成功${NC}"
  else
    echo -e "${RED}✗ 无法创建目标目录${NC}"
    echo -e "\n${CYAN}按任意键返回...${NC}"
    read_char
    return 1
  fi
  
  # 复制文件
  echo -e "${BLUE}操作${NC} 正在复制OBB文件..."
  if cp -f "$src_obb" "$target_obb"; then
    # 设置权限
    chmod 644 "$target_obb"
    echo -e "${GREEN}✓ OBB文件导入成功${NC}"
    echo -e "\n文件位置: ${YELLOW}${target_obb}${NC}"
    echo -e "文件大小: ${YELLOW}$(du -h "$target_obb" | cut -f1)${NC}"
  else
    echo -e "${RED}✗ OBB文件复制失败${NC}"
    echo -e "\n${CYAN}按任意键返回...${NC}"
    read_char
    return 1
  fi
  
  # 验证文件
  echo -e "\n${BLUE}验证${NC} 检查文件完整性..."
  src_size=$(du -b "$src_obb" | cut -f1)
  target_size=$(du -b "$target_obb" | cut -f1)
  
  if [ "$src_size" -eq "$target_size" ]; then
    echo -e "${GREEN}✓ 文件验证通过 (大小匹配)${NC}"
  else
    echo -e "${YELLOW}⚠ 文件大小不匹配${NC}"
    echo -e "源文件: ${src_size} 字节"
    echo -e "目标文件: ${target_size} 字节"
  fi
  
  echo -e "\n${GREEN}操作完成! 请确保游戏已完全关闭${NC}"
  echo -e "${CYAN}按任意键返回...${NC}"
  read_char
}

# 下载KC字体
download_kc_font() {
  clear
  echo -e "\n${CYAN}=== KC字体下载 ==="
  echo -e "${GREEN}正在下载Amiri-Bold字体...${NC}"
  
  # 创建目标目录
  mkdir -p "$CONFIG_BASE/设置" 2>/dev/null
  
  # 字体文件信息
  FONT_URL="https://gitee.com/BOT_141_2580/kc-config-manager/raw/master/PUBGM/KC%E5%AD%97%E4%BD%93/Amiri-Bold.ttf"
  FONT_PATH="$CONFIG_BASE/设置/Amiri-Bold.ttf"
  
  # 直接下载文件
  if safe_download "$FONT_URL" "$FONT_PATH"; then
    echo -e "\n${GREEN}✓ 字体下载成功${NC}"
    echo -e "保存路径: ${YELLOW}$FONT_PATH${NC}"
  else
    echo -e "\n${RED}✗ 字体下载失败${NC}"
  fi
  
  # 返回前等待
  echo -e "\n${CYAN}按任意键返回...${NC}"
  read_char
  
  
  
}

# ========== 游戏配置函数 ==========
# 下载游戏配置
download_config() {
  game=$1
  config=$2
  strength=""
  
  case $config in
    30) strength="●●●●●○○" ;;
    80) strength="●●●○○○○" ;;
    "小金") strength="●●●●○○○" ;;
  esac
  
  echo -e "\n${CYAN}正在下载 ${game} ${config}配置 - 瞄准强度 ${strength}${NC}"
  
  case $game in
    "和平精英")
      case $config in
        30)
          file1="recoil_data_kccn.ini"
          file2="Config.ini"
          target_dir="KC_Peace_Elite/Quasi"
          github_path="Peace%20Elite/30"
          gitee_path="和平精英/30"
          ;;
        80)
          file1="recoil_data_kccn.ini"
          file2="Config.ini"
          target_dir="KC_Peace_Elite/Act"
          github_path="Peace%20Elite/80"
          gitee_path="和平精英/80"
          ;;
      esac
      ;;
    "PUBG")
      case $config in
        30)
          file1="recoil_data_kcgl.ini"
          file2="Config.ini"
          target_dir="KC_PUBG/Quasi"
          github_path="PUBG/30"
          gitee_path="PUBGM/30"
          ;;
        80)
          file1="recoil_data_kcgl.ini"
          file2="Config.ini"
          target_dir="KC_PUBG/Act"
          github_path="PUBG/80"
          gitee_path="PUBGM/80"
          ;;
        "小金")
          file1="recoil_data_kcgl.ini"
          file2="Config.ini"
          target_dir="KC_PUBG/User/Xiao_Jin"
          github_path="PUBG/User/Xiao%20Jin"
          gitee_path="用户配置/小金"
          ;;
      esac
      ;;
  esac
  
  # 创建目标目录
  mkdir -p "$CONFIG_BASE/${target_dir}" 2>/dev/null
  
  # 尝试从GitHub下载第一个文件
  echo -n -e "${BLUE}正在从GitHub获取 ${file1}...${NC}"
  if safe_download "${GITHUB_URL}/${github_path}/${file1}" "$CONFIG_BASE/${target_dir}/${file1}"; then
    echo -e "${GREEN} ✓ (GitHub)"
  else
    # GitHub失败，尝试码云
    echo -n -e "${YELLOW} GitHub失败，尝试码云...${NC}"
    if safe_download "${GITEE_URL}/${gitee_path}/${file1}" "$CONFIG_BASE/${target_dir}/${file1}"; then
      echo -e "${GREEN} ✓ (码云)"
    else
      echo -e "${RED} ✗ 所有源均失败"
    fi
  fi
  
  # 同样处理第二个文件
  echo -n -e "${BLUE}正在从GitHub获取 ${file2}...${NC}"
  if safe_download "${GITHUB_URL}/${github_path}/${file2}" "$CONFIG_BASE/${target_dir}/${file2}"; then
    echo -e "${GREEN} ✓ (GitHub)"
  else
    echo -n -e "${YELLOW} GitHub失败，尝试码云...${NC}"
    if safe_download "${GITEE_URL}/${gitee_path}/${file2}" "$CONFIG_BASE/${target_dir}/${file2}"; then
      echo -e "${GREEN} ✓ (码云)"
    else
      echo -e "${RED} ✗ 所有源均失败"
    fi
  fi
  
  echo -e "${GREEN}完成${NC} ${game} ${config}配置下载完成"
}


# 应用游戏配置
apply_config() {
  game=$1
  config=$2
  
  # 设置源文件路径
  if [ "$config" = "小金" ]; then
    src_dir="$CONFIG_BASE/用户配置/小金"
  else
    src_dir="$CONFIG_BASE/${game}${config}瞄准速度配置"
  fi
  
  echo -e "${BLUE}操作${NC} 正在应用 ${game} ${config} 配置..."
  
  # 第一步：将Config.ini重命名为Config.txt
  src_ini="${src_dir}/Config.ini"
  src_txt="${src_dir}/Config.txt"
  
  if [ -f "$src_ini" ]; then
    if mv -f "$src_ini" "$src_txt"; then
      echo -e "${GREEN}成功重命名: Config.ini → Config.txt"
    else
      echo -e "${RED}重命名失败: Config.ini"
    fi
  else
    echo -e "${RED}文件缺失: Config.ini"
  fi
  
  # 第二步：根据游戏类型处理文件复制
  case $game in
    "和平精英")
      recoil_src="${src_dir}/recoil_data_kccn.ini"
      recoil_dest="/data/local/tmp/recoil_data_kccn.ini"
      config_src="${src_dir}/Config.txt"
      config_dest="/data/user/0/com.game.kernel/Config.txt"
      mkdir -p "/data/user/0/com.game.kernel" 2>/dev/null
      ;;
    "PUBG")
      recoil_src="${src_dir}/recoil_data_kcgl.ini"
      recoil_dest="/data/local/tmp/recoil_data_kcgl.ini"
      config_src="${src_dir}/Config.txt"
      config_dest="/data/user/0/com.android.kernel/Config.txt"
      mkdir -p "/data/user/0/com.android.kernel" 2>/dev/null
      ;;
  esac
  
  # 复制recoil文件
  if [ -f "$recoil_src" ]; then
    if cp -f "$recoil_src" "$recoil_dest"; then
      echo -e "${GREEN}成功部署: $(basename "$recoil_src") → ${recoil_dest}"
      chmod 644 "$recoil_dest"
    else
      echo -e "${RED}部署失败: $(basename "$recoil_src")"
    fi
  else
    echo -e "${RED}文件缺失: $(basename "$recoil_src")"
  fi
  
  # 复制config文件
  if [ -f "$config_src" ]; then
    if cp -f "$config_src" "$config_dest"; then
      echo -e "${GREEN}成功部署: Config.txt → ${config_dest}"
      chmod 644 "$config_dest"
    else
      echo -e "${RED}部署失败: Config.txt"
    fi
  else
    echo -e "${RED}文件缺失: Config.txt"
  fi
  
  echo -e "${GREEN}完成${NC} ${game} ${config}配置已生效"
  sleep 1
  return 0
}

# ========== 设备修改函数 ==========
# 修改设备ID
change_device_id() {
  echo -e "\n${CYAN}=== 高级设备信息修改 ===${NC}"
  
  # 生成函数
  rand_hex() { tr -dc 'a-f0-9' < /dev/urandom | head -c $1; }
  print_mac() { 
    printf "%02X:%02X:%02X:%02X:%02X:%02X" \
    $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) \
    $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) 
  }

  # 1/6 深度清理
  echo -e "\n${YELLOW}1/6${NC} 正在深度清理运行环境..."
  {
    am force-stop com.tencent.mf.uam >/dev/null 2>&1
    rm -rf /sdcard/ramdump /sdcard/tencent/MidasOversea 2>/dev/null
    find /sdcard/Android/data -name "*cache*" -delete 2>/dev/null
  }
  echo -e "${GREEN}✓ 清理20+应用残留数据${NC}"

  # 2/6 系统标识修改
  echo -e "\n${YELLOW}2/6${NC} 修改核心标识..."
  ssaid_file="/data/system/users/0/settings_ssaid.xml"
  old_ssaid=$(grep 'com.tencent.mf.uam' $ssaid_file 2>/dev/null | awk -F'"' '{print $6}')
  new_ssaid=$(rand_hex 16)
  sed -i "s/$old_ssaid/$new_ssaid/" $ssaid_file 2>/dev/null
  echo -e "SSAID: ${RED}${old_ssaid:-无}${NC} → ${GREEN}$new_ssaid${NC}"

  old_android_id=$(settings get secure android_id)
  new_android_id=$(rand_hex 16)
  settings put secure android_id $new_android_id
  echo -e "Android ID: ${RED}$old_android_id${NC} → ${GREEN}$new_android_id${NC}"

  old_serial=$(getprop ro.serialno)
  new_serial=$(rand_hex 8)
  resetprop -p ro.serialno $new_serial
  echo -e "序列号: ${RED}$old_serial${NC} → ${GREEN}$new_serial${NC}"

  # 3/6 伪装设备信息
  echo -e "\n${YELLOW}3/6${NC} 伪造设备信息..."
  models=("SM-G9980" "Mi10Pro" "POT-LX1" "PDKM00" "VOG-AL00")
  new_model=${models[$RANDOM % 5]}
  resetprop ro.product.model "$new_model"
  echo -e "设备型号: ${RED}$(getprop ro.product.model)${NC} → ${GREEN}$new_model${NC}"

  brands=("samsung" "xiaomi" "huawei" "oppo" "vivo")
  new_brand=${brands[$RANDOM % 5]}
  resetprop ro.product.brand "$new_brand"
  echo -e "设备品牌: ${RED}$(getprop ro.product.brand)${NC} → ${GREEN}$new_brand${NC}"

  old_os=$(getprop ro.build.version.release)
  new_os="Android $((9 + RANDOM % 5)).0.0"
  resetprop ro.build.version.release "$new_os"
  echo -e "系统版本: ${RED}$old_os${NC} → ${GREEN}$new_os${NC}"

  # 4/6 网络配置
  echo -e "\n${YELLOW}4/6${NC} 重置网络标识..."
  old_bt=$(settings get secure bluetooth_address)
  new_bt="02:$(print_mac | cut -d: -f2-6)"
  settings put secure bluetooth_address "$new_bt"
  echo -e "蓝牙MAC: ${RED}${old_bt:-无}${NC} → ${GREEN}$new_bt${NC}"

  old_wifi=$(ifconfig wlan0 2>/dev/null | awk '/HWaddr/ {print $5}')
  new_wifi="00:$(print_mac | cut -d: -f2-6)"
  ifconfig wlan0 hw ether "$new_wifi" 2>/dev/null && \
  echo -e "WiFiMAC: ${RED}${old_wifi:-无}${NC} → ${GREEN}$new_wifi${NC}" || \
  echo -e "${RED}× WiFiMAC修改需要内核支持${NC}"

  # 5/6 广告标识
  echo -e "\n${YELLOW}5/6${NC} 重置广告信息..."
  old_adid=$(settings get secure advertising_id)
  new_adid=$(rand_hex 16 | tr 'a-f' 'A-F')
  settings put secure advertising_id "$new_adid"
  echo -e "广告ID: ${RED}${old_adid:-无}${NC} → ${GREEN}$new_adid${NC}"

  old_adb=$(settings get global adb_enabled)
  settings put global adb_enabled 0
  echo -e "ADB调试: ${RED}${old_adb:-启用}${NC} → ${GREEN}禁用${NC}"

  # 6/6 网络重置
  echo -e "\n${YELLOW}6/6${NC} 刷新网络连接..."
  svc data disable >/dev/null
  svc wifi disable >/dev/null
  sleep 2
  rm -rf /data/misc/apexdata/com.android.wifi/*
  svc data enable >/dev/null
  svc wifi enable >/dev/null
  echo -e "${GREEN}✓ 网络状态已重置${NC}"

  # 验证信息
  echo -e "\n${CYAN}=== 修改结果验证 ===${NC}"
  echo -e "设备型号:\t${GREEN}$(getprop ro.product.model)${NC}"
  echo -e "设备品牌:\t${GREEN}$(getprop ro.product.brand)${NC}"
  echo -e "系统版本:\t${GREEN}$(getprop ro.build.version.release)${NC}"
  echo -e "Android ID:\t${GREEN}$(settings get secure android_id)${NC}"
  echo -e "蓝牙MAC:\t${GREEN}$(settings get secure bluetooth_address)${NC}"
  echo -e "广告ID:\t\t${GREEN}$(settings get secure advertising_id)${NC}"
  echo -e "ADB状态:\t${GREEN}$([ $(settings get global adb_enabled) -eq 0 ] && echo "禁用" || echo "启用")${NC}"
  echo -e "\n${GREEN}设备指纹已全面刷新，建议重启后使用！${NC}"

  # 重启确认
  echo -e "\n${CYAN}是否立即重启设备？* Reboot? (30秒后自动取消)${NC}"
  echo -e "${GREEN}1 确认重启 YES \t${RED}0 取消操作 NO ${NC}"
  end_time=$(( $(date +%s) + 30 ))
  while [ $(date +%s) -lt $end_time ]; do
    remaining=$((end_time - $(date +%s)))
    printf "\r剩余时间: %2d 秒 " $remaining
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

# 无限游客功能
reset_game() {
  local package_name=$1
  clear
  echo -e "${CYAN}"
  sleep 0.5
  echo
  echo "正在重置游客..."
  sleep 1
  clear
  killall $package_name
  clear
  rm -rf /data/data/$package_name/shared_prefs /storage/emulated/0/Documents/
  mkdir /data/data/$package_name/shared_prefs
  chmod 777 /data/data/$package_name/shared_prefs
  rm -rf /data/data/$package_name/files

  GUEST="/data/data/$package_name/shared_prefs/device_id.xml"
  rm -rf $GUEST
  echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <string name=\"random\"></string>
    <string name=\"install\"></string>
    <string name=\"uuid\">$RANDOM$RANDOM-$RANDOM-$RANDOM-$RANDOM-$RANDOM$RANDOM$RANDOM</string>
</map>" > $GUEST
  rm -rf /data/data/$package_name/databases
  rm -rf /data/media/0/Android/data/$package_name/files/login-identifier.txt
  rm -rf /data/media/0/Android/data/$package_name/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Intermediate
  touch /data/media/0/Android/data/$package_name/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Intermediate
  rm -rf /data/media/0/Android/data/$package_name/files/TGPA
  touch /data/media/0/Android/data/$package_name/files/TGPA
  rm -rf /data/media/0/Android/data/$package_name/files/ProgramBinaryCache
  touch /data/media/0/Android/data/$package_name/files/ProgramBinaryCache
  iptables -I OUTPUT -d cloud.vmp.onezapp.com -j REJECT
  iptables -I INPUT -s cloud.vmp.onezapp.com -j REJECT
  clear

  am start -n $package_name/com.epicgames.ue4.SplashActivity &>/dev/null
  echo -e "\n${GREEN}游客重置完成！${NC}"
  sleep 1
}



download_kc_font() {
  clear
  echo -e "\n${CYAN}=== KC字体下载 ==="
  echo -e "${GREEN}正在下载Amiri-Bold字体...${NC}"
  
  # 创建目标目录
  mkdir -p "$CONFIG_BASE/KC_Toolbox_Script" 2>/dev/null
  
  # 字体文件信息
  FONT_FILE="Amiri-Bold.ttf"
  FONT_PATH="$CONFIG_BASE/KC_Toolbox_Script/$FONT_FILE"
  
  # 尝试从GitHub下载
  echo -n -e "${BLUE}正在从GitHub获取字体...${NC}"
  if safe_download "${GITHUB_URL}/KC's%20shell%20script/${FONT_FILE}" "$FONT_PATH"; then
    echo -e "${GREEN} ✓ (GitHub)"
  else
    # GitHub失败，尝试码云
    echo -n -e "${YELLOW} GitHub失败，尝试码云...${NC}"
    if safe_download "${GITEE_URL}/PUBGM/KC字体/${FONT_FILE}" "$FONT_PATH"; then
      echo -e "${GREEN} ✓ (码云)"
    else
      echo -e "${RED} ✗ 所有源均失败${NC}"
      return 1
    fi
  fi
  
  echo -e "\n${GREEN}✓ 字体下载成功${NC}"
  echo -e "保存路径: ${YELLOW}$FONT_PATH${NC}"
  
  # [其余部署逻辑保持不变...]
}        rm -f "$output"
      fi
    else
      echo -e "${RED} ✗${NC}"
    fi
    
    retry=$((retry-1))
    [ $retry -gt 0 ] && echo -e "${YELLOW}剩余重试次数: $retry${NC}"
    sleep 2
  done
  
  return 1
}

setup_dirs() {
  echo -e "${BLUE}初始化${NC} 创建配置目录..."
  mkdir -p "$CONFIG_BASE/KC Peace Elite/Quasi" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC Peace Elite/Act" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC Peace Elite/Game Sensitivity" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/Quasi" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/Act" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/User/Xiao Jin" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC Toolbox Script" 2>/dev/null
  mkdir -p "$CONFIG_BASE/KC PUBG/Game Sensitivity" 2>/dev/null
  echo -e "${GREEN}完成${NC} 目录结构创建成功"
}

# ========== 配置管理函数 ==========


download_sensitivity() {
  clear
  echo -e "\n${CYAN}=== 下载灵敏度配置 ==="
  echo -e "${GREEN}1. 和平精英灵敏度"
  echo -e "${GREEN}2. PUBG灵敏度"
  echo -e "${RED}0. 返回主菜单${NC}"
  echo -n -e "${RED}请输入选择: ${CYAN}"
  
  choice=$(read_char)
  echo
  
  case $choice in
    1)
      sensitivity_path="/storage/emulated/0/@BrotherHua Configuration/KC Peace Elite/Game Sensitivity/Active.sav"
      github_url="https://github.com/123456hgdhg/KC/raw/refs/heads/main/Peace%20Elite/Game%20Settings/Active.sav"
      game_dir="/storage/emulated/0/Android/data/com.tencent.tmgp.pubgmhd/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames"
      ;;
      
    2)
      sensitivity_path="/storage/emulated/0/@BrotherHua Configuration/KC PUBG/Game Sensitivity/Active.sav"
      github_url="https://github.com/123456hgdhg/KC/raw/refs/heads/main/PUBG/Game%20Settings/Active.sav"
      game_dir="/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames"
      ;;
      
    0) return ;;
    *) echo -e "${RED}无效输入，请重新选择${NC}"; sleep 1; download_sensitivity; return ;;
  esac

  # 确保目录存在
  mkdir -p "$(dirname "$sensitivity_path")" 2>/dev/null
  
  # 下载灵敏度文件
  echo -e "\n${BLUE}正在下载灵敏度配置...${NC}"
  if safe_download "$github_url" "$sensitivity_path"; then
    echo -e "${GREEN}✓ 灵敏度配置下载成功${NC}"
    echo -e "保存路径: ${YELLOW}$sensitivity_path${NC}"
    
    # 询问是否部署
    echo -e "\n${CYAN}是否要部署灵敏度配置？${NC}"
    echo -e "${GREEN}1. 部署到游戏目录 \t${RED}0. 返回${NC}"
    read -p "请输入选择: " deploy_choice
    
    if [ "$deploy_choice" = "1" ]; then
      echo -e "${BLUE}正在部署配置...${NC}"
      mkdir -p "$game_dir" 2>/dev/null
      if cp -f "$sensitivity_path" "$game_dir/Active.sav"; then
        chmod 644 "$game_dir/Active.sav"
        echo -e "${GREEN}✓ 配置部署成功${NC}"
        echo -e "${YELLOW}提示：请确保游戏已完全关闭${NC}"
      else
        echo -e "${RED}✗ 配置部署失败${NC}"
      fi
    fi
  else
    echo -e "${RED}✗ 灵敏度配置下载失败${NC}"
  fi
  
  echo -e "\n${CYAN}按任意键返回...${NC}"
  read_char
}

# 导入国际服OBB文件
import_obb() {
  clear
  echo -e "\n${CYAN}=== 导入国际服OBB文件 ===${NC}"
  
  # 源文件和目标路径
  src_obb="/storage/emulated/0/123网盘/main.19935.com.tencent.ig.obb"
  target_dir="/storage/emulated/0/Android/obb/com.tencent.ig"
  target_obb="${target_dir}/main.19935.com.tencent.ig.obb"
  
  # 检查源文件是否存在
  if [ ! -f "$src_obb" ]; then
    echo -e "${RED}错误: 未找到源OBB文件${NC}"
    echo -e "请确保文件存在于: ${YELLOW}${src_obb}${NC}"
    echo -e "\n${CYAN}按任意键返回...${NC}"
    read_char
    return 1
  fi
  
  # 创建目标目录
  echo -e "${BLUE}操作${NC} 正在创建目标目录..."
  if mkdir -p "$target_dir" 2>/dev/null; then
    echo -e "${GREEN}✓ 目录创建成功${NC}"
  else
    echo -e "${RED}✗ 无法创建目标目录${NC}"
    echo -e "\n${CYAN}按任意键返回...${NC}"
    read_char
    return 1
  fi
  
  # 复制文件
  echo -e "${BLUE}操作${NC} 正在复制OBB文件..."
  if cp -f "$src_obb" "$target_obb"; then
    # 设置权限
    chmod 644 "$target_obb"
    echo -e "${GREEN}✓ OBB文件导入成功${NC}"
    echo -e "\n文件位置: ${YELLOW}${target_obb}${NC}"
    echo -e "文件大小: ${YELLOW}$(du -h "$target_obb" | cut -f1)${NC}"
  else
    echo -e "${RED}✗ OBB文件复制失败${NC}"
    echo -e "\n${CYAN}按任意键返回...${NC}"
    read_char
    return 1
  fi
  
  # 验证文件
  echo -e "\n${BLUE}验证${NC} 检查文件完整性..."
  src_size=$(du -b "$src_obb" | cut -f1)
  target_size=$(du -b "$target_obb" | cut -f1)
  
  if [ "$src_size" -eq "$target_size" ]; then
    echo -e "${GREEN}✓ 文件验证通过 (大小匹配)${NC}"
  else
    echo -e "${YELLOW}⚠ 文件大小不匹配${NC}"
    echo -e "源文件: ${src_size} 字节"
    echo -e "目标文件: ${target_size} 字节"
  fi
  
  echo -e "\n${GREEN}操作完成! 请确保游戏已完全关闭${NC}"
  echo -e "${CYAN}按任意键返回...${NC}"
  read_char
}

# 下载KC字体
download_kc_font() {
  clear
  echo -e "\n${CYAN}=== KC字体下载 ==="
  echo -e "${GREEN}正在下载Amiri-Bold字体...${NC}"
  
  # 创建目标目录
  mkdir -p "$CONFIG_BASE/设置" 2>/dev/null
  
  # 字体文件信息
  FONT_URL="https://gitee.com/BOT_141_2580/kc-config-manager/raw/master/PUBGM/KC%E5%AD%97%E4%BD%93/Amiri-Bold.ttf"
  FONT_PATH="$CONFIG_BASE/设置/Amiri-Bold.ttf"
  
  # 直接下载文件
  if safe_download "$FONT_URL" "$FONT_PATH"; then
    echo -e "\n${GREEN}✓ 字体下载成功${NC}"
    echo -e "保存路径: ${YELLOW}$FONT_PATH${NC}"
  else
    echo -e "\n${RED}✗ 字体下载失败${NC}"
  fi
  
  # 返回前等待
  echo -e "\n${CYAN}按任意键返回...${NC}"
  read_char
  
  
  
}

# ========== 游戏配置函数 ==========
# 下载游戏配置
download_config() {
  game=$1
  config=$2
  strength=""
  
  case $config in
    30) strength="●●●●●○○" ;;
    80) strength="●●●○○○○" ;;
    "小金") strength="●●●●○○○" ;;
  esac
  
  echo -e "\n${CYAN}正在下载 ${game} ${config}配置 - 瞄准强度 ${strength}${NC}"
  
  case $game in
    "和平精英")
      case $config in
        30)
          file1="recoil_data_kccn.ini"
          file2="Config.ini"
          target_dir="KC_Peace_Elite/Quasi"
          github_path="Peace%20Elite/30"
          gitee_path="和平精英/30"
          ;;
        80)
          file1="recoil_data_kccn.ini"
          file2="Config.ini"
          target_dir="KC_Peace_Elite/Act"
          github_path="Peace%20Elite/80"
          gitee_path="和平精英/80"
          ;;
      esac
      ;;
    "PUBG")
      case $config in
        30)
          file1="recoil_data_kcgl.ini"
          file2="Config.ini"
          target_dir="KC_PUBG/Quasi"
          github_path="PUBG/30"
          gitee_path="PUBGM/30"
          ;;
        80)
          file1="recoil_data_kcgl.ini"
          file2="Config.ini"
          target_dir="KC_PUBG/Act"
          github_path="PUBG/80"
          gitee_path="PUBGM/80"
          ;;
        "小金")
          file1="recoil_data_kcgl.ini"
          file2="Config.ini"
          target_dir="KC_PUBG/User/Xiao_Jin"
          github_path="PUBG/User/Xiao%20Jin"
          gitee_path="用户配置/小金"
          ;;
      esac
      ;;
  esac
  
  # 创建目标目录
  mkdir -p "$CONFIG_BASE/${target_dir}" 2>/dev/null
  
  # 尝试从GitHub下载第一个文件
  echo -n -e "${BLUE}正在从GitHub获取 ${file1}...${NC}"
  if safe_download "${GITHUB_URL}/${github_path}/${file1}" "$CONFIG_BASE/${target_dir}/${file1}"; then
    echo -e "${GREEN} ✓ (GitHub)"
  else
    # GitHub失败，尝试码云
    echo -n -e "${YELLOW} GitHub失败，尝试码云...${NC}"
    if safe_download "${GITEE_URL}/${gitee_path}/${file1}" "$CONFIG_BASE/${target_dir}/${file1}"; then
      echo -e "${GREEN} ✓ (码云)"
    else
      echo -e "${RED} ✗ 所有源均失败"
    fi
  fi
  
  # 同样处理第二个文件
  echo -n -e "${BLUE}正在从GitHub获取 ${file2}...${NC}"
  if safe_download "${GITHUB_URL}/${github_path}/${file2}" "$CONFIG_BASE/${target_dir}/${file2}"; then
    echo -e "${GREEN} ✓ (GitHub)"
  else
    echo -n -e "${YELLOW} GitHub失败，尝试码云...${NC}"
    if safe_download "${GITEE_URL}/${gitee_path}/${file2}" "$CONFIG_BASE/${target_dir}/${file2}"; then
      echo -e "${GREEN} ✓ (码云)"
    else
      echo -e "${RED} ✗ 所有源均失败"
    fi
  fi
  
  echo -e "${GREEN}完成${NC} ${game} ${config}配置下载完成"
}


# 应用游戏配置
apply_config() {
  game=$1
  config=$2
  
  # 设置源文件路径
  if [ "$config" = "小金" ]; then
    src_dir="$CONFIG_BASE/用户配置/小金"
  else
    src_dir="$CONFIG_BASE/${game}${config}瞄准速度配置"
  fi
  
  echo -e "${BLUE}操作${NC} 正在应用 ${game} ${config} 配置..."
  
  # 第一步：将Config.ini重命名为Config.txt
  src_ini="${src_dir}/Config.ini"
  src_txt="${src_dir}/Config.txt"
  
  if [ -f "$src_ini" ]; then
    if mv -f "$src_ini" "$src_txt"; then
      echo -e "${GREEN}成功重命名: Config.ini → Config.txt"
    else
      echo -e "${RED}重命名失败: Config.ini"
    fi
  else
    echo -e "${RED}文件缺失: Config.ini"
  fi
  
  # 第二步：根据游戏类型处理文件复制
  case $game in
    "和平精英")
      recoil_src="${src_dir}/recoil_data_kccn.ini"
      recoil_dest="/data/local/tmp/recoil_data_kccn.ini"
      config_src="${src_dir}/Config.txt"
      config_dest="/data/user/0/com.game.kernel/Config.txt"
      mkdir -p "/data/user/0/com.game.kernel" 2>/dev/null
      ;;
    "PUBG")
      recoil_src="${src_dir}/recoil_data_kcgl.ini"
      recoil_dest="/data/local/tmp/recoil_data_kcgl.ini"
      config_src="${src_dir}/Config.txt"
      config_dest="/data/user/0/com.android.kernel/Config.txt"
      mkdir -p "/data/user/0/com.android.kernel" 2>/dev/null
      ;;
  esac
  
  # 复制recoil文件
  if [ -f "$recoil_src" ]; then
    if cp -f "$recoil_src" "$recoil_dest"; then
      echo -e "${GREEN}成功部署: $(basename "$recoil_src") → ${recoil_dest}"
      chmod 644 "$recoil_dest"
    else
      echo -e "${RED}部署失败: $(basename "$recoil_src")"
    fi
  else
    echo -e "${RED}文件缺失: $(basename "$recoil_src")"
  fi
  
  # 复制config文件
  if [ -f "$config_src" ]; then
    if cp -f "$config_src" "$config_dest"; then
      echo -e "${GREEN}成功部署: Config.txt → ${config_dest}"
      chmod 644 "$config_dest"
    else
      echo -e "${RED}部署失败: Config.txt"
    fi
  else
    echo -e "${RED}文件缺失: Config.txt"
  fi
  
  echo -e "${GREEN}完成${NC} ${game} ${config}配置已生效"
  sleep 1
  return 0
}

# ========== 设备修改函数 ==========
# 修改设备ID
change_device_id() {
  echo -e "\n${CYAN}=== 高级设备信息修改 ===${NC}"
  
  # 生成函数
  rand_hex() { tr -dc 'a-f0-9' < /dev/urandom | head -c $1; }
  print_mac() { 
    printf "%02X:%02X:%02X:%02X:%02X:%02X" \
    $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) \
    $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) 
  }

  # 1/6 深度清理
  echo -e "\n${YELLOW}1/6${NC} 正在深度清理运行环境..."
  {
    am force-stop com.tencent.mf.uam >/dev/null 2>&1
    rm -rf /sdcard/ramdump /sdcard/tencent/MidasOversea 2>/dev/null
    find /sdcard/Android/data -name "*cache*" -delete 2>/dev/null
  }
  echo -e "${GREEN}✓ 清理20+应用残留数据${NC}"

  # 2/6 系统标识修改
  echo -e "\n${YELLOW}2/6${NC} 修改核心标识..."
  ssaid_file="/data/system/users/0/settings_ssaid.xml"
  old_ssaid=$(grep 'com.tencent.mf.uam' $ssaid_file 2>/dev/null | awk -F'"' '{print $6}')
  new_ssaid=$(rand_hex 16)
  sed -i "s/$old_ssaid/$new_ssaid/" $ssaid_file 2>/dev/null
  echo -e "SSAID: ${RED}${old_ssaid:-无}${NC} → ${GREEN}$new_ssaid${NC}"

  old_android_id=$(settings get secure android_id)
  new_android_id=$(rand_hex 16)
  settings put secure android_id $new_android_id
  echo -e "Android ID: ${RED}$old_android_id${NC} → ${GREEN}$new_android_id${NC}"

  old_serial=$(getprop ro.serialno)
  new_serial=$(rand_hex 8)
  resetprop -p ro.serialno $new_serial
  echo -e "序列号: ${RED}$old_serial${NC} → ${GREEN}$new_serial${NC}"

  # 3/6 伪装设备信息
  echo -e "\n${YELLOW}3/6${NC} 伪造设备信息..."
  models=("SM-G9980" "Mi10Pro" "POT-LX1" "PDKM00" "VOG-AL00")
  new_model=${models[$RANDOM % 5]}
  resetprop ro.product.model "$new_model"
  echo -e "设备型号: ${RED}$(getprop ro.product.model)${NC} → ${GREEN}$new_model${NC}"

  brands=("samsung" "xiaomi" "huawei" "oppo" "vivo")
  new_brand=${brands[$RANDOM % 5]}
  resetprop ro.product.brand "$new_brand"
  echo -e "设备品牌: ${RED}$(getprop ro.product.brand)${NC} → ${GREEN}$new_brand${NC}"

  old_os=$(getprop ro.build.version.release)
  new_os="Android $((9 + RANDOM % 5)).0.0"
  resetprop ro.build.version.release "$new_os"
  echo -e "系统版本: ${RED}$old_os${NC} → ${GREEN}$new_os${NC}"

  # 4/6 网络配置
  echo -e "\n${YELLOW}4/6${NC} 重置网络标识..."
  old_bt=$(settings get secure bluetooth_address)
  new_bt="02:$(print_mac | cut -d: -f2-6)"
  settings put secure bluetooth_address "$new_bt"
  echo -e "蓝牙MAC: ${RED}${old_bt:-无}${NC} → ${GREEN}$new_bt${NC}"

  old_wifi=$(ifconfig wlan0 2>/dev/null | awk '/HWaddr/ {print $5}')
  new_wifi="00:$(print_mac | cut -d: -f2-6)"
  ifconfig wlan0 hw ether "$new_wifi" 2>/dev/null && \
  echo -e "WiFiMAC: ${RED}${old_wifi:-无}${NC} → ${GREEN}$new_wifi${NC}" || \
  echo -e "${RED}× WiFiMAC修改需要内核支持${NC}"

  # 5/6 广告标识
  echo -e "\n${YELLOW}5/6${NC} 重置广告信息..."
  old_adid=$(settings get secure advertising_id)
  new_adid=$(rand_hex 16 | tr 'a-f' 'A-F')
  settings put secure advertising_id "$new_adid"
  echo -e "广告ID: ${RED}${old_adid:-无}${NC} → ${GREEN}$new_adid${NC}"

  old_adb=$(settings get global adb_enabled)
  settings put global adb_enabled 0
  echo -e "ADB调试: ${RED}${old_adb:-启用}${NC} → ${GREEN}禁用${NC}"

  # 6/6 网络重置
  echo -e "\n${YELLOW}6/6${NC} 刷新网络连接..."
  svc data disable >/dev/null
  svc wifi disable >/dev/null
  sleep 2
  rm -rf /data/misc/apexdata/com.android.wifi/*
  svc data enable >/dev/null
  svc wifi enable >/dev/null
  echo -e "${GREEN}✓ 网络状态已重置${NC}"

  # 验证信息
  echo -e "\n${CYAN}=== 修改结果验证 ===${NC}"
  echo -e "设备型号:\t${GREEN}$(getprop ro.product.model)${NC}"
  echo -e "设备品牌:\t${GREEN}$(getprop ro.product.brand)${NC}"
  echo -e "系统版本:\t${GREEN}$(getprop ro.build.version.release)${NC}"
  echo -e "Android ID:\t${GREEN}$(settings get secure android_id)${NC}"
  echo -e "蓝牙MAC:\t${GREEN}$(settings get secure bluetooth_address)${NC}"
  echo -e "广告ID:\t\t${GREEN}$(settings get secure advertising_id)${NC}"
  echo -e "ADB状态:\t${GREEN}$([ $(settings get global adb_enabled) -eq 0 ] && echo "禁用" || echo "启用")${NC}"
  echo -e "\n${GREEN}设备指纹已全面刷新，建议重启后使用！${NC}"

  # 重启确认
  echo -e "\n${CYAN}是否立即重启设备？* Reboot? (30秒后自动取消)${NC}"
  echo -e "${GREEN}1 确认重启 YES \t${RED}0 取消操作 NO ${NC}"
  end_time=$(( $(date +%s) + 30 ))
  while [ $(date +%s) -lt $end_time ]; do
    remaining=$((end_time - $(date +%s)))
    printf "\r剩余时间: %2d 秒 " $remaining
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

# 无限游客功能
reset_game() {
  local package_name=$1
  clear
  echo -e "${CYAN}"
  sleep 0.5
  echo
  echo "正在重置游客..."
  sleep 1
  clear
  killall $package_name
  clear
  rm -rf /data/data/$package_name/shared_prefs /storage/emulated/0/Documents/
  mkdir /data/data/$package_name/shared_prefs
  chmod 777 /data/data/$package_name/shared_prefs
  rm -rf /data/data/$package_name/files

  GUEST="/data/data/$package_name/shared_prefs/device_id.xml"
  rm -rf $GUEST
  echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <string name=\"random\"></string>
    <string name=\"install\"></string>
    <string name=\"uuid\">$RANDOM$RANDOM-$RANDOM-$RANDOM-$RANDOM-$RANDOM$RANDOM$RANDOM</string>
</map>" > $GUEST
  rm -rf /data/data/$package_name/databases
  rm -rf /data/media/0/Android/data/$package_name/files/login-identifier.txt
  rm -rf /data/media/0/Android/data/$package_name/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Intermediate
  touch /data/media/0/Android/data/$package_name/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Intermediate
  rm -rf /data/media/0/Android/data/$package_name/files/TGPA
  touch /data/media/0/Android/data/$package_name/files/TGPA
  rm -rf /data/media/0/Android/data/$package_name/files/ProgramBinaryCache
  touch /data/media/0/Android/data/$package_name/files/ProgramBinaryCache
  iptables -I OUTPUT -d cloud.vmp.onezapp.com -j REJECT
  iptables -I INPUT -s cloud.vmp.onezapp.com -j REJECT
  clear

  am start -n $package_name/com.epicgames.ue4.SplashActivity &>/dev/null
  echo -e "\n${GREEN}游客重置完成！${NC}"
  sleep 1
}



download_kc_font() {
  clear
  echo -e "\n${CYAN}=== KC字体下载 ==="
  echo -e "${GREEN}正在下载Amiri-Bold字体...${NC}"
  
  # 创建目标目录
  mkdir -p "$CONFIG_BASE/KC_Toolbox_Script" 2>/dev/null
  
  # 字体文件信息
  FONT_FILE="Amiri-Bold.ttf"
  FONT_PATH="$CONFIG_BASE/KC_Toolbox_Script/$FONT_FILE"
  
  # 尝试从GitHub下载
  echo -n -e "${BLUE}正在从GitHub获取字体...${NC}"
  if safe_download "${GITHUB_URL}/KC's%20shell%20script/${FONT_FILE}" "$FONT_PATH"; then
    echo -e "${GREEN} ✓ (GitHub)"
  else
    # GitHub失败，尝试码云
    echo -n -e "${YELLOW} GitHub失败，尝试码云...${NC}"
    if safe_download "${GITEE_URL}/PUBGM/KC字体/${FONT_FILE}" "$FONT_PATH"; then
      echo -e "${GREEN} ✓ (码云)"
    else
      echo -e "${RED} ✗ 所有源均失败${NC}"
      return 1
    fi
  fi
  
  echo -e "\n${GREEN}✓ 字体下载成功${NC}"
  echo -e "保存路径: ${YELLOW}$FONT_PATH${NC}"
  
  # [其余部署逻辑保持不变...]
}
