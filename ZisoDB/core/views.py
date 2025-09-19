import datetime

from django import forms as django_forms
from django.contrib import messages
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse
from django.utils import formats, timezone
from django.views.generic import TemplateView, View

from .forms import (
    CompanyForm,
    CourtCasesForm,
    CriminalRecordForm,
    CustomerForm,
    DirectorForm,
    EmployeeForm,
    EmploymentRecordForm,
    NextOfKinForm,
    PrevTransactionsForm,
)
from .models import (
    Company,
    CourtCases,
    CriminalRecord,
    Customer,
    Director,
    Employee,
    EmploymentRecord,
    NextOfKin,
    PreviousTransactions,
)


FORM_METADATA = {
    "employee": {
        "title": "Employee Profile",
        "description": "Capture detailed employee demographics, compliance checks, and onboarding details in a single, auditable record.",
        "success_message": "Employee profile saved successfully.",
        "submit_label": "Save employee profile",
        "cta": "Create employee record",
        "icon": "👤",
        "url_name": "employee",
        "list_url_name": "employee_list",
        "list_label": "Browse employee records",
        "empty_message": "No employee profiles have been captured yet.",
        "list_fields": [
            ("employee_id", "Employee ID"),
            ("first_name", "First name"),
            ("last_name", "Last name"),
            ("position", "Position"),
            ("date_of_employment", "Start date"),
        ],
        "model": Employee,
    },
    "next_of_kin": {
        "title": "Next of Kin",
        "description": "Register trusted contacts for employees or directors so you can respond quickly in critical situations.",
        "success_message": "Next of kin information saved successfully.",
        "submit_label": "Save next of kin details",
        "cta": "Add next of kin record",
        "icon": "👪",
        "url_name": "next_of_kin",
        "list_url_name": "next_of_kin_list",
        "list_label": "View next of kin contacts",
        "empty_message": "No next of kin contacts recorded yet.",
        "list_fields": [
            ("next_of_kin_id", "Reference"),
            ("next_of_kin_relationship", "Relationship"),
            ("next_of_kin_phone_number", "Phone"),
            ("next_of_kin_email", "Email"),
        ],
        "model": NextOfKin,
    },
    "company": {
        "title": "Company Details",
        "description": "Maintain an up-to-date company registry complete with governance relationships and compliance artefacts.",
        "success_message": "Company record saved successfully.",
        "submit_label": "Save company profile",
        "cta": "Add company record",
        "icon": "🏢",
        "url_name": "company",
        "list_url_name": "company_list",
        "list_label": "Review company registry",
        "empty_message": "No companies have been registered yet.",
        "list_fields": [
            ("company_id", "Company ID"),
            ("company_name", "Company"),
            ("company_registration_number", "Registration"),
            ("company_phone_number", "Phone"),
            ("company_email", "Email"),
        ],
        "model": Company,
    },
    "director": {
        "title": "Director Profile",
        "description": "Keep track of director identity information, credentials, and governance responsibilities.",
        "success_message": "Director details saved successfully.",
        "submit_label": "Save director details",
        "cta": "Register director",
        "icon": "🧑‍💼",
        "url_name": "director",
        "list_url_name": "director_list",
        "list_label": "View directors",
        "empty_message": "No directors recorded yet.",
        "list_fields": [
            ("director_id", "Director ID"),
            ("director_first_name", "First name"),
            ("director_last_name", "Last name"),
            ("director_phone_number", "Phone"),
            ("director_email", "Email"),
        ],
        "model": Director,
    },
    "court_cases": {
        "title": "Court Case",
        "description": "Document ongoing or historical court cases that influence risk scoring and due diligence.",
        "success_message": "Court case saved successfully.",
        "submit_label": "Save court case information",
        "cta": "Log court case",
        "icon": "⚖️",
        "url_name": "court_cases",
        "list_url_name": "court_cases_list",
        "list_label": "Track court cases",
        "empty_message": "No court cases logged yet.",
        "list_fields": [
            ("court_case_number", "Case number"),
            ("court_case_name", "Case name"),
            ("court_case_type", "Type"),
            ("court_case_date", "Date"),
            ("court_case_location", "Location"),
        ],
        "model": CourtCases,
    },
    "criminal_record": {
        "title": "Criminal Record",
        "description": "Track criminal record findings surfaced during background screening and compliance checks.",
        "success_message": "Criminal record saved successfully.",
        "submit_label": "Save criminal record",
        "cta": "Add criminal record",
        "icon": "🛡️",
        "url_name": "criminal_record",
        "list_url_name": "criminal_record_list",
        "list_label": "Browse criminal records",
        "empty_message": "No criminal records have been logged yet.",
        "list_fields": [
            ("criminal_record_id", "Record ID"),
            ("criminal_record_type", "Type"),
            ("criminal_record_date", "Date"),
            ("criminal_record_location", "Location"),
            ("criminal_record_court_case", "Court case"),
        ],
        "model": CriminalRecord,
    },
    "prev_transactions": {
        "title": "Previous Transaction",
        "description": "Record historical transactions to inform enhanced due diligence and monitoring activities.",
        "success_message": "Previous transaction saved successfully.",
        "submit_label": "Save transaction history",
        "cta": "Log transaction",
        "icon": "💳",
        "url_name": "prev_transactions",
        "list_url_name": "prev_transactions_list",
        "list_label": "Review past transactions",
        "empty_message": "No historical transactions recorded yet.",
        "list_fields": [
            ("previous_transaction_id", "Reference"),
            ("previous_transaction_date", "Date"),
            ("previous_transaction_time", "Time"),
            ("previous_transaction_amount", "Amount"),
            ("previous_transaction_description", "Description"),
        ],
        "model": PreviousTransactions,
    },
    "employment_record": {
        "title": "Employment Record",
        "description": "Maintain a chronological employment history to evidence role changes and performance checkpoints.",
        "success_message": "Employment record saved successfully.",
        "submit_label": "Save employment record",
        "cta": "Add employment record",
        "icon": "📁",
        "url_name": "employment_record",
        "list_url_name": "employment_record_list",
        "list_label": "View employment history",
        "empty_message": "No employment records captured yet.",
        "list_fields": [
            ("employment_record_id", "Record ID"),
            ("employment_record_employee", "Employee"),
            ("employment_record_date", "Date"),
            ("employment_record_time", "Time"),
            ("employment_record_description", "Description"),
        ],
        "model": EmploymentRecord,
    },
    "customer": {
        "title": "Customer Profile",
        "description": "Collect KYC information, linked transactions, and compliance indicators for each customer.",
        "success_message": "Customer profile saved successfully.",
        "submit_label": "Save customer profile",
        "cta": "Create customer profile",
        "icon": "🙍",
        "url_name": "customer",
        "list_url_name": "customer_list",
        "list_label": "Browse customer profiles",
        "empty_message": "No customer profiles created yet.",
        "list_fields": [
            ("customer_id", "Customer ID"),
            ("customer_first_name", "First name"),
            ("customer_last_name", "Last name"),
            ("customer_phone_number", "Phone"),
            ("customer_email", "Email"),
        ],
        "model": Customer,
    },
}


