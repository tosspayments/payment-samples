from django.urls import path
from . import views

urlpatterns = [
  path('', views.index),
  path('vaapi', views.vaapi),
  path('va-callback', views.va_callback),

]