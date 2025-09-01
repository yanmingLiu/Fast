import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/mask_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 聊天角色编辑页面
/// 用于创建或编辑聊天角色的个人信息
class MaskEditPage extends StatefulWidget {
  /// 页面常量定义
  static const int maxNameLength = 20;
  static const int maxDescriptionLength = 500;
  static const int maxOtherInfoLength = 500;
  static const int maxAge = 99;
  static const double bottomButtonHeight = 100.0;
  static const double horizontalPadding = 16.0;
  static const double borderRadius = 16.0;
  static const double titleSpace = 8.0;
  static const double iconSize = 24.0;
  static const double genderIconSize = 16.0;
  const MaskEditPage({super.key});

  @override
  State<MaskEditPage> createState() => _MaskEditPageState();
}

/// MaskEditPage的状态管理类
class _MaskEditPageState extends State<MaskEditPage> {
  // 文本控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherInfoController = TextEditingController();

  // 字符计数
  int _nameLength = 0;
  int _descriptionLength = 0;
  int _otherInfoLength = 0;

  // 选中的性别
  Gender? _gender;

  // 编辑的聊天角色（新建时为null）
  late MaskData? _chatMask;

  final ctr = Get.find<MsgCtr>();

  bool _isChanged = false;

  /// 验证表单数据
  /// 返回验证失败的错误信息，如果验证通过返回null
  String? _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      return LocaleKeys.fill_required_info.tr;
    }

    if (_descriptionController.text.trim().isEmpty) {
      return LocaleKeys.fill_required_info.tr;
    }

    if (_gender == null) {
      return LocaleKeys.fill_required_info.tr;
    }

    return null;
  }

  /// 显示错误提示
  void _showError(String message) {
    FToast.toast(message);
  }

  /// 保存角色信息
  void _saveMask() async {
    // 验证表单
    final errorMessage = _validateForm();
    if (errorMessage != null) {
      _showError(errorMessage);
      return;
    }

    // 关闭键盘
    FocusScope.of(context).unfocus();

    if (_chatMask == null) {
      final balance = AppUser().balance.value;
      final profileChange = AppUser().priceConfig?.profileChange ?? 5;
      if (balance < profileChange) {
        AppRouter.pushGem(ConsumeFrom.mask);
        return;
      }
    }

    final isEditChoosed = _chatMask != null && _chatMask?.id == ctr.session.profileId;

    if (isEditChoosed && _isChanged) {
      AppDialog.alert(
        message: LocaleKeys.edit_choose_mask.tr,
        cancelText: LocaleKeys.cancel.tr,
        confirmText: LocaleKeys.restart.tr,
        onConfirm: () async {
          AppDialog.dismiss();
          _saveRequest();
        },
      );
    } else {
      _saveRequest();
    }
  }

  Future<void> _saveRequest() async {
    if (!_isChanged) {
      Get.back();
      return;
    }
    // 显示加载状态
    FLoading.showLoading();
    try {
      final success = await Api.createOrUpdateMask(
        name: _nameController.text.trim(),
        age: _ageController.text.trim(),
        gender: _gender?.code ?? Gender.unknown.code,
        description: _descriptionController.text.trim(),
        otherInfo: _otherInfoController.text.trim(),
        id: _chatMask?.id,
      );

      await AppUser().getUserInfo();

      FLoading.dismiss();

      if (success) {
        Get.back();
      } else {
        FToast.toast(LocaleKeys.some_error_try_again.tr);
      }
    } catch (e) {
      FLoading.dismiss();
      FToast.toast(LocaleKeys.some_error_try_again.tr);
    }
  }

  /// 初始化编辑数据
  void _initializeEditData() {
    _chatMask = Get.arguments;

    if (_chatMask != null) {
      _nameController.text = _chatMask?.profileName ?? '';
      _descriptionController.text = _chatMask?.description ?? '';
      _ageController.text = _chatMask?.age == null ? '' : _chatMask?.age.toString() ?? '';
      _otherInfoController.text = _chatMask?.otherInfo ?? '';
      _gender = Gender.values.firstWhereOrNull((gender) => gender.code == _chatMask?.gender);
      _nameLength = _nameController.text.length;
      _descriptionLength = _descriptionController.text.length;
      _otherInfoLength = _otherInfoController.text.length;
    }
    setState(() {});
  }

  /// 设置文本监听器
  void _setupTextListeners() {
    _nameController.addListener(() {
      setState(() {
        _nameLength = _nameController.text.length;
        _isChanged = _nameLength > 0;
      });
    });

    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
        _isChanged = _descriptionLength > 0;
      });
    });

    _otherInfoController.addListener(() {
      setState(() {
        _otherInfoLength = _otherInfoController.text.length;
        _isChanged = _otherInfoLength > 0;
      });
    });

    _ageController.addListener(() {
      _isChanged = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeEditData();
    _setupTextListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _otherInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白处关闭键盘
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(child: _buildFormContent()),
            _buildBottomButton(),
          ],
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
          const SizedBox(height: 8),
          _buildGenderField(),
          const SizedBox(height: 8),
          _buildAgeField(),
          const SizedBox(height: 8),
          _buildDescriptionField(),
          const SizedBox(height: 8),
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
        _buildTitle(
          LocaleKeys.your_name.tr,
          subtitle: '($_nameLength/${MaskEditPage.maxNameLength})',
        ),
        _buildTextFieldContainer(
          child: TextField(
            controller: _nameController,
            maxLength: MaskEditPage.maxNameLength,
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
    final isSelected = _gender == gender;
    return GestureDetector(
      onTap: () {
        setState(() => _gender = gender);
        _isChanged = true;
      },
      child: Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(
            color: isSelected ? const Color(0xFF3F8DFD) : const Color(0x33FFFFFF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 4,
          children: [
            selectedIcon.image(width: MaskEditPage.genderIconSize),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF3F8DFD) : const Color(0xFFA8A8A8),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建年龄输入字段
  Widget _buildAgeField() {
    return Column(
      spacing: MaskEditPage.titleSpace,
      children: [
        _buildTitle(LocaleKeys.your_age.tr, query: false),
        _buildTextFieldContainer(
          child: TextField(
            controller: _ageController,
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
        _buildTitle(
          LocaleKeys.description.tr,
          subtitle: '($_descriptionLength/${MaskEditPage.maxDescriptionLength})',
          query: true,
        ),
        _buildMultilineTextFieldContainer(
          child: TextField(
            controller: _descriptionController,
            maxLength: MaskEditPage.maxDescriptionLength,
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
        _buildTitle(
          LocaleKeys.other_info.tr,
          subtitle: '($_otherInfoLength/${MaskEditPage.maxOtherInfoLength})',
          query: false,
        ),
        _buildMultilineTextFieldContainer(
          child: TextField(
            controller: _otherInfoController,
            maxLength: MaskEditPage.maxOtherInfoLength,
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
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(MaskEditPage.borderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  /// 构建多行文本输入框容器
  Widget _buildMultilineTextFieldContainer({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(MaskEditPage.borderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }

  /// 构建输入框装饰
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      counterText: '',
      hintText: hintText,
      border: InputBorder.none,
      hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14),
    );
  }

  /// 构建文本样式
  TextStyle _buildTextStyle() {
    return const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500);
  }

  /// 构建底部按钮
  Widget _buildBottomButton() {
    final idEdit = _chatMask != null;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: MaskEditPage.horizontalPadding)
          .copyWith(
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 16,
          ),
      child: FButton(
        onTap: _saveMask,
        color: Color(0xFF3F8DFD),
        margin: EdgeInsets.symmetric(horizontal: 50),
        hasShadow: true,
        child: _chatMask == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Assets.images.gems.image(width: 24),
                  Text(
                    '${AppUser().priceConfig?.profileChange ?? 5}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    LocaleKeys.to_create.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  idEdit ? LocaleKeys.save.tr : LocaleKeys.create.tr,
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
              color: Color(0xFFFF6C2E),
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
