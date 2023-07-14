# Generated by Django 4.2.3 on 2023-07-14 14:40

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('manufacturer', '0002_alter_productdetail_manufacturing_team'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='productdetail',
            name='manufacturing_team',
        ),
        migrations.AddField(
            model_name='productdetail',
            name='manufacturing_coordinator',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='product_manufacturer', to='manufacturer.employeedetail'),
        ),
        migrations.AlterField(
            model_name='productdetail',
            name='manufacturer',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='product_employeedetail', to='manufacturer.manufacturerdetail'),
        ),
    ]
