from django.contrib import admin
from logistics.models import LogisticDetail, TransportDetail, DriverDetail, DeliveryBooking, DeliveryInvoice


# Register your models here.
@admin.register(LogisticDetail)
class LogisticDetailAdmin(admin.ModelAdmin):
    list_display = ('title', 'country')
    
    
@admin.register(TransportDetail)
class TransportDetailAdmin(admin.ModelAdmin):
    list_display = ('model', 'authority_zone', 'registration_number', 'chassis_type', 'capacity', 'capacity_unit', 'owner_list')
    def owner_list(self, obj):
        return ", ".join([owner.title+"-"+owner.country.name for owner in obj.owners.all()])
    
    
@admin.register(DriverDetail)
class DriverDetailAdmin(admin.ModelAdmin):
    list_display = ('name', 'license_no', 'validity_date', 'contact_number')
    
    
@admin.register(DeliveryBooking)
class DeliveryBookingAdmin(admin.ModelAdmin):
    list_display = ('service_provider', 'sender_contact', 'receiver_contact', 'status')
        

@admin.register(DeliveryInvoice)
class DeliveryInvoiceAdmin(admin.ModelAdmin):
    list_display = ('invoice_id', 'total_cost', 'status')