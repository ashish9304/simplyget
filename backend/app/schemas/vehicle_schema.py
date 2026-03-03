from pydantic import BaseModel, UUID4
from typing import Optional
from datetime import datetime

class VehicleBase(BaseModel):
    type: str
    brand: str
    model: str
    price_per_day: float
    location: str
    image_url: Optional[str] = None
    image_urls: Optional[list[str]] = None
    rating: Optional[float] = 0.0
    lat: Optional[float] = None
    lng: Optional[float] = None
    description: Optional[str] = None
    is_available: bool = True

class VehicleCreate(VehicleBase):
    pass

class VehicleResponse(VehicleBase):
    id: UUID4
    owner_id: UUID4
    created_at: datetime

    class Config:
        from_attributes = True
