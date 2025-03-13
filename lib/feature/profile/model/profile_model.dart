/// Represents a user profile in the application
/// Contains personal information and connected streaming services
class ProfileModel {
  int? id;
  String? profilePath;
  String? fullName;
  String? userName;
  String? link;
  String? bio;
  List<Services>? services;

  /// Creates a profile model with optional parameters
  ProfileModel({
    this.id,
    this.fullName,
    this.userName,
    this.link,
    this.bio,
    this.services,
    this.profilePath,
  });

  /// Creates a ProfileModel from a JSON map
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
        services!.add(Services.fromJson(v));
      });
    }
  }

  /// Converts this ProfileModel to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
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

/// Represents a music streaming service connected to a user's profile
class Services {
  String? serviceName;

  Services({this.serviceName});

  /// Creates a Services instance from a JSON map
  Services.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName'];
  }

  /// Converts this Services instance to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['serviceName'] = this.serviceName;
    return data;
  }
}
