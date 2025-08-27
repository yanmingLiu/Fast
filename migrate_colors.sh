#!/bin/bash

# 颜色迁移脚本
# 批量替换项目中的硬编码颜色值为AppColors

echo "开始批量颜色迁移..."

# 需要迁移的文件列表
files=(
    "lib/component/app_dialog.dart"
    "lib/component/f_login_reward_dialog.dart"
    "lib/component/f_progress.dart"
    "lib/pages/chat/audio_container.dart"
    "lib/pages/chat/chat_page.dart"
    "lib/pages/chat/gift_page.dart"
    "lib/pages/chat/mask_edit_page.dart"
    "lib/pages/chat/mask_page.dart"
    "lib/pages/chat/phone_guide_page.dart"
)

# 颜色替换对照表
declare -A color_map=(
    ["Color(0xFF3F8DFD)"]="AppColors.primary"
    ["Color(0x1A3F8DFD)"]="AppColors.primaryLight"
    ["Color(0x803F8DFD)"]="AppColors.primaryMedium"
    ["Color(0x333F8DFD)"]="AppColors.primarySoft"
    ["Color(0xFFFF4ACF)"]="AppColors.secondary"
    ["Color(0xFF9CFC53)"]="AppColors.success"
    ["Color(0xFFED1010)"]="AppColors.warning"
    ["Color(0xFFCCCCCC)"]="AppColors.separator"
    ["Color(0xFFA8A8A8)"]="AppColors.hintText"
    ["Color(0x4D77AFFF)"]="AppColors.shadow"
    ["Color(0x33FFFFFF)"]="AppColors.white20"
    ["Color(0x1AFFFFFF)"]="AppColors.white10"
    ["Color(0x80FFFFFF)"]="AppColors.white50"
)

# 为每个文件添加导入并替换颜色
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "处理文件: $file"
        
        # 添加 AppColors 导入（如果还没有的话）
        if ! grep -q "app_colors.dart" "$file"; then
            # 找到第一个 import 行并在之后添加
            sed -i '' '1i\
import '\''package:fast_ai/values/app_colors.dart'\''; // 统一颜色管理
' "$file"
        fi
        
        # 替换颜色值
        for old_color in "${!color_map[@]}"; do
            new_color="${color_map[$old_color]}"
            sed -i '' "s|$old_color|$new_color|g" "$file"
        done
        
        echo "完成: $file"
    else
        echo "文件不存在: $file"
    fi
done

echo "批量颜色迁移完成！"
echo "请检查以下内容："
echo "1. 确保所有文件都正确导入了 app_colors.dart"
echo "2. 验证颜色替换是否正确"
echo "3. 运行 flutter analyze 检查语法错误"
echo "4. 运行应用测试视觉效果"