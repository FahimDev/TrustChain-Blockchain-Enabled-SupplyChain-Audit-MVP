from django.db import models
from core.models import BaseTimeStampedModel


# Create your models here.
class SmartContractDeployment(BaseTimeStampedModel):
    title = models.CharField(max_length=100, null=True, blank=True)
    description = models.CharField(max_length=500, null=True, blank=True)
    version = models.CharField(max_length=20)
    address = models.CharField(max_length=42)
    # application binary interface (ABI)
    artifact_abi = models.JSONField()
    deployer = models.CharField(max_length=42)
    network = models.URLField(null=True, blank=True)
    network_title = models.CharField(max_length=20,)
    is_verified = models.BooleanField(default=False)
    is_proxy = models.BooleanField(default=False)
    
    def __str__(self) -> str:
        return self.address
    
    
class SignTypeData(BaseTimeStampedModel):
    domain_name = models.CharField(max_length=100)
    domain_version = models.PositiveIntegerField()
    chain_id = models.PositiveIntegerField()
    smart_contract_address = models.ForeignKey(SmartContractDeployment, on_delete=models.CASCADE, related_name='domain_contract')
    sign_type_version = models.CharField(max_length=30, default='eth_signTypedData_v4')
   
    def __str__(self) -> str:
        return f'{self.domain_name} ⇔ {self.domain_version}'


class EthSignature(BaseTimeStampedModel):
    SIGN_STATUS_CHOICES = [
        (True, 'Accept'),
        (False, 'Reject'),
    ]
    sign_domain = models.ForeignKey(SignTypeData, on_delete=models.CASCADE, related_name='signature_domain')
    signer_address = models.CharField(max_length=42)
    signature = models.CharField(max_length=132, null=True, blank=True)
    message = models.JSONField()
    status = models.BooleanField(choices=SIGN_STATUS_CHOICES)
    
    def __str__(self) -> str:
        return f'{self.signer_address} ⇔ {self.signature}'
    