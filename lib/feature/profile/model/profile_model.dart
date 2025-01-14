class ProfileModel {
  int? id;
  String? profilePath;
  String? fullName;
  String? userName;
  String? link;
  String? bio;
  List<Services>? services;

  ProfileModel(
      {this.id,this.fullName, this.userName, this.link, this.bio, this.services,this.profilePath});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    userName = json['userName'];
    profilePath = json['profilePath'];
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
    data['id'] = this.id;
    data['profilePath'] = this.profilePath;
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
