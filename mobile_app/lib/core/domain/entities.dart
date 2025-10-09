import 'package:collection/collection.dart';

/// Core domain entities that mirror the Django models used in the web app.
///
/// Every entity exposes conversion helpers to and from SQLite `Map<String, Object?>`
/// payloads so the rest of the app can remain persistence-agnostic.

abstract class BaseEntity {
  Map<String, Object?> toMap();
}

class Employee extends BaseEntity {
  Employee({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.nationalId,
    this.idImagePath,
    this.passportNumber,
    required this.dateOfEmployment,
    required this.position,
    this.cvPath,
    this.vehicleRegistrationNumber,
    this.courtCaseIds = const <int>{},
    this.criminalRecordIds = const <int>{},
  });

  factory Employee.fromMap(Map<String, Object?> map,
      {Set<int>? courtCaseIds, Set<int>? criminalRecordIds}) {
    return Employee(
      employeeId: map['employee_id'] as int,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      dateOfBirth: map['date_of_birth'] as String,
      nationalId: map['national_id'] as String,
      idImagePath: map['id_image_path'] as String?,
      passportNumber: map['passport_number'] as String?,
      dateOfEmployment: map['date_of_employment'] as String,
      position: map['position'] as String,
      cvPath: map['cv_path'] as String?,
      vehicleRegistrationNumber:
          map['vehicle_registration_number'] as String?,
      courtCaseIds: courtCaseIds ?? const <int>{},
      criminalRecordIds: criminalRecordIds ?? const <int>{},
    );
  }

  final int employeeId;
  final String firstName;
  final String lastName;
  final String address;
  final String phoneNumber;
  final String email;
  final String dateOfBirth;
  final String nationalId;
  final String? idImagePath;
  final String? passportNumber;
  final String dateOfEmployment;
  final String position;
  final String? cvPath;
  final String? vehicleRegistrationNumber;
  final Set<int> courtCaseIds;
  final Set<int> criminalRecordIds;

  @override
  Map<String, Object?> toMap() {
    return {
      'employee_id': employeeId,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_birth': dateOfBirth,
      'national_id': nationalId,
      'id_image_path': idImagePath,
      'passport_number': passportNumber,
      'date_of_employment': dateOfEmployment,
      'position': position,
      'cv_path': cvPath,
      'vehicle_registration_number': vehicleRegistrationNumber,
    }..removeWhere((_, value) => value == null);
  }

  Employee copyWith({
    String? firstName,
    String? lastName,
    String? address,
    String? phoneNumber,
    String? email,
    String? dateOfBirth,
    String? nationalId,
    String? idImagePath,
    String? passportNumber,
    String? dateOfEmployment,
    String? position,
    String? cvPath,
    String? vehicleRegistrationNumber,
    Set<int>? courtCaseIds,
    Set<int>? criminalRecordIds,
  }) {
    return Employee(
      employeeId: employeeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      idImagePath: idImagePath ?? this.idImagePath,
      passportNumber: passportNumber ?? this.passportNumber,
      dateOfEmployment: dateOfEmployment ?? this.dateOfEmployment,
      position: position ?? this.position,
      cvPath: cvPath ?? this.cvPath,
      vehicleRegistrationNumber:
          vehicleRegistrationNumber ?? this.vehicleRegistrationNumber,
      courtCaseIds: courtCaseIds ?? this.courtCaseIds,
      criminalRecordIds: criminalRecordIds ?? this.criminalRecordIds,
    );
  }
}

class NextOfKin extends BaseEntity {
  NextOfKin({
    required this.nextOfKinId,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.relationship,
    required this.dateOfBirth,
    required this.occupation,
    required this.idNumber,
  });

  factory NextOfKin.fromMap(Map<String, Object?> map) {
    return NextOfKin(
      nextOfKinId: map['next_of_kin_id'] as int,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      relationship: map['relationship'] as String,
      dateOfBirth: map['date_of_birth'] as String,
      occupation: map['occupation'] as String,
      idNumber: map['id_number'] as String,
    );
  }

