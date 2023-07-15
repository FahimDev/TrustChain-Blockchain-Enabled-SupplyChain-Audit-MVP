from django.contrib import admin
from django.utils.html import format_html
from public_blockchain_manager.models import SmartContractDeployment, SignTypeData, EthSignature, AccessRequest


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
    

@admin.register(AccessRequest)
class AccessRequestAdmin(admin.ModelAdmin):
    def requested_by(self, obj):
        return f"{obj.applicant_name}({obj.applicant_organization})"
    def submitted_to(self, obj):
        return f"{obj.endorsement_office}({obj.endorsement_organization})"
    list_display = ('signature_request_uuid', 'requested_by', 'submitted_to', 'mfg_id', 'access_type', 'status', )
    fieldsets = (
        ('Applicant', {'fields': ('applicant_name','applicant_organization', 'applicant_wallet',)}),
        ('Endorser', {'fields': ('endorsement_office', 'endorsement_organization', 'endorsement_org_wallet',)}),
        ('Product Digital Identity', {'fields': ('digital_twin_url', 'smart_contract_address', 'network_name',)}),
        ('Requested Data Batch for Visibility', {'fields': ('mfg_id', 'mfg_license', 'gateway_url', 'private_ledger_id', 'access_type',)}),
        ('Signature Validity', {'fields': ('valid_from_date', 'valid_to_date',)}),
        (None, {'fields': ('status', )}),
    )