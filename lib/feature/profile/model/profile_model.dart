class ProfileModel {
  String? fullName;
  String? userName;
  String? link;
  String? bio;
  List<Services>? services;

  ProfileModel(
      {this.fullName, this.userName, this.link, this.bio, this.services});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    userName = json['userName'];
    link = json['link'];
    bio = json['bio'];
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(new Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this.fullName;
    data['userName'] = this.userName;
    data['link'] = this.link;
    data['bio'] = this.bio;
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  String? serviceName;

  Services({this.serviceName});

  Services.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceName'] = this.serviceName;
    return data;
  }
}
