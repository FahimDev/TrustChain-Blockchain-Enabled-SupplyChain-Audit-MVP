from django.contrib import admin
from django.utils.html import format_html
from public_blockchain_manager.models import SmartContractDeployment, SignTypeData, EthSignature


# Register your models here.
@admin.register(SmartContractDeployment)
class SmartContractDeploymentAdmin(admin.ModelAdmin):
    def network_url(self, obj):
        return format_html("<a href='{url}' target='_blank'>{title} 🖧</a>", url=obj.network, title = obj.network_title)
    
    def contract_address(self, obj):
        return format_html("<a href='{url}/address/{address}' target='_blank'>📜 {address}</a>", url=obj.network, address = obj.address)
    list_display = ('title', 'contract_address', 'version', 'network_url', 'is_verified', 'is_proxy')
    

@admin.register(SignTypeData)
class SignTypeDataAdmin(admin.ModelAdmin):
    list_display = ('domain_name', 'domain_version')
    
    
@admin.register(EthSignature)
class EthSignatureAdmin(admin.ModelAdmin):
    list_display = ('signer_address', 'status')

