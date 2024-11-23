// ignore_for_file: prefer_collection_literals, unnecessary_new, unnecessary_this

class Worker {
  String? about;
  String? name;
  String? photoUrl;
  int? priceMinimum;
  bool? profileCompleted;
  String? service;
  String? serviceCategory;
  String? userId;
  int? ratingTotal;
  int? reviewTotal;
  List<String>? documentation;

  Worker({
    this.about,
    this.name,
    this.photoUrl,
    this.priceMinimum,
    this.profileCompleted,
    this.service,
    this.serviceCategory,
    this.userId,
    this.ratingTotal,
    this.reviewTotal,
  });

  Worker.fromJson(Map<String, dynamic> json) {
    about = json['about'];
    name = json['name'];
    photoUrl = json['photo_url'];
    priceMinimum = json['price_minimum'];
    profileCompleted = json['profile_completed'];
    service = json['service'];
    serviceCategory = json['service_category'];
    ratingTotal = json['rating_total'];
    reviewTotal = json['review_total'];
    userId = json['user_id'];
    documentation = json['documentation'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['about'] = this.about;
    data['name'] = this.name;
    data['photo_url'] = this.photoUrl;
    data['price_minimum'] = this.priceMinimum;
    data['profile_completed'] = this.profileCompleted;
    data['service'] = this.service;
    data['service_category'] = this.serviceCategory;
    data['user_id'] = this.userId;
    data['rating_total'] = this.ratingTotal;
    data['review_total'] = this.reviewTotal;
    data['documentation'] = this.documentation;
    return data;
  }
}
