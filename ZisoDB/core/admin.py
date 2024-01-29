from django.contrib import admin
from .models import Employee, NextOfKin, Director, Company, Customer, CourtCases, CriminalRecord, PreviousTransactions,\
    EmploymentRecord

# Register your models here.
admin.site.register(Employee)
admin.site.register(NextOfKin)
admin.site.register(Director)
admin.site.register(Company)
admin.site.register(Customer)
admin.site.register(CourtCases)
admin.site.register(CriminalRecord)
admin.site.register(PreviousTransactions)
admin.site.register(EmploymentRecord)
