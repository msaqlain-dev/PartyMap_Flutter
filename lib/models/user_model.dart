// Use website JSON to Dart https://javiercbk.github.io/json_to_dart/ to convert your login api body response into dart model

class Address {
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  Address({
    this.addressLine1,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    addressLine1: json['addressLine1'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'],
    country: json['country'],
  );

  Map<String, dynamic> toJson() => {
    'addressLine1': addressLine1,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
  };
}

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? instagram;
  final String? facebook;
  final String? twitter;
  final String? snap;
  final String? role;
  final Address? address;
  final String? token;
  final bool? isLogin;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.instagram,
    this.facebook,
    this.twitter,
    this.snap,
    this.role,
    this.address,
    this.token,
    this.isLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    email: json['email'],
    phone: json['phone'],
    instagram: json['instagram'],
    facebook: json['facebook'],
    twitter: json['twitter'],
    snap: json['snap'],
    role: json['role'],
    address: json['address'] != null ? Address.fromJson(json['address']) : null,
    token: json['token'],
    isLogin: json['isLogin'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'instagram': instagram,
    'facebook': facebook,
    'twitter': twitter,
    'snap': snap,
    'role': role,
    'address': address?.toJson(),
    'token': token,
    'isLogin': isLogin,
  };
}
