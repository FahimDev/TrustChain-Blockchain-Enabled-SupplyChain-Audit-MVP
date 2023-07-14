from django.contrib import admin
from pprint import pprint
from django.utils.html import format_html
from manufacturer.models import ManufacturerDetail, EmployeeDetail, ProductDetail, ProductTrait

# Register your models here.
@admin.register(ManufacturerDetail)
class ManufacturerDetailAdmin(admin.ModelAdmin):
    def brand_logo(self, obj):
        return format_html('<img src="{}" height="50" />'.format(obj.logo.url))
    list_display = ('brand_logo', 'title',)
    

@admin.register(EmployeeDetail)
class EmployeeDetailAdmin(admin.ModelAdmin):
    list_display = [field.name for field in EmployeeDetail._meta.get_fields()]
    

@admin.register(ProductDetail)
class ProductDetailAdmin(admin.ModelAdmin):
    list_display = ('title',)
    

@admin.register(ProductTrait)
class ProductTraitAdmin(admin.ModelAdmin):
    list_display = ('chassis_type',)