class MetadataMixin:
    config_key = None

    def get_page_config(self):
        if self.config_key is None or self.config_key not in FORM_METADATA:
            raise ValueError("View misconfigured – missing metadata key.")
        return FORM_METADATA[self.config_key]


class HomeView(TemplateView):
    template_name = "core/home.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["page_title"] = "Intelligence workspace"
        context["form_pages"] = [
            {
                "title": config["title"],
                "description": config["description"],
                "cta": config["cta"],
                "icon": config["icon"],
                "url": reverse(config["url_name"]),
                "view_url": reverse(config["list_url_name"]),
                "view_label": config.get("list_label"),
                "record_count": config.get("model").objects.count()
                if config.get("model")
                else None,
            }
            for config in FORM_METADATA.values()
        ]
        return context


class TailwindFormView(MetadataMixin, View):
    template_name = "core/form.html"
    form_class = None

    def get(self, request, *args, **kwargs):
        form = self.get_form()
        return render(request, self.template_name, self.get_context_data(form=form))

    def post(self, request, *args, **kwargs):
        form = self.get_form(data=request.POST, files=request.FILES)
        if form.is_valid():
            form.save()
            if self._is_ajax(request):
                return JsonResponse(
                    {
                        "success": True,
                        "message": self.get_page_config()["success_message"],
                    },
                    status=201,
                )

            messages.success(request, self.get_page_config()["success_message"])
            return redirect(request.path)

        if self._is_ajax(request):
            return JsonResponse(
                {
                    "success": False,
                    "message": "Please review the highlighted fields.",
                    "errors": self._serialise_errors(form),
                },
                status=400,
            )

        messages.error(request, "Please review the highlighted fields and try again.")
        return render(
            request,
            self.template_name,
            self.get_context_data(form=form),
            status=400,
        )

    def get_form(self, data=None, files=None):
        form = self.form_class(data=data, files=files)
        self._style_form(form)
        return form

    def get_context_data(self, **kwargs):
        page_config = self.get_page_config()
        context = {
            "page_config": page_config,
            "submit_label": page_config["submit_label"],
            "form_action": self.request.path,
        }
        context.update(kwargs)
        context["page_title"] = page_config["title"]
        context["breadcrumbs"] = self._build_breadcrumbs(page_config)
        if page_config.get("list_url_name"):
            context["list_url"] = reverse(page_config["list_url_name"])
            context["list_link_label"] = page_config.get(
                "list_label", f"View {page_config['title'].lower()}"
            )
        return context

    def _build_breadcrumbs(self, page_config):
        return [
            {"label": "Dashboard", "url": reverse("home")},
            {"label": page_config["title"], "url": ""},
        ]

    def _style_form(self, form):
        text_input_classes = (
            "block w-full rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm "
            "text-slate-900 shadow-sm transition focus:border-indigo-500 focus:outline-none "
            "focus:ring-2 focus:ring-indigo-500 focus:ring-offset-1"
        )
        file_input_classes = (
            "block w-full text-sm text-slate-900 file:mr-4 file:rounded-lg file:border-0 "
            "file:bg-indigo-600 file:px-4 file:py-2 file:font-semibold file:text-white "
            "hover:file:bg-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 "
            "focus:ring-offset-1"
        )
        checkbox_classes = (
            "h-4 w-4 rounded border-slate-300 text-indigo-600 shadow-sm focus:ring-indigo-500"
        )

        for name, field in form.fields.items():
            widget = field.widget
            widget.attrs["data-field-input"] = name

            if isinstance(widget, django_forms.widgets.CheckboxInput):
                widget.attrs["class"] = checkbox_classes
            elif isinstance(widget, django_forms.widgets.FileInput):
                widget.attrs["class"] = file_input_classes
            else:
                base_classes = text_input_classes
                if isinstance(widget, django_forms.widgets.Textarea):
                    widget.attrs.setdefault("rows", "4")
                    base_classes += " resize-y"
                widget.attrs["class"] = base_classes

                if isinstance(widget, django_forms.widgets.DateInput):
                    widget.input_type = "date"

                if not isinstance(widget, django_forms.widgets.Select):
                    widget.attrs.setdefault("placeholder", field.label)

            if isinstance(field, django_forms.ModelChoiceField) and field.empty_label is not None:
                field.empty_label = f"Select {field.label.lower()}"

    def _serialise_errors(self, form):
        errors = {
            field: [str(message) for message in error_list]
            for field, error_list in form.errors.items()
        }
        non_field = form.non_field_errors()
        if non_field:
            errors["__all__"] = [str(message) for message in non_field]
        return errors

    def _is_ajax(self, request):
        return request.headers.get("X-Requested-With") == "XMLHttpRequest"


