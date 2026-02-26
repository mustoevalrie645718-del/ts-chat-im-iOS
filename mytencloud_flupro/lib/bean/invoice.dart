class Invoice {
  final String? id;
  final String? title;
  final String? amount;
  final String? date;
  final String? type;
  final String? number;
  final String? company;
  final String? taxNumber;

  Invoice({
    this.id,
    this.title,
    this.amount,
    this.date,
    this.type,
    this.number,
    this.company,
    this.taxNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'type': type,
      'number': number,
      'company': company,
      'taxNumber': taxNumber,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: json['date'],
      type: json['type'],
      number: json['number'],
      company: json['company'],
      taxNumber: json['taxNumber'],
    );
  }
} 