# Generated by Django 4.2.1 on 2023-05-13 19:06

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('logistics', '0007_rename_booking_id_deliveryinvoice_booking_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='driverdetail',
            name='dob',
            field=models.DateField(verbose_name='Date of birth'),
        ),
    ]