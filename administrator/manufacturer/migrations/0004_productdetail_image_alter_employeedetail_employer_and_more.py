# Generated by Django 4.2.3 on 2023-07-15 04:22

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('manufacturer', '0003_remove_productdetail_manufacturing_team_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='productdetail',
            name='image',
            field=models.ImageField(blank=True, null=True, upload_to='product'),
        ),
        migrations.AlterField(
            model_name='employeedetail',
            name='employer',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='employee_manufacturerdetail', to='manufacturer.manufacturerdetail'),
        ),
        migrations.AlterField(
            model_name='productdetail',
            name='manufacturer',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='product_manufacturer', to='manufacturer.manufacturerdetail'),
        ),
        migrations.AlterField(
            model_name='productdetail',
            name='manufacturing_coordinator',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='product_employeedetail', to='manufacturer.employeedetail'),
        ),
    ]