class SavingTip {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String category;
  final List<String>? tags;

  SavingTip({
    this.id="",
    this.title='',
    this.content='',
    this.imageUrl='',
    this.category='',
    this.tags,
  });
}

// 本地模拟数据
final List<SavingTip> savingTipsData = [
  SavingTip(
    id: '1',
    title: '超市购物省钱技巧',
    content: '1. 选择超市自有品牌商品，质量相近但价格更实惠\n'
        '2. 关注超市促销活动，特别是生鲜食品的晚间折扣\n'
        '3. 使用会员卡和优惠券\n'
        '4. 批量购买非易腐食品\n'
        '5. 制定购物清单，避免冲动消费',
    imageUrl: 'assets/images/saving_tips/ic_sq1.png',
    category: '购物',
    tags: ['超市', '购物', '日常'],
  ),
  SavingTip(
    id: '2',
    title: '餐饮省钱小妙招',
    content: '1. 自己做饭，减少外卖\n'
        '2. 合理规划食材，避免浪费\n'
        '3. 使用优惠券和团购\n'
        '4. 选择性价比高的餐厅\n'
        '5. 关注餐厅会员日活动',
    imageUrl: 'assets/images/saving_tips/ic_sq2.png',
    category: '餐饮',
    tags: ['餐饮', '美食', '日常'],
  ),
  SavingTip(
    id: '3',
    title: '交通出行省钱攻略',
    content: '1. 使用公共交通\n'
        '2. 拼车出行\n'
        '3. 选择优惠时段出行\n'
        '4. 使用共享单车\n'
        '5. 合理规划路线，避免绕路',
    imageUrl: 'assets/images/saving_tips/ic_sq3.png',
    category: '交通',
    tags: ['交通', '出行', '日常'],
  ),
  SavingTip(
    id: '4',
    title: '居家生活省钱技巧',
    content: '1. 节约用水用电\n'
        '2. 合理使用家电\n'
        '3. 选择节能产品\n'
        '4. 做好垃圾分类\n'
        '5. 定期维护家电',
    imageUrl: 'assets/images/saving_tips/ic_sq4.png',
    category: '居家',
    tags: ['居家', '生活', '日常'],
  ),
  SavingTip(
    id: '5',
    title: '网购省钱攻略',
    content: '1. 使用比价工具\n'
        '2. 关注优惠活动\n'
        '3. 使用返利网站\n'
        '4. 选择合适时机购物\n'
        '5. 合理使用优惠券',
    imageUrl: 'assets/images/saving_tips/ic_sq5.png',
    category: '购物',
    tags: ['网购', '购物', '日常'],
  ),
]; 