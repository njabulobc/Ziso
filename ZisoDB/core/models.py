from django.db import models
from django import forms

# Create your models here.
# Django modelforms below
class Employee(models.Model):
    employee_id = models.IntegerField(primary_key=True)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    address = models.CharField(max_length=30)
    phone_number = models.CharField(max_length=30)
    email = models.CharField(max_length=30)
    date_of_birth = models.DateField()
    national_id = models.CharField(max_length=30)
    id_image = models.ImageField(upload_to='images/')
    passport_number = models.CharField(max_length=30)
    date_of_employment = models.DateField()
    position = models.CharField(max_length=30)
#   point to next of kin table
    court = models.ForeignKey('Court', on_delete=models.CASCADE)
    # point to criminal record table
    criminal_record = models.ForeignKey('CriminalRecord', on_delete=models.CASCADE)
    # point to employment record table
    employment_record = models.ForeignKey('EmploymentRecord', on_delete=models.CASCADE)
    cv = models.FileField(upload_to='files/')
    vehicle_registration_number = models.CharField(max_length=30)

class NextOfKin(models.Model):
    next_of_kin_id = models.IntegerField(primary_key=True)
    next_of_kin_phone_number = models.CharField(max_length=30)
    next_of_kin_email = models.CharField(max_length=30)
    next_of_kin_address = models.CharField(max_length=30)
    next_of_kin_relationship = models.CharField(max_length=30)
    next_of_kin_date_of_birth = models.DateField()
    next_of_kin_occupation = models.CharField(max_length=30)
    next_of_kin_id_number = models.CharField(max_length=30)

class Director(models.Model):
    director_id = models.IntegerField(primary_key=True)
    director_first_name = models.CharField(max_length=30)
    director_last_name = models.CharField(max_length=30)
    director_address = models.CharField(max_length=30)
    director_phone_number = models.CharField(max_length=30)
    director_email = models.CharField(max_length=30)
    director_date_of_birth = models.DateField()
    director_national_id = models.CharField(max_length=30)
    director_passport_number = models.CharField(max_length=30)
    director_vehicle_registration_number = models.CharField(max_length=30)

class Company(models.Model):
    company_id = models.IntegerField(primary_key=True)
    company_name = models.CharField(max_length=30)
    company_address = models.CharField(max_length=30)
    company_phone_number = models.CharField(max_length=30)
    company_email = models.CharField(max_length=30)
    company_date_of_incorporation = models.DateField()
    company_registration_number = models.CharField(max_length=30)
    company_director = models.ForeignKey('Director', on_delete=models.CASCADE)
    company_employees = models.ForeignKey('Employee', on_delete=models.CASCADE)
    company_next_of_kin = models.ForeignKey('NextOfKin', on_delete=models.CASCADE)
    company_court = models.ForeignKey('Court', on_delete=models.CASCADE)

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

class Customer(models.Model):
    customer_id = models.IntegerField(primary_key=True)
    customer_first_name = models.CharField(max_length=30)
    customer_last_name = models.CharField(max_length=30)
    customer_address = models.CharField(max_length=30)
    customer_phone_number = models.CharField(max_length=30)
    customer_email = models.CharField(max_length=30)
    customer_date_of_birth = models.DateField()
    customer_national_id = models.CharField(max_length=30)
    customer_passport_number = models.CharField(max_length=30)
    customer_vehicle_registration_number = models.CharField(max_length=30)
    customer_criminal_record = models.ForeignKey('CriminalRecord', on_delete=models.CASCADE)
    customer_previous_transactions = models.ForeignKey('PreviousTransactions', on_delete=models.CASCADE)
    court_case = models.ForeignKey('CourtCases', on_delete=models.CASCADE)

class CriminalRecord(models.Model):
    criminal_record_id = models.IntegerField(primary_key=True)
    criminal_record_description = models.CharField(max_length=30)
    criminal_record_date = models.DateField()
    criminal_record_time = models.CharField(max_length=30)
    criminal_record_location = models.CharField(max_length=30)
    criminal_record_type = models.CharField(max_length=30)
    criminal_record_court_case = models.ForeignKey('CourtCases', on_delete=models.CASCADE)

class PreviousTransactions(models.Model):
    previous_transaction_id = models.IntegerField(primary_key=True)
    previous_transaction_date = models.DateField()
    previous_transaction_time = models.CharField(max_length=30)
    previous_transaction_amount = models.CharField(max_length=30)
    previous_transaction_description = models.CharField(max_length=30)

class EmploymentRecord(models.Model):
    employment_record_id = models.IntegerField(primary_key=True)
    employment_record_date = models.DateField()
    employment_record_time = models.CharField(max_length=30)
    employment_record_description = models.CharField(max_length=30)
    employment_record_employee = models.ForeignKey('Employee', on_delete=models.CASCADE)

