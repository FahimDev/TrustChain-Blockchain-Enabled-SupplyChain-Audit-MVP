import uuid
from django.db import models
from datetime import datetime
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
    

SIGN_REQUEST_STATUS_CHOICES = [
    ('pending','Pending'),
    ('accepted','Accepted'),
    ('rejected','Rejected'),
]
ACCESS_TYPE_CHOICES = [
    ('READ ONLY','READ ONLY'),
    ('WRITE','WRITE'),
]

NETWORK_TYPE_CHOICES = [
    ('Polygon','Polygon'),
    ('Ethereum','Ethereum'),
    ('Polygon Mumbai','Polygon Mumbai'),
    ('Goerli','Goerli'),
]
class AccessRequest(BaseTimeStampedModel):
    signature_request_uuid = models.UUIDField(unique=True, default=uuid.uuid4, editable=False)
    applicant_name = models.CharField(verbose_name='Name', max_length=100, default="Mr. Sample")
    applicant_organization = models.CharField(verbose_name='Organization', max_length=100, default="Org-X")
    applicant_wallet = models.CharField(verbose_name='Wallet Address', max_length=42, default='0x...')
    endorsement_office = models.CharField(verbose_name='Officer Name', max_length=100,default='Mr. Demo')
    endorsement_organization = models.CharField(verbose_name='Organization', max_length=100, default='Org-Y')
    endorsement_org_wallet = models.CharField(verbose_name='Wallet Address', max_length=42, default='0x...')
    valid_from_date = models.DateTimeField(verbose_name='Start Date', default=datetime.now, blank=True)
    valid_to_date = models.DateTimeField(verbose_name='End Date', default=datetime.now, blank=True)
    digital_twin_url = models.URLField(verbose_name='Digital Twin URL', default='www.example-nft.com/0x.../id')
    smart_contract_address = models.CharField(max_length=42, default='0x......')
    network_name = models.CharField(verbose_name = 'Deployed Network Name', max_length=50, choices= NETWORK_TYPE_CHOICES, default='Goerli')
    mfg_id = models.CharField(verbose_name='MFG. ID', max_length=100, default="#Sample")
    mfg_license = models.CharField(verbose_name='MFG. License', max_length=200, default="#Lis123")
    gateway_url = models.URLField(verbose_name='Gateway URL', default="http://enterprise.network/org-y/hlf-pk")
    private_ledger_id = models.CharField(max_length=200, default="hlf-pk")
    access_type = models.CharField(
        max_length=20, choices=ACCESS_TYPE_CHOICES, default='READ ONLY')
    status = models.CharField(
        max_length=20, choices=SIGN_REQUEST_STATUS_CHOICES, default='pending')
    
    def __str__(self) -> str:
        return f'{self.applicant_organization} ⇔ {self.signature_request_uuid}'