class EmployeeView(TailwindFormView):
    form_class = EmployeeForm
    config_key = "employee"


class NextOfKinView(TailwindFormView):
    form_class = NextOfKinForm
    config_key = "next_of_kin"


class CompanyView(TailwindFormView):
    form_class = CompanyForm
    config_key = "company"


class DirectorView(TailwindFormView):
    form_class = DirectorForm
    config_key = "director"


class CourtCasesView(TailwindFormView):
    form_class = CourtCasesForm
    config_key = "court_cases"


class CriminalRecordView(TailwindFormView):
    form_class = CriminalRecordForm
    config_key = "criminal_record"


class PrevTransactionsView(TailwindFormView):
    form_class = PrevTransactionsForm
    config_key = "prev_transactions"


class EmploymentRecordView(TailwindFormView):
    form_class = EmploymentRecordForm
    config_key = "employment_record"


class CustomerView(TailwindFormView):
    form_class = CustomerForm
    config_key = "customer"


class RecordListView(MetadataMixin, TemplateView):
    template_name = "core/list.html"
    model = None
    list_fields = None

    def get_model(self):
        if self.model is not None:
            return self.model
        page_config = self.get_page_config()
        model = page_config.get("model")
        if model is None:
            raise ValueError("List view misconfigured – missing model metadata.")
        return model

    def get_queryset(self):
        return self.get_model().objects.all()

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        page_config = self.get_page_config()
        context["page_config"] = page_config
        context["page_title"] = f"{page_config['title']} records"
        context["breadcrumbs"] = [
            {"label": "Dashboard", "url": reverse("home")},
            {"label": page_config["title"], "url": reverse(page_config["url_name"])},
            {"label": "Records", "url": ""},
        ]
        context["create_url"] = reverse(page_config["url_name"])
        context["create_label"] = page_config.get("cta", "Create record")
        context["columns"] = self.get_columns()
        context["rows"] = self.get_rows()
        context["empty_message"] = page_config.get(
            "empty_message", "No records have been captured yet."
        )
        context["record_count"] = len(context["rows"])
        return context

    def get_columns(self):
        field_config = self.list_fields or self.get_page_config().get("list_fields", [])
        columns = []
        for field_name, label in field_config:
            columns.append({"name": field_name, "label": label})
        if not columns:
            model = self.get_model()
            for field in model._meta.fields[:5]:
                columns.append({"name": field.name, "label": field.verbose_name.title()})
        return columns

    def get_rows(self):
        rows = []
        columns = self.get_columns()
        for obj in self.get_queryset():
            rows.append(
                {
                    "object": obj,
                    "values": [self._resolve_value(obj, column["name"]) for column in columns],
                }
            )
        return rows

    def _resolve_value(self, obj, field_name):
        value = getattr(obj, field_name, None)
        if hasattr(value, "all"):
            values = [str(item) for item in value.all()]
            return ", ".join(values) if values else "—"
        if isinstance(value, datetime.datetime):
            value = timezone.localtime(value) if timezone.is_aware(value) else value
            return formats.date_format(value, "DATETIME_FORMAT")
        if isinstance(value, datetime.date):
            return formats.date_format(value, "DATE_FORMAT")
        if isinstance(value, datetime.time):
            return formats.time_format(value, "TIME_FORMAT")
        if value in (None, ""):
            return "—"
        return str(value)


class EmployeeListView(RecordListView):
    config_key = "employee"
    model = Employee


class NextOfKinListView(RecordListView):
    config_key = "next_of_kin"
    model = NextOfKin


class CompanyListView(RecordListView):
    config_key = "company"
    model = Company


class DirectorListView(RecordListView):
    config_key = "director"
    model = Director


class CourtCasesListView(RecordListView):
    config_key = "court_cases"
    model = CourtCases


class CriminalRecordListView(RecordListView):
    config_key = "criminal_record"
    model = CriminalRecord


class PrevTransactionsListView(RecordListView):
    config_key = "prev_transactions"
    model = PreviousTransactions


class EmploymentRecordListView(RecordListView):
    config_key = "employment_record"
    model = EmploymentRecord


class CustomerListView(RecordListView):
    config_key = "customer"
    model = Customer
