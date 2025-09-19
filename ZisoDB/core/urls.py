"""
URL configuration for ZisoDB project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.urls import path

from .views import (
    CompanyListView,
    CompanyView,
    CourtCasesListView,
    CourtCasesView,
    CriminalRecordListView,
    CriminalRecordView,
    CustomerListView,
    CustomerView,
    DirectorListView,
    DirectorView,
    EmployeeListView,
    EmployeeView,
    EmploymentRecordListView,
    EmploymentRecordView,
    HomeView,
    NextOfKinListView,
    NextOfKinView,
    PrevTransactionsListView,
    PrevTransactionsView,
)


urlpatterns = [
    path("", HomeView.as_view(), name="home"),
    path("employee/", EmployeeView.as_view(), name="employee"),
    path("employee/records/", EmployeeListView.as_view(), name="employee_list"),
    path("next-of-kin/", NextOfKinView.as_view(), name="next_of_kin"),
    path(
        "next-of-kin/records/",
        NextOfKinListView.as_view(),
        name="next_of_kin_list",
    ),
    path("company/", CompanyView.as_view(), name="company"),
    path("company/records/", CompanyListView.as_view(), name="company_list"),
    path("director/", DirectorView.as_view(), name="director"),
    path("director/records/", DirectorListView.as_view(), name="director_list"),
    path("court-cases/", CourtCasesView.as_view(), name="court_cases"),
    path(
        "court-cases/records/",
        CourtCasesListView.as_view(),
        name="court_cases_list",
    ),
    path("criminal-record/", CriminalRecordView.as_view(), name="criminal_record"),
    path(
        "criminal-record/records/",
        CriminalRecordListView.as_view(),
        name="criminal_record_list",
    ),
    path("prev-transactions/", PrevTransactionsView.as_view(), name="prev_transactions"),
    path(
        "prev-transactions/records/",
        PrevTransactionsListView.as_view(),
        name="prev_transactions_list",
    ),
    path("employment-record/", EmploymentRecordView.as_view(), name="employment_record"),
    path(
        "employment-record/records/",
        EmploymentRecordListView.as_view(),
        name="employment_record_list",
    ),
    path("customer/", CustomerView.as_view(), name="customer"),
    path("customer/records/", CustomerListView.as_view(), name="customer_list"),
]
