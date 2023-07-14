# Generated by Django 4.2.1 on 2023-05-14 08:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('logistics', '0008_alter_driverdetail_dob'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='driverdetail',
            name='dob',
        ),
        migrations.RemoveField(
            model_name='driverdetail',
            name='national_id',
        ),
        migrations.AddField(
            model_name='driverdetail',
            name='contact_number',
            field=models.CharField(blank=True, max_length=15, null=True, unique=True),
        ),
        migrations.AddField(
            model_name='driverdetail',
            name='is_contact_valid',
            field=models.BooleanField(default=False),
        ),
    ]
