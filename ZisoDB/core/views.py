from django import forms as django_forms
from django.contrib import messages
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse
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


FORM_METADATA = {
    "employee": {
        "title": "Employee Profile",
        "description": "Capture detailed employee demographics, compliance checks, and onboarding details in a single, auditable record.",
        "success_message": "Employee profile saved successfully.",
        "submit_label": "Save employee profile",
        "cta": "Create employee record",
        "icon": "👤",
        "url_name": "employee",
    },
    "next_of_kin": {
        "title": "Next of Kin",
        "description": "Register trusted contacts for employees or directors so you can respond quickly in critical situations.",
        "success_message": "Next of kin information saved successfully.",
        "submit_label": "Save next of kin details",
        "cta": "Add next of kin record",
        "icon": "👪",
        "url_name": "next_of_kin",
    },
    "company": {
        "title": "Company Details",
        "description": "Maintain an up-to-date company registry complete with governance relationships and compliance artefacts.",
        "success_message": "Company record saved successfully.",
        "submit_label": "Save company profile",
        "cta": "Add company record",
        "icon": "🏢",
        "url_name": "company",
    },
    "director": {
        "title": "Director Profile",
        "description": "Keep track of director identity information, credentials, and governance responsibilities.",
        "success_message": "Director details saved successfully.",
        "submit_label": "Save director details",
        "cta": "Register director",
        "icon": "🧑‍💼",
        "url_name": "director",
    },
    "court_cases": {
        "title": "Court Case",
        "description": "Document ongoing or historical court cases that influence risk scoring and due diligence.",
        "success_message": "Court case saved successfully.",
        "submit_label": "Save court case information",
        "cta": "Log court case",
        "icon": "⚖️",
        "url_name": "court_cases",
    },
    "criminal_record": {
        "title": "Criminal Record",
        "description": "Track criminal record findings surfaced during background screening and compliance checks.",
        "success_message": "Criminal record saved successfully.",
        "submit_label": "Save criminal record",
        "cta": "Add criminal record",
        "icon": "🛡️",
        "url_name": "criminal_record",
    },
    "prev_transactions": {
        "title": "Previous Transaction",
        "description": "Record historical transactions to inform enhanced due diligence and monitoring activities.",
        "success_message": "Previous transaction saved successfully.",
        "submit_label": "Save transaction history",
        "cta": "Log transaction",
        "icon": "💳",
        "url_name": "prev_transactions",
    },
    "employment_record": {
        "title": "Employment Record",
        "description": "Maintain a chronological employment history to evidence role changes and performance checkpoints.",
        "success_message": "Employment record saved successfully.",
        "submit_label": "Save employment record",
        "cta": "Add employment record",
        "icon": "📁",
        "url_name": "employment_record",
    },
    "customer": {
        "title": "Customer Profile",
        "description": "Collect KYC information, linked transactions, and compliance indicators for each customer.",
        "success_message": "Customer profile saved successfully.",
        "submit_label": "Save customer profile",
        "cta": "Create customer profile",
        "icon": "🙍",
        "url_name": "customer",
    },
}


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
            }
            for config in FORM_METADATA.values()
        ]
        return context


class TailwindFormView(View):
    template_name = "core/form.html"
    form_class = None
    config_key = None

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
        context = {"page_config": page_config, "submit_label": page_config["submit_label"], "form_action": self.request.path}
        context.update(kwargs)
        context["page_title"] = page_config["title"]
        context["breadcrumbs"] = self._build_breadcrumbs(page_config)
        return context

    def get_page_config(self):
        if self.config_key is None or self.config_key not in FORM_METADATA:
            raise ValueError("Form view misconfigured – missing metadata key.")
        return FORM_METADATA[self.config_key]

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
