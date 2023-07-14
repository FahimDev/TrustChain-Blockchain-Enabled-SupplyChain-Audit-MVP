from django.db import models
from model_utils import FieldTracker
from model_utils.models import TimeStampedModel
from django.db import IntegrityError
from core.services.exceptions import NotDeletable


# Create your models here.
class BaseTimeStampedModel(TimeStampedModel):
    tracker = FieldTracker()

    class Meta:
        abstract = True

    def delete(self, **kwargs):
        try:
            super().delete(**kwargs)
        except IntegrityError:
            raise NotDeletable