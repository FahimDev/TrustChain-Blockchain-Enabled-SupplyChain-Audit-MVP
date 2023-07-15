from django.contrib import admin
from exim_service.models import EXIMDetail, EmployeeDetail


# Register your models here.
@admin.register(EXIMDetail)
class EXIMDetailAdmin(admin.ModelAdmin):
    list_display = ('title', 'country', 'operation_type')
    
    
@admin.register(EmployeeDetail)
class EmployeeDetailAdmin(admin.ModelAdmin):
    list_display = ('name', 'employer', 'designation', 'contact_number')
