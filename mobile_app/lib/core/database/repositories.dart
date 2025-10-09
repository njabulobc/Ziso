import '../domain/entities.dart';
import 'entity_dao.dart';

abstract class BaseRepository<T extends BaseEntity> {
  Future<List<T>> all({String? searchTerm});
  Future<T?> byId(int id);
  Future<void> save(T entity);
  Future<void> remove(int id);
  Future<int> nextId();
}

class SimpleRepository<T extends BaseEntity> extends BaseRepository<T> {
  SimpleRepository({
    required String tableName,
    required String primaryKey,
    required EntityFromMap<T> fromMap,
    required List<String> sortColumns,
    required List<String> searchColumns,
  })  : _dao = EntityDao<T>(
          tableName: tableName,
          primaryKey: primaryKey,
          sortColumns: sortColumns,
          fromMap: fromMap,
        ),
        _searchColumns = searchColumns;

  final EntityDao<T> _dao;
  final List<String> _searchColumns;

  @override
  Future<List<T>> all({String? searchTerm}) {
    return _dao.fetchAll(searchTerm: searchTerm, searchColumns: _searchColumns);
  }

  @override
  Future<T?> byId(int id) => _dao.findById(id);

  @override
  Future<void> remove(int id) => _dao.delete(id);

  @override
  Future<void> save(T entity) => _dao.upsert(entity);

  @override
  Future<int> nextId() => _dao.nextId();
}

class EmployeeRepository extends BaseRepository<Employee> {
  EmployeeRepository()
      : _dao = EntityDao<Employee>(
          tableName: 'employees',
          primaryKey: 'employee_id',
          sortColumns: const ['last_name', 'first_name'],
          fromMap: (map) => Employee.fromMap(map),
        ),
        _courtCases = PivotDao(
          tableName: 'employee_court_cases',
          leftColumn: 'employee_id',
          rightColumn: 'court_case_id',
        ),
        _criminalRecords = PivotDao(
          tableName: 'employee_criminal_records',
          leftColumn: 'employee_id',
          rightColumn: 'criminal_record_id',
        );

  final EntityDao<Employee> _dao;
  final PivotDao _courtCases;
  final PivotDao _criminalRecords;

  @override
  Future<List<Employee>> all({String? searchTerm}) async {
    final results = await _dao.fetchAll(
      searchTerm: searchTerm,
      searchColumns: const ['first_name', 'last_name', 'phone_number', 'email', 'position'],
    );
    return Future.wait(results.map(_hydrate));
  }

  @override
  Future<Employee?> byId(int id) async {
    final employee = await _dao.findById(id);
    if (employee == null) {
      return null;
    }
    return _hydrate(employee);
  }

  Future<Employee> _hydrate(Employee employee) async {
    final courtCases = await _courtCases.loadRightIds(employee.employeeId);
    final criminalRecords = await _criminalRecords.loadRightIds(employee.employeeId);
    return employee.copyWith(
      courtCaseIds: courtCases,
      criminalRecordIds: criminalRecords,
    );
  }

  @override
  Future<void> remove(int id) async {
    await _dao.delete(id);
    await _courtCases.replaceLinks(leftId: id, rightIds: const []);
    await _criminalRecords.replaceLinks(leftId: id, rightIds: const []);
  }

  @override
  Future<void> save(Employee entity) async {
    await _dao.upsert(entity);
    await _courtCases.replaceLinks(
      leftId: entity.employeeId,
      rightIds: entity.courtCaseIds,
    );
    await _criminalRecords.replaceLinks(
      leftId: entity.employeeId,
      rightIds: entity.criminalRecordIds,
    );
  }

  @override
  Future<int> nextId() => _dao.nextId();
}

