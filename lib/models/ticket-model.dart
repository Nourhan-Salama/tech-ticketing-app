class TicketModel {
  final int id;
  final String title;
  final int status;
  final String description;
  final ServiceModel service;
  final UserModel user;
  final ManagerModel? manager;
  final TechnicianModel? technician;

  TicketModel({
    required this.id,
    required this.title,
    required this.status,
    required this.description,
    required this.service,
    required this.user,
    this.manager,
    this.technician,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as int,
      description: json['description'] as String,
      service: ServiceModel.fromJson(json['service']),
      user: UserModel.fromJson(json['user']),
      manager: json['manager'] != null ? ManagerModel.fromJson(json['manager']) :null,
      technician: json['technician'] != null ? TechnicianModel.fromJson(json['technician']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ServiceModel {
  final int id;
  final String name;

  ServiceModel({required this.id, required this.name});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ManagerModel {
  final int id;
  final UserModel user;

  ManagerModel({required this.id, required this.user});

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user']),
    );
  }
}

class TechnicianModel {
  final int id;
  final UserModel user;

  TechnicianModel({required this.id, required this.user});

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user']),
    );
  }
}

