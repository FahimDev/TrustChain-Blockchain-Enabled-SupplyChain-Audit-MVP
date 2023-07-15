from django.db import models
from datetime import datetime
from django_countries.fields import CountryField
from django.core.validators import MinValueValidator, MaxValueValidator
from core.models import BaseTimeStampedModel


# Create your models here.
class EXIMDetail(BaseTimeStampedModel):
    OPERATION_TYPE_CHOICES = [
        ('export','Exporter'),
        ('import','Importer'),
        ('export_import','Exporter/Importer'),
    ]
    title = models.CharField(max_length=100)
    tin_number = models.PositiveIntegerField(unique= True)
    address = models.TextField(max_length=500)
    operation_type = models.CharField(max_length=20, choices= OPERATION_TYPE_CHOICES, default= 'export')
    country = CountryField()

    class Meta:
        ordering = ('-id',)

    def __str__(self) -> str:
        return self.title[:70]
    

class EmployeeDetail(BaseTimeStampedModel):
    name = models.CharField(max_length=100)
    contact_number = models.CharField(max_length=15, unique= True, null= True, blank= True)
    contact_kyc = models.UUIDField(unique=True, null= True, blank= True, editable=True)
    designation = models.CharField(max_length= 50)
    employer = models.ForeignKey(EXIMDetail, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'employee_employer')
    
    def __str__(self) -> str:
        return f'{self.name} ⇔ {self.contact_number} | {self.employer}({self.designation})'