  final int nextOfKinId;
  final String phoneNumber;
  final String email;
  final String address;
  final String relationship;
  final String dateOfBirth;
  final String occupation;
  final String idNumber;

  @override
  Map<String, Object?> toMap() {
    return {
      'next_of_kin_id': nextOfKinId,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'relationship': relationship,
      'date_of_birth': dateOfBirth,
      'occupation': occupation,
      'id_number': idNumber,
    };
  }
}

class Director extends BaseEntity {
  Director({
    required this.directorId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.nationalId,
    this.passportNumber,
    this.vehicleRegistrationNumber,
  });

  factory Director.fromMap(Map<String, Object?> map) {
    return Director(
      directorId: map['director_id'] as int,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      dateOfBirth: map['date_of_birth'] as String,
      nationalId: map['national_id'] as String,
      passportNumber: map['passport_number'] as String?,
      vehicleRegistrationNumber:
          map['vehicle_registration_number'] as String?,
    );
  }

  final int directorId;
  final String firstName;
  final String lastName;
  final String address;
  final String phoneNumber;
  final String email;
  final String dateOfBirth;
  final String nationalId;
  final String? passportNumber;
  final String? vehicleRegistrationNumber;

  @override
  Map<String, Object?> toMap() {
    return {
      'director_id': directorId,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_birth': dateOfBirth,
      'national_id': nationalId,
      'passport_number': passportNumber,
      'vehicle_registration_number': vehicleRegistrationNumber,
    }..removeWhere((_, value) => value == null);
  }
}

class Company extends BaseEntity {
  Company({
    required this.companyId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.dateOfIncorporation,
    required this.registrationNumber,
    this.directorIds = const <int>{},
    this.employeeIds = const <int>{},
    this.nextOfKinIds = const <int>{},
    this.courtCaseIds = const <int>{},
  });

  factory Company.fromMap(
    Map<String, Object?> map, {
    Set<int>? directorIds,
    Set<int>? employeeIds,
    Set<int>? nextOfKinIds,
    Set<int>? courtCaseIds,
  }) {
    return Company(
      companyId: map['company_id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      dateOfIncorporation: map['date_of_incorporation'] as String,
      registrationNumber: map['registration_number'] as String,
      directorIds: directorIds ?? const <int>{},
      employeeIds: employeeIds ?? const <int>{},
      nextOfKinIds: nextOfKinIds ?? const <int>{},
      courtCaseIds: courtCaseIds ?? const <int>{},
    );
  }

  final int companyId;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String dateOfIncorporation;
  final String registrationNumber;
  final Set<int> directorIds;
  final Set<int> employeeIds;
  final Set<int> nextOfKinIds;
  final Set<int> courtCaseIds;

  @override
  Map<String, Object?> toMap() {
    return {
      'company_id': companyId,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_incorporation': dateOfIncorporation,
      'registration_number': registrationNumber,
    };
  }
}

class CourtCase extends BaseEntity {
  CourtCase({
    required this.courtCaseId,
    required this.number,
    required this.name,
    required this.type,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.parties,
    required this.judge,
  });

  factory CourtCase.fromMap(Map<String, Object?> map) {
    return CourtCase(
      courtCaseId: map['court_case_id'] as int,
      number: map['number'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      location: map['location'] as String,
      description: map['description'] as String,
      parties: map['parties'] as String,
      judge: map['judge'] as String,
    );
  }

  final int courtCaseId;
  final String number;
  final String name;
  final String type;
  final String date;
  final String time;
  final String location;
  final String description;
  final String parties;
  final String judge;

  @override
  Map<String, Object?> toMap() {
    return {
      'court_case_id': courtCaseId,
      'number': number,
      'name': name,
      'type': type,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'parties': parties,
      'judge': judge,
    };
  }
}

class Customer extends BaseEntity {
  Customer({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.nationalId,
    this.passportNumber,
    this.vehicleRegistrationNumber,
    this.criminalRecordIds = const <int>{},
    this.previousTransactionIds = const <int>{},
    this.courtCaseIds = const <int>{},
  });

