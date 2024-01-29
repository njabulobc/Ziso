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
    EmployeeView,
    NextOfKinView,
    CompanyView,
    DirectorView,
    CourtCasesView,
    CriminalRecordView,
    PrevTransactionsView,
    EmploymentRecordView,
    CustomerView,
    submit_form,
)

urlpatterns = [
    path('employee/', EmployeeView.as_view(), name='employee'),
    path('next-of-kin/', NextOfKinView.as_view(), name='next_of_kin'),
    path('company/', CompanyView.as_view(), name='company'),
    path('director/', DirectorView.as_view(), name='director'),
    path('court-cases/', CourtCasesView.as_view(), name='court_cases'),
    path('criminal-record/', CriminalRecordView.as_view(), name='criminal_record'),
    path('prev-transactions/', PrevTransactionsView.as_view(), name='prev_transactions'),
    path('employment-record/', EmploymentRecordView.as_view(), name='employment_record'),
    path('customer/', CustomerView.as_view(), name='customer'),
    path('submit-form/<str:form_class>/', submit_form, name='submit_form'),
]
