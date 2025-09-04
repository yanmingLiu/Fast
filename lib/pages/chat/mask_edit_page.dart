import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/mask_edit_ctr.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 聊天角色编辑页面
/// 用于创建或编辑聊天角色的个人信息
class MaskEditPage extends GetView<MaskEditCtr> {
  /// 页面常量定义
  static const double bottomButtonHeight = 100.0;
  static const double horizontalPadding = 16.0;
  static const double borderRadius = 16.0;
  static const double titleSpace = 8.0;
  static const double iconSize = 24.0;
  static const double genderIconSize = 16.0;

  /// 静态常量缓存，提升性能
  static const EdgeInsets _genderPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 6);
  static const EdgeInsets _textFieldPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets _multilineTextFieldPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const EdgeInsets _buttonMargin = EdgeInsets.symmetric(horizontal: 50);
  static const SizedBox _spacing8 = SizedBox(height: 8);
  static const SizedBox _spacing20 = SizedBox(height: 20);
  static const BoxConstraints _multilineConstraints = BoxConstraints(minHeight: 88);
  static const Color _backgroundColor = Color(0xFF333333);
  static const Color _selectedColor = Color(0xFF3F8DFD);
  static const Color _unselectedColor = Color(0x33FFFFFF);
  static const Color _unselectedTextColor = Color(0xFFA8A8A8);
  static const Color _hintColor = Color(0xFF999999);
  static const Color _containerColor = Color(0xFF111111);
  static const Color _borderColor = Color(0x1AFFFFFF);
  static const Color _requiredColor = Color(0xFFFF6C2E);

  const MaskEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    Get.put(MaskEditCtr());

    return GestureDetector(
      onTap: () {
        // 点击空白处关闭键盘
        Get.focusScope?.unfocus();
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(child: _buildFormContent()),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleSpacing: 0.0,
      leadingWidth: 48,
      leading: FButton(
        width: 44,
        height: 44,
        color: Colors.transparent,
        onTap: () => Get.back(),
        child: Center(child: FIcon(assetName: Assets.svg.back)),
      ),
      title: Text(
        LocaleKeys.create_profile_mask.tr,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 构建表单内容
  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: MaskEditPage.horizontalPadding,
      ).copyWith(bottom: MaskEditPage.bottomButtonHeight),
      child: Column(
        spacing: 8,
        children: [
          _buildNameField(),
          _spacing8,
          _buildGenderField(),
          _spacing8,
          _buildAgeField(),
          _spacing8,
          _buildDescriptionField(),
          _spacing8,
          _buildOtherInfoField(),
        ],
      ),
    );
  }

  /// 构建姓名输入字段
  Widget _buildNameField() {
    return Column(
      spacing: MaskEditPage.titleSpace,
      children: [
        Obx(
          () => _buildTitle(
            LocaleKeys.your_name.tr,
            subtitle: '(${controller.nameLength.value}/${MaskEditCtr.maxNameLength})',
          ),
        ),
        _buildTextFieldContainer(
          child: TextField(
            controller: controller.nameController,
            maxLength: MaskEditCtr.maxNameLength,
            inputFormatters: [_NoLeadingSpaceFormatter()],
            decoration: _buildInputDecoration(LocaleKeys.name_hint.tr),
            style: _buildTextStyle(),
          ),
        ),
      ],
    );
  }

  /// 构建性别选择字段
  Widget _buildGenderField() {
    return Column(
      spacing: MaskEditPage.titleSpace,
      children: [
        _buildTitle(LocaleKeys.your_gender.tr),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            _buildGenderOption(Gender.female, Gender.female.display, Assets.images.female),
            _buildGenderOption(Gender.male, Gender.male.display, Assets.images.male),
            _buildGenderOption(Gender.nonBinary, Gender.nonBinary.display, Assets.images.nonbinary),
          ],
        ),
      ],
    );
  }

  /// 构建性别选项
  Widget _buildGenderOption(Gender gender, String label, AssetGenImage selectedIcon) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == gender;
      return GestureDetector(
        onTap: () {
          controller.selectGender(gender);
        },
        child: Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: isSelected ? _selectedColor : _unselectedColor, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: _genderPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 4,
            children: [
              selectedIcon.image(width: genderIconSize),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _selectedColor : _unselectedTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 构建年龄输入字段
  Widget _buildAgeField() {
    return Column(
      spacing: MaskEditPage.titleSpace,
      children: [
        _buildTitle(LocaleKeys.your_age.tr, query: false),
        _buildTextFieldContainer(
          child: TextField(
            controller: controller.ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
              _AgeInputFormatter(),
            ],
            decoration: _buildInputDecoration(LocaleKeys.age_hint.tr),
            style: _buildTextStyle(),
          ),
        ),
      ],
    );
  }

  /// 构建描述输入字段
  Widget _buildDescriptionField() {
    return Column(
      spacing: MaskEditPage.titleSpace,
      children: [
        Obx(
          () => _buildTitle(
            LocaleKeys.description.tr,
            subtitle: '(${controller.descriptionLength.value}/${MaskEditCtr.maxDescriptionLength})',
            query: true,
          ),
        ),
        _buildMultilineTextFieldContainer(
          child: TextField(
            controller: controller.descriptionController,
            maxLength: MaskEditCtr.maxDescriptionLength,
            maxLines: null,
            inputFormatters: [_NoLeadingSpaceFormatter()],
            decoration: _buildInputDecoration(LocaleKeys.description_hint.tr),
            style: _buildTextStyle(),
          ),
        ),
      ],
    );
  }

  /// 构建其他信息输入字段
  Widget _buildOtherInfoField() {
    return Column(
      spacing: MaskEditPage.titleSpace,
      children: [
        Obx(
          () => _buildTitle(
            LocaleKeys.other_info.tr,
            subtitle: '(${controller.otherInfoLength.value}/${MaskEditCtr.maxOtherInfoLength})',
            query: false,
          ),
        ),
        _buildMultilineTextFieldContainer(
          child: TextField(
            controller: controller.otherInfoController,
            maxLength: MaskEditCtr.maxOtherInfoLength,
            maxLines: null,
            inputFormatters: [_NoLeadingSpaceFormatter()],
            decoration: _buildInputDecoration(LocaleKeys.other_info_hint.tr),
            style: _buildTextStyle(),
          ),
        ),
      ],
    );
  }

  /// 构建文本输入框容器
  Widget _buildTextFieldContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: _textFieldPadding,
      child: child,
    );
  }

  /// 构建多行文本输入框容器
  Widget _buildMultilineTextFieldContainer({required Widget child}) {
    return Container(
      constraints: _multilineConstraints,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: _multilineTextFieldPadding,
      child: child,
    );
  }

  /// 构建输入框装饰
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      counterText: '',
      hintText: hintText,
      border: InputBorder.none,
      hintStyle: const TextStyle(color: _hintColor, fontSize: 14),
    );
  }

  /// 构建文本样式
  TextStyle _buildTextStyle() {
    return const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500);
  }

  /// 构建底部按钮
  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 16,
        bottom: MediaQuery.of(Get.context!).padding.bottom > 0
            ? MediaQuery.of(Get.context!).padding.bottom
            : 16,
      ),
      decoration: const BoxDecoration(
        color: _containerColor,
        border: Border(top: BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: FButton(
        onTap: controller.saveMask,
        color: _selectedColor,
        margin: _buttonMargin,
        hasShadow: true,
        child: !controller.isEditMode
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Assets.images.gems.image(width: 24),
                  Text(
                    '${controller.createCost}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    LocaleKeys.to_create.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  LocaleKeys.save.tr,
                  style: AppTextStyle.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTitle(String title, {String? subtitle, bool query = true}) {
    return Row(
      spacing: 2,
      children: [
        Text(
          title,
          style: AppTextStyle.openSans(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (query)
          Text(
            '*',
            style: AppTextStyle.openSans(
              fontSize: 14,
              color: _requiredColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (subtitle != null)
          Text(
            subtitle,
            style: AppTextStyle.openSans(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _AgeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value == null || value > 99999) {
      return oldValue;
    }

    return newValue;
  }
}

class _NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 如果新值为空，直接返回
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 只阻止第一个字符前面的空格
    // 如果文本以空格开头，且这是新输入的空格，则阻止
    if (newValue.text.startsWith(' ') && !oldValue.text.startsWith(' ')) {
      return oldValue;
    }

    return newValue;
  }
}