  factory Customer.fromMap(
    Map<String, Object?> map, {
    Set<int>? criminalRecordIds,
    Set<int>? previousTransactionIds,
    Set<int>? courtCaseIds,
  }) {
    return Customer(
      customerId: map['customer_id'] as int,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String,
      email: map['email'] as String,
      dateOfBirth: map['date_of_birth'] as String,
      nationalId: map['national_id'] as String,
      passportNumber: map['passport_number'] as String?,
      vehicleRegistrationNumber:
          map['vehicle_registration_number'] as String?,
      criminalRecordIds: criminalRecordIds ?? const <int>{},
      previousTransactionIds: previousTransactionIds ?? const <int>{},
      courtCaseIds: courtCaseIds ?? const <int>{},
    );
  }

  final int customerId;
  final String firstName;
  final String lastName;
  final String address;
  final String phoneNumber;
  final String email;
  final String dateOfBirth;
  final String nationalId;
  final String? passportNumber;
  final String? vehicleRegistrationNumber;
  final Set<int> criminalRecordIds;
  final Set<int> previousTransactionIds;
  final Set<int> courtCaseIds;

  @override
  Map<String, Object?> toMap() {
    return {
      'customer_id': customerId,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_birth': dateOfBirth,
      'national_id': nationalId,
      'passport_number': passportNumber,
      'vehicle_registration_number': vehicleRegistrationNumber,
    }..removeWhere((_, value) => value == null);
  }
}

class CriminalRecord extends BaseEntity {
  CriminalRecord({
    required this.criminalRecordId,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    this.courtCaseId,
  });

  factory CriminalRecord.fromMap(Map<String, Object?> map) {
    return CriminalRecord(
      criminalRecordId: map['criminal_record_id'] as int,
      description: map['description'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      location: map['location'] as String,
      type: map['type'] as String,
      courtCaseId: map['court_case_id'] as int?,
    );
  }

  final int criminalRecordId;
  final String description;
  final String date;
  final String time;
  final String location;
  final String type;
  final int? courtCaseId;

  @override
  Map<String, Object?> toMap() {
    return {
      'criminal_record_id': criminalRecordId,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'type': type,
      'court_case_id': courtCaseId,
    }..removeWhere((_, value) => value == null);
  }
}

class PreviousTransaction extends BaseEntity {
  PreviousTransaction({
    required this.previousTransactionId,
    required this.date,
    required this.time,
    required this.amount,
    required this.description,
  });

  factory PreviousTransaction.fromMap(Map<String, Object?> map) {
    return PreviousTransaction(
      previousTransactionId: map['previous_transaction_id'] as int,
      date: map['date'] as String,
      time: map['time'] as String,
      amount: map['amount'] as String,
      description: map['description'] as String,
    );
  }

  final int previousTransactionId;
  final String date;
  final String time;
  final String amount;
  final String description;

  @override
  Map<String, Object?> toMap() {
    return {
      'previous_transaction_id': previousTransactionId,
      'date': date,
      'time': time,
      'amount': amount,
      'description': description,
    };
  }
}

class EmploymentRecord extends BaseEntity {
  EmploymentRecord({
    required this.employmentRecordId,
    required this.date,
    required this.time,
    required this.description,
    required this.employeeId,
  });

  factory EmploymentRecord.fromMap(Map<String, Object?> map) {
    return EmploymentRecord(
      employmentRecordId: map['employment_record_id'] as int,
      date: map['date'] as String,
      time: map['time'] as String,
      description: map['description'] as String,
      employeeId: map['employee_id'] as int,
    );
  }

  final int employmentRecordId;
  final String date;
  final String time;
  final String description;
  final int employeeId;

  @override
  Map<String, Object?> toMap() {
    return {
      'employment_record_id': employmentRecordId,
      'date': date,
      'time': time,
      'description': description,
      'employee_id': employeeId,
    };
  }
}

extension EntityListEquality on Iterable<BaseEntity> {
  bool equals(Iterable<BaseEntity> other) {
    final self = map((entity) => entity.toMap()).toList();
    final comparison = other.map((entity) => entity.toMap()).toList();
    const equality = DeepCollectionEquality();
    return equality.equals(self, comparison);
  }
}
