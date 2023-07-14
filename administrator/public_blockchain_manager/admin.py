from django.contrib import admin
from public_blockchain_manager.models import SmartContractDeployment, SignTypeData, EthSignature


# Register your models here.
@admin.register(SmartContractDeployment)
class SmartContractDeploymentAdmin(admin.ModelAdmin):
    list_display = ('title', 'address', 'network')
    

@admin.register(SignTypeData)
class SignTypeDataAdmin(admin.ModelAdmin):
    list_display = ('domain_name', 'domain_version')
    
    
@admin.register(EthSignature)
class EthSignatureAdmin(admin.ModelAdmin):
    list_display = ('signer_address', 'status')

