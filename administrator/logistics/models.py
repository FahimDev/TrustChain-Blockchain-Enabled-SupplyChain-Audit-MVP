import uuid
from django.db import models
from datetime import datetime
from django_countries.fields import CountryField
from django.core.validators import MinValueValidator, MaxValueValidator
from core.models import BaseTimeStampedModel


# Create your models here.
VEHICLE_TYPE_CHOICES = [
    ('sedan','Sedan'),
    ('minivan','Minivan-MPV'),
    ('hatchback','Hatchback-MPV'),
    ('pickup','Pickup'),
    ('freezer_van','Freezer Van'),
    ('covered_van','Covered Van'),
    ('truck','Truck'),
]

class LogisticDetail(BaseTimeStampedModel):
    title = models.CharField(max_length=100)
    tin_number = models.PositiveIntegerField()
    address = models.TextField(max_length=500)
    country = CountryField()

    class Meta:
        ordering = ('-id',)

    def __str__(self) -> str:
        return self.title[:70]
    

class TransportDetail(BaseTimeStampedModel):
    CAPACITY_UNIT_CHOICES = [
        ('kg','KG'),
        ('ton','TON'),
    ]
    brand = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    chassis_type = models.CharField(
        max_length=20, choices=VEHICLE_TYPE_CHOICES, default='minivan')
    chassis_number = models.CharField(max_length=100, null= True, blank= True)
    engine_number = models.CharField(max_length=100, null= True, blank= True)
    authority_zone = models.CharField(max_length=200, null= True, blank= True)
    registration_number = models.CharField(max_length=200, null= True, blank= True)
    capacity = models.PositiveIntegerField()
    capacity_unit = models.CharField(max_length=10, choices= CAPACITY_UNIT_CHOICES, default= 'ton')
    owners = models.ManyToManyField(LogisticDetail, null= True, blank= True, related_name= 'transport_owners')
    
    def __str__(self) -> str:
        return f'{self.authority_zone}-{self.registration_number} ⇔ {self.capacity} {self.capacity_unit} | {self.chassis_type}'

    
class DriverDetail(BaseTimeStampedModel):
    BLOOD_GROUP_CHOICES = [
        ('a_pos','A+'),
        ('a_neg','A-'),
        ('b_pos','B+'),
        ('b_neg','B-'),
        ('ab_pos','AB+'),
        ('ab_neg','AB-'),
        ('o_pos','O+'),
        ('o_neg','O-'),
    ]
    name = models.CharField(max_length=100)
    contact_number = models.CharField(max_length=15, unique= True, null= True, blank= True)
    contact_kyc = models.UUIDField(unique=True, null= True, blank= True, editable=True)
    license_no = models.CharField(max_length=200, unique= True)
    blood_group = models.CharField(
        max_length=10, choices=BLOOD_GROUP_CHOICES)
    issuer_authority = models.CharField(max_length=200)
    issue_year = models.PositiveIntegerField(validators=[
        MinValueValidator(1900),
        MaxValueValidator(datetime.now().year)],
        help_text="Use the following format: <YYYY>")
    validity_date = models.DateField()
    employer = models.ForeignKey(LogisticDetail, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'driver_employer')
    
    def __str__(self) -> str:
        return f'{self.name} ⇔ {self.license_no} | {self.validity_date}'
    
    
class DeliveryBooking(BaseTimeStampedModel):
    CAPACITY_UNIT_CHOICES = [
        ('kg','KG'),
        ('ton','TON'),
    ]
    STATUS_CHOICES = [
        ('pending','Pending'),
        ('processing','Processing'),
        ('pick_up','Pick Up'),
        ('on_delivery','On Delivery'),
        ('delivered','Delivered'),
        ('returned','Returned'),
    ]
    service_provider = models.ForeignKey(LogisticDetail, on_delete= models.SET_NULL, null= True, blank= True, related_name= 'booking_logistics')
    product_batch_id = models.UUIDField(unique=False, editable=True, null= True, blank= True)
    product_quantity = models.PositiveIntegerField()
    product_weight = models.PositiveIntegerField()
    weight_unit = models.CharField(max_length=10, choices= CAPACITY_UNIT_CHOICES, default= 'kg')
    chassis_type = models.CharField(
    max_length=20, choices=VEHICLE_TYPE_CHOICES, default='minivan')
    sender_contact = models.CharField(max_length=15)
    from_address = models.TextField(max_length=500)
    from_country = CountryField()
    receiver_contact = models.CharField(max_length=15)
    to_address = models.TextField(max_length=500)
    to_country = CountryField()
    remark = models.CharField(max_length=100, default= 'Client nick name')
    status = models.CharField(max_length=20, choices= STATUS_CHOICES, default= 'pending')
  
    def __str__(self) -> str:
        return f'{self.remark}: {self.sender_contact} ⇔ {self.receiver_contact} | {self.service_provider}'
        
        
class DeliveryInvoice(BaseTimeStampedModel):
    CURRENCY_CHOICES = [
        ('eth','ETH'),
        ('matic','Matic'),
        ('fiat','FIAT'),
    ]
    BILL_STATUS_CHOICES = [
        ('pending','Pending'),
        ('paid','Paid'),
    ]
    booking = models.ForeignKey(DeliveryBooking, on_delete= models.CASCADE, null= True, blank= True, related_name= 'invoice_booking')
    assigned_vehicle = models.ForeignKey(TransportDetail, on_delete= models.CASCADE, null= True, blank= True, related_name= 'invoice_transport')
    assigned_driver = models.ForeignKey(DriverDetail, on_delete= models.CASCADE, null= True, blank= True, related_name= 'invoice_driver')
    total_cost = models.PositiveIntegerField()
    trx_id = models.CharField(max_length=200, null= True, blank= True)
    currency = models.CharField(max_length=20, choices= CURRENCY_CHOICES, default= 'fiat')
    status = models.CharField(max_length=20, choices= BILL_STATUS_CHOICES, default= 'pending')
    invoice_id = models.UUIDField(unique=True, default=uuid.uuid4, editable=False)

    def __str__(self) -> str:
        return f'{self.invoice_id} ⇔ {self.total_cost} | {self.status}'
        
        