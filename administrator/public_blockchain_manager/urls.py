from django.urls import path, include
from rest_framework.routers import DefaultRouter

app_name = 'public_blockchain_manager' # namespace

router = DefaultRouter()

urlpatterns = [
    path('', include(router.urls)),

]