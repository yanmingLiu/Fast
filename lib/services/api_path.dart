class ApiPath {
  ApiPath._();

  // 注册
  static const String register = '/v2/user/device/register';
  // 获取用户信息
  static const String getUserInfo = '/v2/appUser/getByDeviceId/user';
  // 修改用户信息
  static const String updateUserInfo = '/v2/appUser/updateUserInfo';
  // 角色列表
  static const String roleList = '/v2/characterProfile/getAll';
  // moments list
  static const String momentsList = '/moments/getAll';
  // 根据角色 id 查询角色
  static const String getRoleById = '/v2/characterProfile/getById';
  // 用户减钻石
  static const String minusGems = '/v2/appUser/minusGems';
  // 通过角色随机查一条查询
  static const String genRandomOne = '/v2/characterMedia/getByRole/randomOne';
  // 支持 auto-mask 支持角色生成
  static const String undrCharacter = '/isNaked/undressOutcome';
  // undr image result
  static const String undrImageRes = '/isNaked/getUndressResult';
  // undr styles
  static const String undrStyles = '/getStyleConfig';
  // ios 创建订单
  static const String createIosOrder = '/rechargeOrders/createOrder';
  // iOS 完成订单
  static const String verifyIosReceipt = '/rechargeOrders/finishOrder';
  // 创建 google 订单
  static const String createAndOrder = '/pay/google/create';
  // 谷歌验签
  static const String verifyAndOrder = '/pay/google/verify';
  // 收藏角色
  static const String collectRole = '/v2/characterProfile/collect';
  // 取消收藏角色
  static const String cancelCollectRole = '/v2/characterProfile/cancelCollect';
  // 角色标签
  static const String roleTag = '/v2/characterProfile/tags';
  // 会话列表
  static const String sessionList = '/aiChatConversation/list';
  // 新增会话
  static const String addSession = '/aiChatConversation/add';
  // 重置会话
  static const String resetSession = '/aiChatConversation/reset';
  // 删除会话
  static const String deleteSession = '/aiChatConversation/delete';
  // 收藏列表
  static const String collectList = '/v2/characterProfile/collect/list';
  // 消息列表
  static const String messageList = '/v2/history/getAll';
  // 语音聊天
  static const String voiceChat = '/audioClips/chat';
  // 开屏随机角色
  static const String splashRandomRole = '/plfC/getRecommendRole';
  // 上报事件 用户参数
  static String eventParams = '/v2/user/upinfo';
  // 聊天等级配置
  static String chatLevelConfig = '/system/chatLevelConf';
  // 解锁图片
  static String unlockImage = '/v2/characterProfile/unlockImage';
  // 聊天等级
  static String chatLevel = '/aiChatConversation/getChatLevel';
  // translate
  static String translate = '/translate';
  // 签到
  static String signIn = '/signin';
  // 送礼配置
  static String giftConfig = '/v2/characterProfile/getGiftConf';
  // 换装配置
  static String changeConfig = '/v2/characterProfile/getClothingConf';
  // 送玩具
  static String sendToy = '/v2/message/gift';
  // 送衣服
  static String sendClothes = '/v2/message/clothes';
  // 保存消息信息
  static String saveMsg = '/v2/history/saveMessage';
  // 用户加钻石
  static String addGems = '/v2/appUser/plusGems';
  // sku 列表
  static String skuList = '/platformConfig/getAllSku';
  // 编辑消息
  static String editMsg = '/v2/message/editMsg';
  // 续写
  static String continueWrite = '/v2/message/resume/h';
  // 重新发送消息
  static String resendMsg = '/v2/message/resend/h';
  // 发送消息
  static String sendMsg = '/v2/message/conversation/ask/h';
  // 修改聊天场景
  static String editScene = '/v2/message/conversation/change';
  // 修改会话模式
  static String editMode = '/aiChatConversation/editMode';
  // 新建 mask
  static String createMask = '/userProfile/add';
  // 编辑 mask
  static String editMask = '/userProfile/update';
  // 获取 mask 列表
  static String getMaskList = '/userProfile/getAll';
  // 切换 mask
  static String changeMask = '/v2/message/conversation/changeArchive';
  // 各种价格配置
  static String getPriceConfig = '/system/price/config';
  // 删除mask
  static String deleteMask = '/userProfile/del';
}
