from django.http import JsonResponse
from django.views.generic import View
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from .forms import (
    EmployeeForm,
    NextOfKinForm,
    CompanyForm,
    DirectorForm,
    CourtCasesForm,
    CriminalRecordForm,
    PrevTransactionsForm,
    EmploymentRecordForm,
    CustomerForm,
)


class FormSubmissionView(View):
    form_class = None

    def get_form(self, request):
        return self.form_class(request.POST, request.FILES)

    def get_template_name(self):
        # Implement this method in each subclass to return the appropriate template name
        raise NotImplementedError

    def get_success_response(self):
        return JsonResponse({'success': True})

    def get_error_response(self, form):
        return JsonResponse({'errors': form.errors if form.errors else 'Invalid data'})

    def get(self, request):
        form = self.form_class()
        return render(request, self.get_template_name(), {'form': form})

    def post(self, request):
        form = self.get_form(request)
        if form.is_valid():
            form.save()
            return self.get_success_response()
        return self.get_error_response(form)


class EmployeeView(FormSubmissionView):
    form_class = EmployeeForm

    def get_template_name(self):
        return 'employee.html'


class NextOfKinView(FormSubmissionView):
    form_class = NextOfKinForm

    def get_template_name(self):
        return 'next_of_kin.html'


class CompanyView(FormSubmissionView):
    form_class = CompanyForm

    def get_template_name(self):
        return 'company.html'


class DirectorView(FormSubmissionView):
    form_class = DirectorForm

    def get_template_name(self):
        return 'director.html'


class CourtCasesView(FormSubmissionView):
    form_class = CourtCasesForm

    def get_template_name(self):
        return 'court_cases.html'


class CriminalRecordView(FormSubmissionView):
    form_class = CriminalRecordForm

    def get_template_name(self):
        return 'criminal_record.html'


class PrevTransactionsView(FormSubmissionView):
    form_class = PrevTransactionsForm

    def get_template_name(self):
        return 'prev_transactions.html'


class EmploymentRecordView(FormSubmissionView):
    form_class = EmploymentRecordForm

    def get_template_name(self):
        return 'employment_record.html'


class CustomerView(FormSubmissionView):
    form_class = CustomerForm

    def get_template_name(self):
        return 'customer.html'


@csrf_exempt
def submit_form(request, form_class):
    if request.method == 'POST':
        form = form_class(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'errors': form.errors if form.errors else 'Invalid data'})
