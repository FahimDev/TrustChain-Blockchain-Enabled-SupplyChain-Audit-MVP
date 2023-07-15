from django.contrib import admin
from django.utils.html import format_html
from inventory.models import InventoryDetail, MonitoringDevice, WarehouseSection, MonitoringData, StorageManager


# Register your models here.
@admin.register(InventoryDetail)
class InventoryDetailAdmin(admin.ModelAdmin):
    list_display = ('title', 'tin_number', 'country')
    
    
@admin.register(MonitoringDevice)
class MonitoringDeviceAdmin(admin.ModelAdmin):
    list_display = ('name', 'mac_address', 'device_category',)


@admin.register(WarehouseSection)
class WarehouseSectionAdmin(admin.ModelAdmin):
    list_display = ('name', 'uwb_tracker', 'temperature_sensor', 'cc_camera', 'max_sub_sections', 'area', 'address')
   

@admin.register(MonitoringData)
class MonitoringDataAdmin(admin.ModelAdmin):
    list_display = ('device', 'warehouse', 'value', 'unit', 'report_remark', 'created',)
     
    
@admin.register(StorageManager)
class StorageManagerAdmin(admin.ModelAdmin):
    def digital_twin(self, obj):
        return format_html("<a href='{url}' target='_blank'>NFT 🏷</a>", url=obj.product_digital_twin)
    list_display = ('product_mfg_id', 'tracking_id', 'digital_twin', 'warehouse', 'section', 'sub_section', 'booked_from', 'booked_to', 'booked_by', 'status')
    