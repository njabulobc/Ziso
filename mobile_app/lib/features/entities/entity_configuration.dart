import '../../core/database/repositories.dart';
import '../../core/domain/entities.dart';

enum FieldInputType { text, multiline, date, email, phone, number }

class FieldDefinition {
  FieldDefinition({
    required this.key,
    required this.label,
    this.inputType = FieldInputType.text,
    this.required = true,
    this.readOnly = false,
    this.hint,
  });

  final String key;
  final String label;
  final FieldInputType inputType;
  final bool required;
  final bool readOnly;
  final String? hint;
}

class RelationDefinition<T extends BaseEntity> {
  RelationDefinition({
    required this.key,
    required this.label,
    required this.loadOptions,
  });

  final String key;
  final String label;
  final Future<List<RelationOption>> Function() loadOptions;
}

class RelationOption {
  RelationOption({required this.id, required this.label});

  final int id;
  final String label;
}

class EntityConfiguration<T extends BaseEntity> {
  EntityConfiguration({
    required this.name,
    required this.singularName,
    required this.repository,
    required this.fields,
    required this.idKey,
    required this.toFormValues,
    required this.toRelationValues,
    required this.fromForm,
    this.relations = const <RelationDefinition<T>>[],
    this.searchableFields = const <String>[],
    this.listTitleBuilder,
    this.listSubtitleBuilder,
  });

  final String name;
  final String singularName;
  final BaseRepository<T> repository;
  final List<FieldDefinition> fields;
  final String idKey;
  final Map<String, dynamic> Function(T entity) toFormValues;
  final Map<String, Set<int>> Function(T entity) toRelationValues;
  final T Function(Map<String, dynamic> values, Map<String, Set<int>> relations) fromForm;
  final List<RelationDefinition<T>> relations;
  final List<String> searchableFields;
  final String Function(T entity)? listTitleBuilder;
  final String Function(T entity)? listSubtitleBuilder;
}

