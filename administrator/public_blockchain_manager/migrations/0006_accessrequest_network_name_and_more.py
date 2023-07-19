# Generated by Django 4.2.3 on 2023-07-15 15:23

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('public_blockchain_manager', '0005_remove_accessrequest_applicant_organizer_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='accessrequest',
            name='network_name',
            field=models.CharField(default='Goerli', max_length=50, verbose_name='Deployed Network Name'),
        ),
        migrations.AlterField(
            model_name='accessrequest',
            name='applicant_name',
            field=models.CharField(default='Mr. Sample', max_length=100, verbose_name='Name'),
        ),
        migrations.AlterField(
            model_name='accessrequest',
            name='applicant_organization',
            field=models.CharField(default='Org-X', max_length=100, verbose_name='Organization'),
        ),
        migrations.AlterField(
            model_name='accessrequest',
            name='digital_twin_url',
            field=models.URLField(default='www.example-nft.com/0x.../id', verbose_name='Digital Twin URL'),
        ),
        migrations.AlterField(
            model_name='accessrequest',
            name='endorsement_office',
            field=models.CharField(default='Mr. Demo', max_length=100, verbose_name='Officer Name'),
        ),
        migrations.AlterField(
            model_name='accessrequest',
            name='endorsement_organization',
            field=models.CharField(default='Org-Y', max_length=100, verbose_name='Organization'),
        ),
        migrations.AlterField(
            model_name='accessrequest',
            name='gateway_url',
            field=models.URLField(default='http://enterprise.network/org-y/hlf-pk', verbose_name='Gateway URL'),
        ),
    ]
