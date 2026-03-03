from typing import List, Optional
from fastapi import APIRouter, Depends, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.services.vehicle_service import VehicleService
from app.schemas.vehicle_schema import VehicleCreate, VehicleResponse
from app.core.dependencies import get_current_user
from app.models.user_model import User

router = APIRouter()

@router.get("/featured", response_model=List[VehicleResponse])
async def read_featured_vehicles(db: AsyncSession = Depends(get_db)):
    vehicle_service = VehicleService(db)
    return await vehicle_service.get_featured_vehicles()

@router.get("/", response_model=List[VehicleResponse])
async def read_vehicles(
    min_price: Optional[float] = Query(None),
    max_price: Optional[float] = Query(None),
    type: Optional[str] = Query(None),
    brand: Optional[str] = Query(None),
    location: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    vehicle_service = VehicleService(db)
    return await vehicle_service.get_vehicles(
        min_price=min_price,
        max_price=max_price,
        type=type,
        brand=brand,
        location=location
    )

@router.post("/", response_model=VehicleResponse, status_code=status.HTTP_201_CREATED)
async def create_vehicle(
    vehicle_in: VehicleCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    vehicle_service = VehicleService(db)
    return await vehicle_service.create_vehicle(vehicle_in, str(current_user.id))

@router.get("/{vehicle_id}", response_model=VehicleResponse)
async def read_vehicle(vehicle_id: str, db: AsyncSession = Depends(get_db)):
    vehicle_service = VehicleService(db)
    return await vehicle_service.get_vehicle(vehicle_id)