class EntityConfigurations {
  EntityConfigurations()
      : employees = EntityConfiguration<Employee>(
          name: 'Employees',
          singularName: 'Employee',
          idKey: 'employee_id',
          repository: EmployeeRepository(),
          searchableFields: const ['first_name', 'last_name', 'email', 'phone_number'],
          fields: [
            FieldDefinition(key: 'employee_id', label: 'Employee ID', inputType: FieldInputType.number, required: true),
            FieldDefinition(key: 'first_name', label: 'First Name'),
            FieldDefinition(key: 'last_name', label: 'Last Name'),
            FieldDefinition(key: 'address', label: 'Address'),
            FieldDefinition(key: 'phone_number', label: 'Phone Number', inputType: FieldInputType.phone),
            FieldDefinition(key: 'email', label: 'Email', inputType: FieldInputType.email),
            FieldDefinition(key: 'date_of_birth', label: 'Date of Birth', inputType: FieldInputType.date),
            FieldDefinition(key: 'national_id', label: 'National ID'),
            FieldDefinition(key: 'passport_number', label: 'Passport Number', required: false),
            FieldDefinition(key: 'date_of_employment', label: 'Date of Employment', inputType: FieldInputType.date),
            FieldDefinition(key: 'position', label: 'Position'),
            FieldDefinition(key: 'vehicle_registration_number', label: 'Vehicle Registration Number', required: false),
            FieldDefinition(key: 'id_image_path', label: 'ID Document Path', required: false, hint: 'Store a local file path or note'),
            FieldDefinition(key: 'cv_path', label: 'CV File Path', required: false),
          ],
          relations: [
            RelationDefinition<Employee>(
              key: 'court_case_ids',
              label: 'Court Cases',
              loadOptions: () async {
                final cases = await buildCourtCaseRepository().all();
                return cases
                    .map((c) => RelationOption(id: c.courtCaseId, label: '${c.number} – ${c.name}'))
                    .toList();
              },
            ),
            RelationDefinition<Employee>(
              key: 'criminal_record_ids',
              label: 'Criminal Records',
              loadOptions: () async {
                final records = await buildCriminalRecordRepository().all();
                return records
                    .map((r) => RelationOption(id: r.criminalRecordId, label: r.description))
                    .toList();
              },
            ),
          ],
          listTitleBuilder: (employee) => '${employee.firstName} ${employee.lastName}',
          listSubtitleBuilder: (employee) => employee.position,
          toFormValues: (employee) => employee.toMap(),
          toRelationValues: (employee) => {
            'court_case_ids': employee.courtCaseIds,
            'criminal_record_ids': employee.criminalRecordIds,
          },
          fromForm: (values, relations) {
            return Employee(
              employeeId: values['employee_id'] as int,
              firstName: values['first_name'] as String,
              lastName: values['last_name'] as String,
              address: values['address'] as String,
              phoneNumber: values['phone_number'] as String,
              email: values['email'] as String,
              dateOfBirth: values['date_of_birth'] as String,
              nationalId: values['national_id'] as String,
              passportNumber: values['passport_number'] as String?,
              dateOfEmployment: values['date_of_employment'] as String,
              position: values['position'] as String,
              vehicleRegistrationNumber: values['vehicle_registration_number'] as String?,
              idImagePath: values['id_image_path'] as String?,
              cvPath: values['cv_path'] as String?,
              courtCaseIds: relations['court_case_ids'] ?? {},
              criminalRecordIds: relations['criminal_record_ids'] ?? {},
            );
          },
        ),
        nextOfKin = EntityConfiguration<NextOfKin>(
          name: 'Next of Kin',
          singularName: 'Next of Kin Contact',
          idKey: 'next_of_kin_id',
          repository: buildNextOfKinRepository(),
          searchableFields: const ['relationship', 'phone_number', 'email'],
          fields: [
            FieldDefinition(key: 'next_of_kin_id', label: 'ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'phone_number', label: 'Phone Number', inputType: FieldInputType.phone),
            FieldDefinition(key: 'email', label: 'Email', inputType: FieldInputType.email),
            FieldDefinition(key: 'address', label: 'Address'),
            FieldDefinition(key: 'relationship', label: 'Relationship'),
            FieldDefinition(key: 'date_of_birth', label: 'Date of Birth', inputType: FieldInputType.date),
            FieldDefinition(key: 'occupation', label: 'Occupation'),
            FieldDefinition(key: 'id_number', label: 'ID Number'),
          ],
          toFormValues: (kin) => kin.toMap(),
          toRelationValues: (_) => <String, Set<int>>{},
          fromForm: (values, relations) {
            return NextOfKin(
              nextOfKinId: values['next_of_kin_id'] as int,
              phoneNumber: values['phone_number'] as String,
              email: values['email'] as String,
              address: values['address'] as String,
              relationship: values['relationship'] as String,
              dateOfBirth: values['date_of_birth'] as String,
              occupation: values['occupation'] as String,
              idNumber: values['id_number'] as String,
            );
          },
        ),
        directors = EntityConfiguration<Director>(
          name: 'Directors',
          singularName: 'Director',
          idKey: 'director_id',
          repository: buildDirectorRepository(),
          searchableFields: const ['first_name', 'last_name', 'email'],
          fields: [
            FieldDefinition(key: 'director_id', label: 'Director ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'first_name', label: 'First Name'),
            FieldDefinition(key: 'last_name', label: 'Last Name'),
            FieldDefinition(key: 'address', label: 'Address'),
            FieldDefinition(key: 'phone_number', label: 'Phone Number', inputType: FieldInputType.phone),
            FieldDefinition(key: 'email', label: 'Email', inputType: FieldInputType.email),
            FieldDefinition(key: 'date_of_birth', label: 'Date of Birth', inputType: FieldInputType.date),
            FieldDefinition(key: 'national_id', label: 'National ID'),
            FieldDefinition(key: 'passport_number', label: 'Passport Number', required: false),
            FieldDefinition(key: 'vehicle_registration_number', label: 'Vehicle Registration Number', required: false),
          ],
          toFormValues: (director) => director.toMap(),
          toRelationValues: (_) => <String, Set<int>>{},
          fromForm: (values, relations) {
            return Director(
              directorId: values['director_id'] as int,
              firstName: values['first_name'] as String,
              lastName: values['last_name'] as String,
              address: values['address'] as String,
              phoneNumber: values['phone_number'] as String,
              email: values['email'] as String,
              dateOfBirth: values['date_of_birth'] as String,
              nationalId: values['national_id'] as String,
              passportNumber: values['passport_number'] as String?,
              vehicleRegistrationNumber: values['vehicle_registration_number'] as String?,
            );
          },
        ),
        companies = EntityConfiguration<Company>(
          name: 'Companies',
          singularName: 'Company',
          idKey: 'company_id',
          repository: CompanyRepository(),
          searchableFields: const ['name', 'registration_number'],
          fields: [
            FieldDefinition(key: 'company_id', label: 'Company ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'name', label: 'Company Name'),
            FieldDefinition(key: 'address', label: 'Address'),
            FieldDefinition(key: 'phone_number', label: 'Phone Number', inputType: FieldInputType.phone),
            FieldDefinition(key: 'email', label: 'Email', inputType: FieldInputType.email),
            FieldDefinition(key: 'date_of_incorporation', label: 'Date of Incorporation', inputType: FieldInputType.date),
            FieldDefinition(key: 'registration_number', label: 'Registration Number'),
          ],
          relations: [
            RelationDefinition<Company>(
              key: 'director_ids',
              label: 'Directors',
              loadOptions: () async {
                final directors = await buildDirectorRepository().all();
                return directors
                    .map((d) => RelationOption(id: d.directorId, label: '${d.firstName} ${d.lastName}'))
                    .toList();
              },
            ),
            RelationDefinition<Company>(
              key: 'employee_ids',
              label: 'Employees',
              loadOptions: () async {
                final employees = await EmployeeRepository().all();
                return employees
                    .map((e) => RelationOption(id: e.employeeId, label: '${e.firstName} ${e.lastName}'))
                    .toList();
              },
            ),
            RelationDefinition<Company>(
              key: 'next_of_kin_ids',
              label: 'Next of Kin',
              loadOptions: () async {
                final kin = await buildNextOfKinRepository().all();
                return kin
                    .map((k) => RelationOption(id: k.nextOfKinId, label: '${k.relationship} – ${k.phoneNumber}'))
                    .toList();
              },
            ),
            RelationDefinition<Company>(
              key: 'court_case_ids',
              label: 'Court Cases',
              loadOptions: () async {
                final cases = await buildCourtCaseRepository().all();
                return cases
                    .map((c) => RelationOption(id: c.courtCaseId, label: '${c.number} – ${c.name}'))
                    .toList();
              },
            ),
          ],
          listTitleBuilder: (company) => company.name,
          listSubtitleBuilder: (company) => company.registrationNumber,
          toFormValues: (company) => company.toMap(),
          toRelationValues: (company) => {
            'director_ids': company.directorIds,
            'employee_ids': company.employeeIds,
            'next_of_kin_ids': company.nextOfKinIds,
            'court_case_ids': company.courtCaseIds,
          },
          fromForm: (values, relations) {
            return Company(
              companyId: values['company_id'] as int,
              name: values['name'] as String,
              address: values['address'] as String,
              phoneNumber: values['phone_number'] as String,
              email: values['email'] as String,
              dateOfIncorporation: values['date_of_incorporation'] as String,
              registrationNumber: values['registration_number'] as String,
              directorIds: relations['director_ids'] ?? {},
              employeeIds: relations['employee_ids'] ?? {},
              nextOfKinIds: relations['next_of_kin_ids'] ?? {},
              courtCaseIds: relations['court_case_ids'] ?? {},
            );
          },
        ),
        courtCases = EntityConfiguration<CourtCase>(
          name: 'Court Cases',
          singularName: 'Court Case',
          idKey: 'court_case_id',
          repository: buildCourtCaseRepository(),
          searchableFields: const ['name', 'number', 'location', 'judge'],
          fields: [
            FieldDefinition(key: 'court_case_id', label: 'Court Case ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'number', label: 'Case Number'),
            FieldDefinition(key: 'name', label: 'Case Name'),
            FieldDefinition(key: 'type', label: 'Case Type'),
            FieldDefinition(key: 'date', label: 'Date', inputType: FieldInputType.date),
            FieldDefinition(key: 'time', label: 'Time'),
            FieldDefinition(key: 'location', label: 'Location'),
            FieldDefinition(key: 'description', label: 'Description', inputType: FieldInputType.multiline),
            FieldDefinition(key: 'parties', label: 'Parties', inputType: FieldInputType.multiline),
            FieldDefinition(key: 'judge', label: 'Judge'),
          ],
          toFormValues: (caseEntity) => caseEntity.toMap(),
          toRelationValues: (_) => <String, Set<int>>{},
          fromForm: (values, relations) {
            return CourtCase(
              courtCaseId: values['court_case_id'] as int,
              number: values['number'] as String,
              name: values['name'] as String,
              type: values['type'] as String,
              date: values['date'] as String,
              time: values['time'] as String,
              location: values['location'] as String,
              description: values['description'] as String,
              parties: values['parties'] as String,
              judge: values['judge'] as String,
            );
          },
        ),
        customers = EntityConfiguration<Customer>(
          name: 'Customers',
          singularName: 'Customer',
          idKey: 'customer_id',
          repository: CustomerRepository(),
          searchableFields: const ['first_name', 'last_name', 'email', 'phone_number'],
          fields: [
            FieldDefinition(key: 'customer_id', label: 'Customer ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'first_name', label: 'First Name'),
            FieldDefinition(key: 'last_name', label: 'Last Name'),
            FieldDefinition(key: 'address', label: 'Address'),
            FieldDefinition(key: 'phone_number', label: 'Phone Number', inputType: FieldInputType.phone),
            FieldDefinition(key: 'email', label: 'Email', inputType: FieldInputType.email),
            FieldDefinition(key: 'date_of_birth', label: 'Date of Birth', inputType: FieldInputType.date),
            FieldDefinition(key: 'national_id', label: 'National ID'),
            FieldDefinition(key: 'passport_number', label: 'Passport Number', required: false),
            FieldDefinition(key: 'vehicle_registration_number', label: 'Vehicle Registration Number', required: false),
          ],
          relations: [
            RelationDefinition<Customer>(
              key: 'criminal_record_ids',
              label: 'Criminal Records',
              loadOptions: () async {
                final records = await buildCriminalRecordRepository().all();
                return records
                    .map((r) => RelationOption(id: r.criminalRecordId, label: r.description))
                    .toList();
              },
            ),
            RelationDefinition<Customer>(
              key: 'previous_transaction_ids',
              label: 'Previous Transactions',
              loadOptions: () async {
                final transactions = await buildPreviousTransactionRepository().all();
                return transactions
                    .map((t) => RelationOption(id: t.previousTransactionId, label: '${t.date} – ${t.amount}'))
                    .toList();
              },
            ),
            RelationDefinition<Customer>(
              key: 'court_case_ids',
              label: 'Court Cases',
              loadOptions: () async {
                final cases = await buildCourtCaseRepository().all();
                return cases
                    .map((c) => RelationOption(id: c.courtCaseId, label: '${c.number} – ${c.name}'))
                    .toList();
              },
            ),
          ],
          listTitleBuilder: (customer) => '${customer.firstName} ${customer.lastName}',
          listSubtitleBuilder: (customer) => customer.email,
          toFormValues: (customer) => customer.toMap(),
          toRelationValues: (customer) => {
            'criminal_record_ids': customer.criminalRecordIds,
            'previous_transaction_ids': customer.previousTransactionIds,
            'court_case_ids': customer.courtCaseIds,
          },
          fromForm: (values, relations) {
            return Customer(
              customerId: values['customer_id'] as int,
              firstName: values['first_name'] as String,
              lastName: values['last_name'] as String,
              address: values['address'] as String,
              phoneNumber: values['phone_number'] as String,
              email: values['email'] as String,
              dateOfBirth: values['date_of_birth'] as String,
              nationalId: values['national_id'] as String,
              passportNumber: values['passport_number'] as String?,
              vehicleRegistrationNumber: values['vehicle_registration_number'] as String?,
              criminalRecordIds: relations['criminal_record_ids'] ?? {},
              previousTransactionIds: relations['previous_transaction_ids'] ?? {},
              courtCaseIds: relations['court_case_ids'] ?? {},
            );
          },
        ),
        criminalRecords = EntityConfiguration<CriminalRecord>(
          name: 'Criminal Records',
          singularName: 'Criminal Record',
          idKey: 'criminal_record_id',
          repository: buildCriminalRecordRepository(),
          searchableFields: const ['description', 'type'],
          fields: [
            FieldDefinition(key: 'criminal_record_id', label: 'Record ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'description', label: 'Description', inputType: FieldInputType.multiline),
            FieldDefinition(key: 'date', label: 'Date', inputType: FieldInputType.date),
            FieldDefinition(key: 'time', label: 'Time'),
            FieldDefinition(key: 'location', label: 'Location'),
            FieldDefinition(key: 'type', label: 'Type'),
            FieldDefinition(key: 'court_case_id', label: 'Court Case ID', inputType: FieldInputType.number, required: false),
          ],
          toFormValues: (record) => record.toMap(),
          toRelationValues: (_) => <String, Set<int>>{},
          fromForm: (values, relations) {
            return CriminalRecord(
              criminalRecordId: values['criminal_record_id'] as int,
              description: values['description'] as String,
              date: values['date'] as String,
              time: values['time'] as String,
              location: values['location'] as String,
              type: values['type'] as String,
              courtCaseId: values['court_case_id'] as int?,
            );
          },
        ),
        previousTransactions = EntityConfiguration<PreviousTransaction>(
          name: 'Previous Transactions',
          singularName: 'Previous Transaction',
          idKey: 'previous_transaction_id',
          repository: buildPreviousTransactionRepository(),
          searchableFields: const ['description', 'amount'],
          fields: [
            FieldDefinition(key: 'previous_transaction_id', label: 'Transaction ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'date', label: 'Date', inputType: FieldInputType.date),
            FieldDefinition(key: 'time', label: 'Time'),
            FieldDefinition(key: 'amount', label: 'Amount'),
            FieldDefinition(key: 'description', label: 'Description', inputType: FieldInputType.multiline),
          ],
          toFormValues: (transaction) => transaction.toMap(),
          toRelationValues: (_) => <String, Set<int>>{},
          fromForm: (values, relations) {
            return PreviousTransaction(
              previousTransactionId: values['previous_transaction_id'] as int,
              date: values['date'] as String,
              time: values['time'] as String,
              amount: values['amount'] as String,
              description: values['description'] as String,
            );
          },
        ),
        employmentRecords = EntityConfiguration<EmploymentRecord>(
          name: 'Employment Records',
          singularName: 'Employment Record',
          idKey: 'employment_record_id',
          repository: buildEmploymentRecordRepository(),
          searchableFields: const ['description'],
          fields: [
            FieldDefinition(key: 'employment_record_id', label: 'Record ID', inputType: FieldInputType.number),
            FieldDefinition(key: 'date', label: 'Date', inputType: FieldInputType.date),
            FieldDefinition(key: 'time', label: 'Time'),
            FieldDefinition(key: 'description', label: 'Description', inputType: FieldInputType.multiline),
            FieldDefinition(key: 'employee_id', label: 'Employee ID', inputType: FieldInputType.number),
          ],
          toFormValues: (record) => record.toMap(),
          toRelationValues: (_) => <String, Set<int>>{},
          fromForm: (values, relations) {
            return EmploymentRecord(
              employmentRecordId: values['employment_record_id'] as int,
              date: values['date'] as String,
              time: values['time'] as String,
              description: values['description'] as String,
              employeeId: values['employee_id'] as int,
            );
          },
        );

  final EntityConfiguration<Employee> employees;
  final EntityConfiguration<NextOfKin> nextOfKin;
  final EntityConfiguration<Director> directors;
  final EntityConfiguration<Company> companies;
  final EntityConfiguration<CourtCase> courtCases;
  final EntityConfiguration<Customer> customers;
  final EntityConfiguration<CriminalRecord> criminalRecords;
  final EntityConfiguration<PreviousTransaction> previousTransactions;
  final EntityConfiguration<EmploymentRecord> employmentRecords;

}
