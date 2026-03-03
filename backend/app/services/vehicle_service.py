from typing import List, Optional
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.repository.vehicle_repo import VehicleRepo
from app.schemas.vehicle_schema import VehicleCreate
from app.models.vehicle_model import Vehicle

class VehicleService:
    def __init__(self, db: AsyncSession):
        self.vehicle_repo = VehicleRepo(db)

    async def get_vehicles(
        self,
        min_price: Optional[float] = None,
        max_price: Optional[float] = None,
        type: Optional[str] = None,
        brand: Optional[str] = None,
        location: Optional[str] = None
    ) -> List[Vehicle]:
        return await self.vehicle_repo.get_all(
            min_price=min_price,
            max_price=max_price,
            type=type,
            brand=brand,
            location=location
        )

    async def get_vehicle(self, vehicle_id: str) -> Vehicle:
        vehicle = await self.vehicle_repo.get_by_id(vehicle_id)
        if not vehicle:
            raise HTTPException(status_code=404, detail="Vehicle not found")
        return vehicle

    async def create_vehicle(self, vehicle: VehicleCreate, owner_id: str) -> Vehicle:
        return await self.vehicle_repo.create(vehicle, owner_id)

    async def get_featured_vehicles(self) -> List[Vehicle]:
        return await self.vehicle_repo.get_featured()
