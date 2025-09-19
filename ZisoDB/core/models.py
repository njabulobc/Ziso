from django.db import models


class Employee(models.Model):
    employee_id = models.IntegerField(primary_key=True)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    address = models.CharField(max_length=30)
    phone_number = models.CharField(max_length=30)
    email = models.CharField(max_length=30)
    date_of_birth = models.DateField()
    national_id = models.CharField(max_length=30)
    id_image = models.ImageField(upload_to="images/", blank=True, null=True)
    passport_number = models.CharField(max_length=30, blank=True)
    date_of_employment = models.DateField()
    position = models.CharField(max_length=30)
    court_cases = models.ManyToManyField(
        "CourtCases",
        blank=True,
        related_name="employees",
        help_text="Select any court cases that are relevant to this employee.",
    )
    criminal_records = models.ManyToManyField(
        "CriminalRecord",
        blank=True,
        related_name="employees",
        help_text="Link any criminal records associated with this employee.",
    )
    cv = models.FileField(upload_to="files/", blank=True, null=True)
    vehicle_registration_number = models.CharField(max_length=30, blank=True)

    class Meta:
        ordering = ["last_name", "first_name"]

    def __str__(self) -> str:
        return f"{self.first_name} {self.last_name}".strip()


class NextOfKin(models.Model):
    next_of_kin_id = models.IntegerField(primary_key=True)
    next_of_kin_phone_number = models.CharField(max_length=30)
    next_of_kin_email = models.CharField(max_length=30)
    next_of_kin_address = models.CharField(max_length=30)
    next_of_kin_relationship = models.CharField(max_length=30)
    next_of_kin_date_of_birth = models.DateField()
    next_of_kin_occupation = models.CharField(max_length=30)
    next_of_kin_id_number = models.CharField(max_length=30)

    class Meta:
        ordering = ["next_of_kin_relationship", "next_of_kin_id_number"]

    def __str__(self) -> str:
        return f"{self.next_of_kin_relationship} – {self.next_of_kin_phone_number}"


class Director(models.Model):
    director_id = models.IntegerField(primary_key=True)
    director_first_name = models.CharField(max_length=30)
    director_last_name = models.CharField(max_length=30)
    director_address = models.CharField(max_length=30)
    director_phone_number = models.CharField(max_length=30)
    director_email = models.CharField(max_length=30)
    director_date_of_birth = models.DateField()
    director_national_id = models.CharField(max_length=30)
    director_passport_number = models.CharField(max_length=30, blank=True)
    director_vehicle_registration_number = models.CharField(max_length=30, blank=True)

    class Meta:
        ordering = ["director_last_name", "director_first_name"]

    def __str__(self) -> str:
        return f"{self.director_first_name} {self.director_last_name}".strip()


class Company(models.Model):
    company_id = models.IntegerField(primary_key=True)
    company_name = models.CharField(max_length=30)
    company_address = models.CharField(max_length=30)
    company_phone_number = models.CharField(max_length=30)
    company_email = models.CharField(max_length=30)
    company_date_of_incorporation = models.DateField()
    company_registration_number = models.CharField(max_length=30)
    directors = models.ManyToManyField(
        "Director",
        blank=True,
        related_name="companies",
        help_text="Associate directors responsible for this company.",
    )
    employees = models.ManyToManyField(
        "Employee",
        blank=True,
        related_name="companies",
        help_text="Attach employees working for this company.",
    )
    next_of_kin = models.ManyToManyField(
        "NextOfKin",
        blank=True,
        related_name="companies",
        help_text="Reference next of kin contacts for company stakeholders.",
    )
    court_cases = models.ManyToManyField(
        "CourtCases",
        blank=True,
        related_name="companies",
        help_text="Log relevant court cases for this company.",
    )

    class Meta:
        ordering = ["company_name"]

    def __str__(self) -> str:
        return self.company_name


class CourtCases(models.Model):
    court_case_id = models.IntegerField(primary_key=True)
    court_case_number = models.CharField(max_length=30)
    court_case_name = models.CharField(max_length=30)
    court_case_type = models.CharField(max_length=30)
    court_case_date = models.DateField()
    court_case_time = models.CharField(max_length=30)
    court_case_location = models.CharField(max_length=30)
    court_case_description = models.CharField(max_length=30)
    court_case_parties = models.CharField(max_length=30)
    court_case_judge = models.CharField(max_length=30)

    class Meta:
        ordering = ["-court_case_date", "court_case_number"]

    def __str__(self) -> str:
        return f"{self.court_case_number} – {self.court_case_name}"


class Customer(models.Model):
    customer_id = models.IntegerField(primary_key=True)
    customer_first_name = models.CharField(max_length=30)
    customer_last_name = models.CharField(max_length=30)
    customer_address = models.CharField(max_length=30)
    customer_phone_number = models.CharField(max_length=30)
    customer_email = models.CharField(max_length=30)
    customer_date_of_birth = models.DateField()
    customer_national_id = models.CharField(max_length=30)
    customer_passport_number = models.CharField(max_length=30, blank=True)
    customer_vehicle_registration_number = models.CharField(max_length=30, blank=True)
    criminal_records = models.ManyToManyField(
        "CriminalRecord",
        blank=True,
        related_name="customers",
        help_text="Link background screening findings to this customer.",
    )
    previous_transactions = models.ManyToManyField(
        "PreviousTransactions",
        blank=True,
        related_name="customers",
        help_text="Associate historical transactions for this customer.",
    )
    court_cases = models.ManyToManyField(
        "CourtCases",
        blank=True,
        related_name="customers",
        help_text="Attach any court cases involving this customer.",
    )

    class Meta:
        ordering = ["customer_last_name", "customer_first_name"]

    def __str__(self) -> str:
        return f"{self.customer_first_name} {self.customer_last_name}".strip()


class CriminalRecord(models.Model):
    criminal_record_id = models.IntegerField(primary_key=True)
    criminal_record_description = models.CharField(max_length=30)
    criminal_record_date = models.DateField()
    criminal_record_time = models.CharField(max_length=30)
    criminal_record_location = models.CharField(max_length=30)
    criminal_record_type = models.CharField(max_length=30)
    criminal_record_court_case = models.ForeignKey(
        "CourtCases",
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name="criminal_records",
        help_text="Optional reference to the court case linked to this record.",
    )

    class Meta:
        ordering = ["-criminal_record_date", "criminal_record_id"]

    def __str__(self) -> str:
        return f"{self.criminal_record_type} on {self.criminal_record_date}"


class PreviousTransactions(models.Model):
    previous_transaction_id = models.IntegerField(primary_key=True)
    previous_transaction_date = models.DateField()
    previous_transaction_time = models.CharField(max_length=30)
    previous_transaction_amount = models.CharField(max_length=30)
    previous_transaction_description = models.CharField(max_length=30)

    class Meta:
        ordering = ["-previous_transaction_date", "previous_transaction_id"]

    def __str__(self) -> str:
        return f"{self.previous_transaction_date} – {self.previous_transaction_amount}"


class EmploymentRecord(models.Model):
    employment_record_id = models.IntegerField(primary_key=True)
    employment_record_date = models.DateField()
    employment_record_time = models.CharField(max_length=30)
    employment_record_description = models.CharField(max_length=30)
    employment_record_employee = models.ForeignKey(
        "Employee",
        on_delete=models.CASCADE,
        related_name="employment_records",
    )

    class Meta:
        ordering = ["-employment_record_date", "employment_record_id"]

    def __str__(self) -> str:
        return f"{self.employment_record_employee} – {self.employment_record_date}"

