# Generated by Django 4.2.3 on 2023-07-15 07:17

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('manufacturer', '0005_alter_productdetail_mfg_id'),
    ]

    operations = [
        migrations.AlterField(
            model_name='productdetail',
            name='image',
            field=models.ImageField(blank=True, default='product/image_missing.png', null=True, upload_to='product'),
        ),
    ]