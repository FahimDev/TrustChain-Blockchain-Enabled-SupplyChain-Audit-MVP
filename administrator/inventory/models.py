import uuid
from django.db import models
from datetime import datetime
from django_countries.fields import CountryField
from django.core.validators import MinValueValidator, MaxValueValidator
from core.models import BaseTimeStampedModel


# Create your models here.
class InventoryDetail(BaseTimeStampedModel):
    title = models.CharField(max_length=100)
    tin_number = models.PositiveIntegerField()
    country = CountryField()

    class Meta:
        ordering = ('-id',)

    def __str__(self) -> str:
        return self.title[:70]
    
    
DEVICE_TYPE_CHOICES = [
    ('UWB-Tag','UWB-Tag'),
    ('UWB-Anchor','UWB-Anchor'),
    ('Temperature','Temperature'),
    ('CC-Camera','CC-Camera'),
]

class MonitoringDevice(BaseTimeStampedModel):
    name = models.CharField(max_length=50)
    mac_address = models.UUIDField(unique=True, default=uuid.uuid4, editable=False) # Just for MVP dummy Data
    device_category = models.CharField(
        max_length=20, choices=DEVICE_TYPE_CHOICES, default='UWB-Tag')
    
    def __str__(self) -> str:
        return f'{self.name} ⇔ {self.device_category}'
    
    
class WarehouseSection(BaseTimeStampedModel):
    uuid = models.UUIDField(unique=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=10)
    uwb_tracker = models.ForeignKey(MonitoringDevice, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'uwbtracker_monitoringdevice')
    temperature_sensor = models.ForeignKey(MonitoringDevice, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'temperaturesensor_monitoringdevice')
    cc_camera = models.ForeignKey(MonitoringDevice, on_delete= models.SET_NULL, null= True, blank= True, verbose_name='CC Camera', related_name= 'cccamera_monitoringdevice')
    max_sub_sections = models.PositiveIntegerField()
    area = models.CharField(max_length=50)
    address = models.TextField(max_length=500)

    class Meta:
        ordering = ('-id',)

    def __str__(self) -> str:
        return self.name[:70]
    

class MonitoringData(BaseTimeStampedModel):
    device = models.ForeignKey(MonitoringDevice, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'device_monitoringdevice')
    warehouse = models.ForeignKey(WarehouseSection, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'warehouse_monitoringdevice')
    value = models.PositiveIntegerField()
    report_remark = models.CharField(max_length=100, null= True, blank= True)
    unit = models.CharField(max_length=20)
    
    class Meta:
        ordering = ('-id',)
 
        
STORAGE_STATUS_CHOICES = [
    ('Stored','Stored'),
    ('Returned','Returned'),
    ('Clear','Clear'),
    ('Archived','Archived'),
]
class StorageManager(BaseTimeStampedModel):
    tracking_id = models.UUIDField(unique=True, default=uuid.uuid4, editable=False)
    product_mfg_id = models.PositiveIntegerField()
    product_digital_twin = models.URLField()
    warehouse = models.ForeignKey(InventoryDetail, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'warehouse_inventorydetail')
    section = models.ForeignKey(WarehouseSection, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'section_monitoringdevice')
    sub_section = models.PositiveIntegerField()
    booked_from = models.DateTimeField(verbose_name='From Date', default=datetime.now, blank=True)
    booked_to = models.DateTimeField(verbose_name='To Date', default=datetime.now, blank=True)
    booked_by = models.CharField(max_length=50)
    remark = models.CharField(max_length=100)
    status = models.CharField(
        max_length=20, choices=STORAGE_STATUS_CHOICES, default='Stored')

    class Meta:
        ordering = ('-id',)

