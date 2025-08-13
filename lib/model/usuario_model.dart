class UsuarioModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String photo;
  final String address;
  final String phone;
  final String city;
  final String barrio;
  final String razonsocial;
  final String ruc;
  final String dateBirth;
  final String dateCreated;
  final String token;
  final String tipoCi;
  final String ci;

  UsuarioModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.photo,
    required this.address,
    required this.phone,
    required this.city,
    required this.barrio,
    required this.razonsocial,
    required this.ruc,
    required this.tipoCi,
    required this.ci,
    required this.dateBirth,
    required this.dateCreated,
    required this.token,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      name: json["name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      photo: json["photo"] ?? "",
      address: json["address"] ?? "",
      phone: json["phone"] ?? "",
      city: json["city"] ?? "",
      barrio: json["barrio"] ?? "",
      razonsocial: json["razonsocial"] ?? "",
      ruc: json["ruc"] ?? "",
      dateBirth: json["date_birth"] ?? "",
      dateCreated: json["date"] ?? "",
      token: json['token'] ?? '',
      tipoCi: json["tipo_ci"] ?? "",
      ci: json["ci"] ?? "",
    );
  }
  //  MODELO ESPECIAL PARA GOOGLE
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "last_name": lastName,
    "email": email,
    "photo": photo,
    "address": address,
    "phone": phone,
    "city": city,
    "barrio": barrio,
    "razonsocial": razonsocial,
    "ruc": ruc,
    "date_birth": dateBirth,
    "date": dateCreated,
    "token": token,
    "tipo_ci": tipoCi,
    "ci": ci,
  };
}

// ubicaciones Modelo
class UbicacionModel {
  final int id;
  final String nombreUbicacion;
  final String callePrincipal;
  final String numeracion;
  final double latitud;
  final double longitud;
  final String? ciudad;
  final String? calleSecundaria;
  final String? referencia;
  final String? tel;
  final int userId;

  UbicacionModel({
    required this.id,
    required this.nombreUbicacion,
    required this.callePrincipal,
    required this.numeracion,
    required this.latitud,
    required this.longitud,
    this.calleSecundaria,
    this.referencia,
    this.tel,
    this.ciudad,
    required this.userId,
  });

  factory UbicacionModel.fromJson(Map<String, dynamic> json) {
    return UbicacionModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      nombreUbicacion: json["nombre_ubicacion"],
      callePrincipal: json["calle_principal"],
      numeracion: json["numeracion"],
      latitud: double.tryParse(json["latitud"].toString()) ?? 0.0,
      longitud: double.tryParse(json["longitud"].toString()) ?? 0.0,
      ciudad: json["ciudad"],
      calleSecundaria: json["calle_secundaria"],
      referencia: json["referencia"],
      tel: json["tel"],
      userId: int.tryParse(json["user_id"].toString()) ?? 0,
    );
  }

  // En tu archivo UbicacionModel.dart
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nombre_ubicacion": nombreUbicacion,
      "calle_principal": callePrincipal,
      "calle_secundaria": calleSecundaria ?? "",
      "referencia": referencia ?? "",
      "tel": tel ?? "",
      "numeracion": numeracion,
      "latitud": latitud.toString(),
      "longitud": longitud.toString(),
      "ciudad": ciudad,
      "user_id": userId,
    };
  }
}
