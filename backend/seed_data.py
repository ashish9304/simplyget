import asyncio
import uuid
import random
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
from app.models.user_model import User
from app.models.vehicle_model import Vehicle
from app.core.security import get_password_hash

# Database setup
engine = create_async_engine(settings.DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def seed_data():
    async with AsyncSessionLocal() as session:
        # Check if user exists
        # For simplicity, create a dummy owner if not exists
        # In real app, we should check by email
        
        # Create a dummy owner
        owner = User(
            email="owner@example.com",
            hashed_password=get_password_hash("password123"),
            name="John Doe",
            role="owner",
            is_active=True
        )
        session.add(owner)
        await session.commit()
        await session.refresh(owner)
        print(f"Created owner: {owner.email}")

        vehicles_data = [
            {
                "type": "car",
                "brand": "Maruti",
                "model": "Swift",
                "price_per_day": 1500.0,
                "location": "Baner, Pune",
                "image_url": "https://imgd.aeplcdn.com/370x208/n/cw/ec/156405/swift-exterior-right-front-three-quarter-15.jpeg?isig=0&q=80",
                "rating": 4.5,
                "lat": 18.5590,
                "lng": 73.7868,
                "description": "Compact and fuel-efficient city car.",
                "owner_id": owner.id
            },
            {
                "type": "bike",
                "brand": "Royal Enfield",
                "model": "Classic 350",
                "price_per_day": 800.0,
                "location": "Koregaon Park, Pune",
                "image_url": "https://imgd.aeplcdn.com/310x174/n/cw/ec/124113/hunter-350-right-front-three-quarter.jpeg?isig=0&q=80",
                "rating": 4.8,
                "lat": 18.5362,
                "lng": 73.8940,
                "description": "Cruiser bike for long rides.",
                "owner_id": owner.id
            },
            {
                "type": "car",
                "brand": "Hyundai",
                "model": "Creta",
                "price_per_day": 2500.0,
                "location": "Viman Nagar, Pune",
                "image_url": "https://imgd.aeplcdn.com/370x208/n/cw/ec/141115/creta-exterior-right-front-three-quarter.jpeg?isig=0&q=80",
                "rating": 4.7,
                "lat": 18.5679,
                "lng": 73.9143,
                "description": "Spacious SUV for family trips.",
                "owner_id": owner.id
            },
             {
                "type": "bike",
                "brand": "Honda",
                "model": "Activa 6G",
                "price_per_day": 400.0,
                "location": "Aundh, Pune",
                "image_url": "https://imgd.aeplcdn.com/310x174/n/cw/ec/124013/activa-6g-right-front-three-quarter.jpeg?isig=0&q=80",
                "rating": 4.2,
                "lat": 18.5580,
                "lng": 73.8075,
                "description": "Easy to ride scooter for city commute.",
                "owner_id": owner.id
            },
            {
                "type": "car",
                "brand": "Mahindra",
                "model": "Thar",
                "price_per_day": 3500.0,
                "location": "Kothrud, Pune",
                "image_url": "https://imgd.aeplcdn.com/370x208/n/cw/ec/40087/thar-exterior-right-front-three-quarter-11.jpeg?isig=0&q=80",
                "rating": 4.9,
                "lat": 18.5074,
                "lng": 73.8077,
                "description": "Off-road beast for adventures.",
                "owner_id": owner.id
            }
        ]

        for v_data in vehicles_data:
            vehicle = Vehicle(**v_data)
            session.add(vehicle)
        
        await session.commit()
        print("Seeded vehicles data.")

if __name__ == "__main__":
    asyncio.run(seed_data())
