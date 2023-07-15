"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
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
from django.contrib import admin
from django.urls import path, include, re_path
from rest_framework.routers import DefaultRouter

from django.conf.urls.static import static

from core import urls as core_urls
from manufacturer import urls as mfg_urls
from public_blockchain_manager import urls as public_web3_urls
from logistics import urls as logistics_urls
from exim_service import urls as exim_urls

from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

from django.conf import settings

router = DefaultRouter()

admin.site.site_header = 'ERP'
admin.site.site_title = 'Trust Chain Administrator'

schema_view = get_schema_view(
   openapi.Info(
      title="Web 3.0 Application API",
      default_version='v1',
      description="A blockchain-based MVP of Brain Station 23 ltd.",
      terms_of_service="https://www.google.com/policies/terms/",
      contact=openapi.Contact(email="contact@snippets.local"),
      license=openapi.License(name="BSD License"),
   ),
   public=True,
   permission_classes=[permissions.AllowAny],
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(router.urls)),
    
    path('api/web2/', include([
        path('core/', include(core_urls, namespace='core')),
        path('manufacturer/', include(mfg_urls, namespace='manufacturer')),
        path('logistics/', include(logistics_urls, namespace='logistics')),
        path('export-import/', include(exim_urls, namespace='exim_service')),
        path('public-web3-manager/', include(public_web3_urls, namespace='public_blockchain_manager')),
    ])),
    
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    re_path(r'^swagger/$', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    re_path(r'^redoc/$', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),

]

if settings.DEBUG:
    import debug_toolbar
    urlpatterns += [
        path('__debug__/', include(debug_toolbar.urls)),
    ]
    
urlpatterns += static(settings.MEDIA_URL, document_root = settings.MEDIA_ROOT )
