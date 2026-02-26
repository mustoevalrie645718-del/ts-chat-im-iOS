class ZhangdanBean {
  String date; //日期
  String inmoney; //收入
  String outmoney; //支出
  String remondmoney;

  ZhangdanBean(
      this.date, this.inmoney, this.outmoney, this.remondmoney);

  @override
  String toString() {
    return 'ZhangDanBean{date: $date, inmoney: $inmoney, outmoney: $outmoney, remondmoney: $remondmoney}';
  } //结余

}
