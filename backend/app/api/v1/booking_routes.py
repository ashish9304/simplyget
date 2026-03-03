from typing import List
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.services.booking_service import BookingService
from app.schemas.booking_schema import BookingCreate, BookingResponse
from app.core.dependencies import get_current_user
from app.models.user_model import User

router = APIRouter()

@router.post("/", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
async def create_booking(
    booking_in: BookingCreate, 
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    booking_service = BookingService(db)
    return await booking_service.create_booking(booking_in, str(current_user.id))

@router.get("/me", response_model=List[BookingResponse])
async def read_user_bookings(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    booking_service = BookingService(db)
    return await booking_service.get_user_bookings(str(current_user.id))
