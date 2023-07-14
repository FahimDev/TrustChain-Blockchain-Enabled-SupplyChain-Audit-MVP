import uuid
from django.db import models
from datetime import datetime
from django_countries.fields import CountryField
from django.core.validators import MinValueValidator, MaxValueValidator
from core.models import BaseTimeStampedModel

# Create your models here.
class ManufacturerDetail(BaseTimeStampedModel):
    title = models.CharField(max_length=100)
    logo = models.ImageField(upload_to="logo") 
    tin_number = models.PositiveIntegerField(unique= True)
    description = models.TextField(max_length=500)
    country = CountryField()

    class Meta:
        ordering = ('-id',)

    def __str__(self) -> str:
        return self.title[:70]
    

class EmployeeDetail(BaseTimeStampedModel):
    name = models.CharField(max_length=100)
    contact_number = models.CharField(max_length=15, unique= True, null= True, blank= True)
    certification_title = models.CharField(max_length=50)
    certification_id = models.UUIDField(unique=True, null= True, blank= True, editable=True)
    designation = models.CharField(max_length= 50)
    employer = models.ForeignKey(ManufacturerDetail, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'employee_employer')

    class Meta:
        ordering = ('-id',)
        
    def __str__(self) -> str:
        return f'{self.name} ⇔ {self.contact_number} | {self.employer}({self.designation})'
    

# Create your models here.
VEHICLE_TYPE_CHOICES = [
    ('Sedan','Sedan'),
    ('Minivan','Minivan-MPV'),
    ('Hatchback','Hatchback-MPV'),
    ('Pickup','Pickup'),
    ('FreezerVan','Freezer Van'),
    ('CoveredVan','Covered Van'),
    ('Truck','Truck'),
] 

VEHICLE_FUEL_CHOICES = [
    ('Hybrid','Hybrid'),
    ('LeadAcid','Lead Acid'),
    ('LithiumIronPhosphate','Lithium Iron Phosphate'),
    ('Octane/CNG','Octane/CNG'),
    ('Octane','Octane'),
] 

VEHICLE_COLOR_CHOICES = [
    ('Black','Black'),
    ('Silver','Silver'),
    ('White','White'),
    ('Red','Red'),
] 

class ProductTrait(BaseTimeStampedModel):
    chassis_type = models.CharField(
            max_length=20, choices=VEHICLE_TYPE_CHOICES, default='Sedan')
    fuel_type = models.CharField(
            max_length=20, choices=VEHICLE_FUEL_CHOICES, default='Hybrid')
    seat_number = models.PositiveIntegerField()
    color = models.CharField(
            max_length=20, choices=VEHICLE_COLOR_CHOICES, default='White')

    class Meta:
        ordering = ('-id',)
    
    def __str__(self) -> str:
        return f'{self.chassis_type} ⇔ {self.color} | {self.fuel_type}'    


class ProductDetail(BaseTimeStampedModel):
    title = models.CharField(max_length=100)
    description = models.TextField(max_length=500)
    owner_address = models.CharField(max_length=64)
    mfg_id = models.UUIDField(unique=True, default=uuid.uuid4, editable=False)
    mfg_license = models.CharField(max_length=100)
    trait = models.ForeignKey(ProductTrait, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'trait_producttrait')
    manufacturer = models.ForeignKey(ManufacturerDetail, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'product_manufacturer')
    manufacturing_team = models.ManyToManyField(EmployeeDetail)
    digital_twin = models.BooleanField(default=False)
    
    class Meta:
        ordering = ('-id',)
    
    def __str__(self) -> str:
        return f'{self.title} ⇔ {self.mfg_id} | {self.digital_twin}'

    