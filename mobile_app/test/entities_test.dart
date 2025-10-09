import 'package:flutter_test/flutter_test.dart';

import 'package:ziso_mobile/core/domain/entities.dart';

void main() {
  group('Entity mapping', () {
    test('Employee round trip', () {
      final employee = Employee(
        employeeId: 1,
        firstName: 'Jane',
        lastName: 'Doe',
        address: '123 Main St',
        phoneNumber: '555-1234',
        email: 'jane@example.com',
        dateOfBirth: '1990-01-01',
        nationalId: 'ID123',
        dateOfEmployment: '2020-01-01',
        position: 'Analyst',
      );
      final map = employee.toMap();
      final fromMap = Employee.fromMap(map);
      expect(fromMap.toMap(), map);
    });

    test('Company retains relations', () {
      final company = Company(
        companyId: 1,
        name: 'Ziso Ltd',
        address: 'Corporate Plaza',
        phoneNumber: '555-9876',
        email: 'info@ziso.test',
        dateOfIncorporation: '2010-05-01',
        registrationNumber: 'REG-123',
        directorIds: {1, 2},
        employeeIds: {3},
        nextOfKinIds: {4},
        courtCaseIds: {5},
      );
      final map = company.toMap();
      final fromMap = Company.fromMap(map,
          directorIds: company.directorIds,
          employeeIds: company.employeeIds,
          nextOfKinIds: company.nextOfKinIds,
          courtCaseIds: company.courtCaseIds);
      expect(fromMap.directorIds, company.directorIds);
      expect(fromMap.employeeIds, company.employeeIds);
      expect(fromMap.nextOfKinIds, company.nextOfKinIds);
      expect(fromMap.courtCaseIds, company.courtCaseIds);
    });
  });
}
