from typing import List
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.repository.booking_repo import BookingRepo
from app.repository.vehicle_repo import VehicleRepo
from app.schemas.booking_schema import BookingCreate, BookingResponse
from app.models.booking_model import Booking

class BookingService:
    def __init__(self, db: AsyncSession):
        self.booking_repo = BookingRepo(db)
        self.vehicle_repo = VehicleRepo(db)

    async def create_booking(self, booking_in: BookingCreate, user_id: str) -> Booking:
        vehicle = await self.vehicle_repo.get_by_id(booking_in.vehicle_id)
        if not vehicle:
            raise HTTPException(status_code=404, detail="Vehicle not found")
        
        # Calculate total price
        duration = (booking_in.end_date - booking_in.start_date).days
        if duration <= 0:
            raise HTTPException(status_code=400, detail="Invalid booking duration")
        
        total_price = duration * vehicle.price_per_day
        
        return await self.booking_repo.create(booking_in, user_id, total_price)

    async def get_user_bookings(self, user_id: str) -> List[Booking]:
        return await self.booking_repo.get_by_user(user_id)
