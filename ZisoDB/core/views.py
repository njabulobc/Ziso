from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .forms import EmployeeForm, NextOfKinForm, DirectorForm, CompanyForm, CustomerForm, CourtCasesForm, CriminalRecordForm, PreviousTransactionsForm, EmploymentRecordForm
from django.shortcuts import render

@csrf_exempt
def submit_employee_form(request):
    if request.method == 'POST':
        form = EmployeeForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_next_of_kin_form(request):
    if request.method == 'POST':
        form = NextOfKinForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_director_form(request):
    if request.method == 'POST':
        form = DirectorForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_company_form(request):
    if request.method == 'POST':
        form = CompanyForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_court_cases_form(request):
    if request.method == 'POST':
        form = CourtCasesForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_criminal_record_form(request):
    if request.method == 'POST':
        form = CriminalRecordForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_previous_transactions_form(request):
    if request.method == 'POST':
        form = PreviousTransactionsForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_employment_record_form(request):
    if request.method == 'POST':
        form = EmploymentRecordForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

@csrf_exempt
def submit_customer_form(request):
    if request.method == 'POST':
        form = CustomerForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors})
    else:
        return JsonResponse({'errors': 'Invalid request method'})

def index(request):
    return render(request, 'index.html')