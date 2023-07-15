from django.apps import AppConfig


class InventoryConfig(AppConfig): # Initialized at Settings
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'inventory'
