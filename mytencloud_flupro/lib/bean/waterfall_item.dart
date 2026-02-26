class WaterfallItem {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final double? imageHeight;
  final String? category;

  WaterfallItem({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.imageHeight,
    this.category,
  });
}

// 本地模拟数据
final List<WaterfallItem> waterfallItems = [
  WaterfallItem(
    id: '1',
    title: '春日花海',
    description: '春天的花海，美不胜收，让人心旷神怡。',
    imageUrl: 'assets/images/waterfall/spring.jpg',
    imageHeight: 300,
    category: '风景',
  ),
  WaterfallItem(
    id: '2',
    title: '夏日海滩',
    description: '阳光、沙滩、海浪，构成完美的夏日画卷。',
    imageUrl: 'assets/images/waterfall/summer.jpg',
    imageHeight: 250,
    category: '风景',
  ),
  WaterfallItem(
    id: '3',
    title: '秋日枫叶',
    description: '金黄的枫叶，装点着秋天的浪漫。',
    imageUrl: 'assets/images/waterfall/autumn.jpg',
    imageHeight: 280,
    category: '风景',
  ),
  WaterfallItem(
    id: '4',
    title: '冬日雪景',
    description: '银装素裹的世界，纯净而美好。',
    imageUrl: 'assets/images/waterfall/winter.jpg',
    imageHeight: 320,
    category: '风景',
  ),
  WaterfallItem(
    id: '5',
    title: '城市夜景',
    description: '璀璨的灯光，照亮城市的夜空。',
    imageUrl: 'assets/images/waterfall/city.jpg',
    imageHeight: 270,
    category: '城市',
  ),
  WaterfallItem(
    id: '6',
    title: '山水画卷',
    description: '青山绿水，如诗如画。',
    imageUrl: 'assets/images/waterfall/landscape.jpg',
    imageHeight: 290,
    category: '风景',
  ),
]; 