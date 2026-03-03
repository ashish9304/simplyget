from typing import List, Optional
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.booking_model import Booking
from app.schemas.booking_schema import BookingCreate

class BookingRepo:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_user(self, user_id: str) -> List[Booking]:
        result = await self.db.execute(select(Booking).filter(Booking.user_id == user_id))
        return result.scalars().all()

    async def create(self, booking_in: BookingCreate, user_id: str, total_price: float) -> Booking:
        db_booking = Booking(
            user_id=user_id,
            vehicle_id=booking_in.vehicle_id,
            start_date=booking_in.start_date,
            end_date=booking_in.end_date,
            total_price=total_price,
            status="confirmed"
        )
        self.db.add(db_booking)
        await self.db.commit()
        await self.db.refresh(db_booking)
        return db_booking
