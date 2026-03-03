from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1 import auth_routes, vehicle_routes, booking_routes, upload_routes, location_routes
import logging
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(title=settings.PROJECT_NAME)

# CORS Middleware
print(f"DEBUG: Configured CORS Origins: {settings.BACKEND_CORS_ORIGINS}")
try:
    origins = [str(origin) for origin in settings.BACKEND_CORS_ORIGINS]
except Exception as e:
    logger.warning(f"Failed to parse CORS origins: {e}. Defaulting to ['*']")
    origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    try:
        response = await call_next(request)
        process_time = time.time() - start_time
        logger.info(f"Request: {request.method} {request.url.path} - Status: {response.status_code} - Time: {process_time:.4f}s")
        return response
    except Exception as e:
        process_time = time.time() - start_time
        logger.error(f"Request failed: {request.method} {request.url.path} - Error: {e}", exc_info=True)
        # Re-raise to let FastAPI handle the 500 response, but we've logged it now
        raise e

@app.get("/")
async def root():
    logger.info("Root endpoint accessed")
    return {"message": "Welcome to Good To Go API"}

app.include_router(auth_routes.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(vehicle_routes.router, prefix="/api/v1/vehicles", tags=["vehicles"])
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.include_router(upload_routes.router, prefix="/api/v1/upload", tags=["upload"])
app.include_router(location_routes.router, prefix="/api/v1/location", tags=["location"])