class CompanyRepository extends BaseRepository<Company> {
  CompanyRepository()
      : _dao = EntityDao<Company>(
          tableName: 'companies',
          primaryKey: 'company_id',
          sortColumns: const ['name'],
          fromMap: (map) => Company.fromMap(map),
        ),
        _directors = PivotDao(
          tableName: 'company_directors',
          leftColumn: 'company_id',
          rightColumn: 'director_id',
        ),
        _employees = PivotDao(
          tableName: 'company_employees',
          leftColumn: 'company_id',
          rightColumn: 'employee_id',
        ),
        _nextOfKin = PivotDao(
          tableName: 'company_next_of_kin',
          leftColumn: 'company_id',
          rightColumn: 'next_of_kin_id',
        ),
        _courtCases = PivotDao(
          tableName: 'company_court_cases',
          leftColumn: 'company_id',
          rightColumn: 'court_case_id',
        );

  final EntityDao<Company> _dao;
  final PivotDao _directors;
  final PivotDao _employees;
  final PivotDao _nextOfKin;
  final PivotDao _courtCases;

  @override
  Future<List<Company>> all({String? searchTerm}) async {
    final companies = await _dao.fetchAll(
      searchTerm: searchTerm,
      searchColumns: const ['name', 'registration_number', 'phone_number', 'email'],
    );
    return Future.wait(companies.map(_hydrate));
  }

  @override
  Future<Company?> byId(int id) async {
    final company = await _dao.findById(id);
    if (company == null) {
      return null;
    }
    return _hydrate(company);
  }

  Future<Company> _hydrate(Company company) async {
    final directors = await _directors.loadRightIds(company.companyId);
    final employees = await _employees.loadRightIds(company.companyId);
    final kin = await _nextOfKin.loadRightIds(company.companyId);
    final cases = await _courtCases.loadRightIds(company.companyId);
    return Company(
      companyId: company.companyId,
      name: company.name,
      address: company.address,
      phoneNumber: company.phoneNumber,
      email: company.email,
      dateOfIncorporation: company.dateOfIncorporation,
      registrationNumber: company.registrationNumber,
      directorIds: directors,
      employeeIds: employees,
      nextOfKinIds: kin,
      courtCaseIds: cases,
    );
  }

  @override
  Future<void> remove(int id) async {
    await _dao.delete(id);
    await _directors.replaceLinks(leftId: id, rightIds: const []);
    await _employees.replaceLinks(leftId: id, rightIds: const []);
    await _nextOfKin.replaceLinks(leftId: id, rightIds: const []);
    await _courtCases.replaceLinks(leftId: id, rightIds: const []);
  }

  @override
  Future<void> save(Company entity) async {
    await _dao.upsert(entity);
    await _directors.replaceLinks(leftId: entity.companyId, rightIds: entity.directorIds);
    await _employees.replaceLinks(leftId: entity.companyId, rightIds: entity.employeeIds);
    await _nextOfKin.replaceLinks(leftId: entity.companyId, rightIds: entity.nextOfKinIds);
    await _courtCases.replaceLinks(leftId: entity.companyId, rightIds: entity.courtCaseIds);
  }

  @override
  Future<int> nextId() => _dao.nextId();
}

class CustomerRepository extends BaseRepository<Customer> {
  CustomerRepository()
      : _dao = EntityDao<Customer>(
          tableName: 'customers',
          primaryKey: 'customer_id',
          sortColumns: const ['last_name', 'first_name'],
          fromMap: (map) => Customer.fromMap(map),
        ),
        _criminalRecords = PivotDao(
          tableName: 'customer_criminal_records',
          leftColumn: 'customer_id',
          rightColumn: 'criminal_record_id',
        ),
        _transactions = PivotDao(
          tableName: 'customer_transactions',
          leftColumn: 'customer_id',
          rightColumn: 'previous_transaction_id',
        ),
        _courtCases = PivotDao(
          tableName: 'customer_court_cases',
          leftColumn: 'customer_id',
          rightColumn: 'court_case_id',
        );

  final EntityDao<Customer> _dao;
  final PivotDao _criminalRecords;
  final PivotDao _transactions;
  final PivotDao _courtCases;

  @override
  Future<List<Customer>> all({String? searchTerm}) async {
    final customers = await _dao.fetchAll(
      searchTerm: searchTerm,
      searchColumns: const ['first_name', 'last_name', 'phone_number', 'email'],
    );
    return Future.wait(customers.map(_hydrate));
  }

  @override
  Future<Customer?> byId(int id) async {
    final customer = await _dao.findById(id);
    if (customer == null) {
      return null;
    }
    return _hydrate(customer);
  }

