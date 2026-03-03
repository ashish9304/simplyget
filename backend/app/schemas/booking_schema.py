from pydantic import BaseModel, UUID4
from typing import Optional
from datetime import datetime

class BookingBase(BaseModel):
    vehicle_id: UUID4
    start_date: datetime
    end_date: datetime

class BookingCreate(BookingBase):
    pass

class BookingResponse(BookingBase):
    id: UUID4
    user_id: UUID4
    total_price: float
    status: str
    created_at: datetime

    class Config:
        from_attributes = True
