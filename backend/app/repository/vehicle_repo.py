from typing import List, Optional
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import or_, and_
from app.models.vehicle_model import Vehicle
from app.schemas.vehicle_schema import VehicleCreate

class VehicleRepo:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_all(
        self, 
        min_price: Optional[float] = None,
        max_price: Optional[float] = None,
        type: Optional[str] = None,
        brand: Optional[str] = None,
        location: Optional[str] = None
    ) -> List[Vehicle]:
        query = select(Vehicle)
        filters = []
        
        if min_price is not None:
            filters.append(Vehicle.price_per_day >= min_price)
        if max_price is not None:
            filters.append(Vehicle.price_per_day <= max_price)
        if type:
            filters.append(Vehicle.type == type)
        if brand:
            filters.append(Vehicle.brand.ilike(f"%{brand}%"))
        if location:
            filters.append(Vehicle.location.ilike(f"%{location}%"))
            
        if filters:
            query = query.filter(and_(*filters))
            
        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_by_id(self, vehicle_id: str) -> Optional[Vehicle]:
        result = await self.db.execute(select(Vehicle).filter(Vehicle.id == vehicle_id))
        return result.scalars().first()

    async def create(self, vehicle_in: VehicleCreate, owner_id: str) -> Vehicle:
        db_vehicle = Vehicle(
            **vehicle_in.model_dump(),
            owner_id=owner_id
        )
        self.db.add(db_vehicle)
        await self.db.commit()
        await self.db.refresh(db_vehicle)
        return db_vehicle

    async def get_featured(self) -> List[Vehicle]:
        from sqlalchemy import desc
        result = await self.db.execute(select(Vehicle).order_by(desc(Vehicle.rating)).limit(5))
        return result.scalars().all()