  Future<Customer> _hydrate(Customer customer) async {
    final criminalRecords = await _criminalRecords.loadRightIds(customer.customerId);
    final transactions = await _transactions.loadRightIds(customer.customerId);
    final courtCases = await _courtCases.loadRightIds(customer.customerId);
    return Customer(
      customerId: customer.customerId,
      firstName: customer.firstName,
      lastName: customer.lastName,
      address: customer.address,
      phoneNumber: customer.phoneNumber,
      email: customer.email,
      dateOfBirth: customer.dateOfBirth,
      nationalId: customer.nationalId,
      passportNumber: customer.passportNumber,
      vehicleRegistrationNumber: customer.vehicleRegistrationNumber,
      criminalRecordIds: criminalRecords,
      previousTransactionIds: transactions,
      courtCaseIds: courtCases,
    );
  }

  @override
  Future<void> remove(int id) async {
    await _dao.delete(id);
    await _criminalRecords.replaceLinks(leftId: id, rightIds: const []);
    await _transactions.replaceLinks(leftId: id, rightIds: const []);
    await _courtCases.replaceLinks(leftId: id, rightIds: const []);
  }

  @override
  Future<void> save(Customer entity) async {
    await _dao.upsert(entity);
    await _criminalRecords.replaceLinks(
      leftId: entity.customerId,
      rightIds: entity.criminalRecordIds,
    );
    await _transactions.replaceLinks(
      leftId: entity.customerId,
      rightIds: entity.previousTransactionIds,
    );
    await _courtCases.replaceLinks(
      leftId: entity.customerId,
      rightIds: entity.courtCaseIds,
    );
  }

  @override
  Future<int> nextId() => _dao.nextId();
}

SimpleRepository<NextOfKin> buildNextOfKinRepository() {
  return SimpleRepository<NextOfKin>(
    tableName: 'next_of_kin',
    primaryKey: 'next_of_kin_id',
    fromMap: (map) => NextOfKin.fromMap(map),
    sortColumns: const ['relationship', 'id_number'],
    searchColumns: const ['relationship', 'phone_number', 'email'],
  );
}

SimpleRepository<Director> buildDirectorRepository() {
  return SimpleRepository<Director>(
    tableName: 'directors',
    primaryKey: 'director_id',
    fromMap: (map) => Director.fromMap(map),
    sortColumns: const ['last_name', 'first_name'],
    searchColumns: const ['first_name', 'last_name', 'email', 'phone_number'],
  );
}

SimpleRepository<CourtCase> buildCourtCaseRepository() {
  return SimpleRepository<CourtCase>(
    tableName: 'court_cases',
    primaryKey: 'court_case_id',
    fromMap: (map) => CourtCase.fromMap(map),
    sortColumns: const ['date DESC', 'number'],
    searchColumns: const ['name', 'number', 'location', 'judge'],
  );
}

SimpleRepository<CriminalRecord> buildCriminalRecordRepository() {
  return SimpleRepository<CriminalRecord>(
    tableName: 'criminal_records',
    primaryKey: 'criminal_record_id',
    fromMap: (map) => CriminalRecord.fromMap(map),
    sortColumns: const ['date DESC', 'criminal_record_id'],
    searchColumns: const ['description', 'type', 'location'],
  );
}

SimpleRepository<PreviousTransaction> buildPreviousTransactionRepository() {
  return SimpleRepository<PreviousTransaction>(
    tableName: 'previous_transactions',
    primaryKey: 'previous_transaction_id',
    fromMap: (map) => PreviousTransaction.fromMap(map),
    sortColumns: const ['date DESC', 'previous_transaction_id'],
    searchColumns: const ['description', 'amount'],
  );
}

SimpleRepository<EmploymentRecord> buildEmploymentRecordRepository() {
  return SimpleRepository<EmploymentRecord>(
    tableName: 'employment_records',
    primaryKey: 'employment_record_id',
    fromMap: (map) => EmploymentRecord.fromMap(map),
    sortColumns: const ['date DESC', 'employment_record_id'],
    searchColumns: const ['description'],
  );
}
