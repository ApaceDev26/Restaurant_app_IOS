class EarningHistoryModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<EarningHistory>? earningHistory;

  EarningHistoryModel({this.totalSize, this.limit, this.offset, this.earningHistory});

  EarningHistoryModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['earning_history'] != null) {
      earningHistory = <EarningHistory>[];
      json['earning_history'].forEach((v) {
        earningHistory!.add(EarningHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (earningHistory != null) {
      data['earning_history'] = earningHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EarningHistory {
  int? id;
  int? orderId;
  String? orderName;
  double? restaurantAmount;
  String? createdAt;
  String? dateTime;

  EarningHistory({
    this.id,
    this.orderId,
    this.orderName,
    this.restaurantAmount,
    this.createdAt,
    this.dateTime,
  });

  EarningHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    orderName = json['order_name'];
    restaurantAmount = json['restaurant_amount']?.toDouble();
    createdAt = json['created_at'];
    dateTime = json['date_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['order_name'] = orderName;
    data['restaurant_amount'] = restaurantAmount;
    data['created_at'] = createdAt;
    data['date_time'] = dateTime;
    return data;
  }
}

