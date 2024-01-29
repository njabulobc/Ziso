from django import forms
from .models import Employee, NextOfKin, Director, Company, CourtCases, Customer, CriminalRecord, PreviousTransactions, EmploymentRecord

class EmployeeForm(forms.ModelForm):
    class Meta:
        model = Employee
        fields = '__all__'  # Include all fields from the Employee model

class NextOfKinForm(forms.ModelForm):
    class Meta:
        model = NextOfKin
        fields = '__all__'  # Include all fields from the NextOfKin model

class DirectorForm(forms.ModelForm):
    class Meta:
        model = Director
        fields = '__all__'  # Include all fields from the Director model

class CompanyForm(forms.ModelForm):
    class Meta:
        model = Company
        fields = '__all__'  # Include all fields from the Company model

class CourtCasesForm(forms.ModelForm):
    class Meta:
        model = CourtCases
        fields = '__all__'  # Include all fields from the CourtCases model

class CriminalRecordForm(forms.ModelForm):
    class Meta:
        model = CriminalRecord
        fields = '__all__'  # Include all fields from the CriminalRecord model

class PrevTransactionsForm(forms.ModelForm):
    class Meta:
        model = PreviousTransactions
        fields = '__all__'  # Include all fields from the PreviousTransactions model

class EmploymentRecordForm(forms.ModelForm):
    class Meta:
        model = EmploymentRecord
        fields = '__all__'  # Include all fields from the EmploymentRecord model

class CustomerForm(forms.ModelForm):
    class Meta:
        model = Customer
        fields = '__all__'  # Include all fields from the Customer model

