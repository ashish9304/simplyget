from pydantic_settings import BaseSettings
from typing import Optional, List, Union

class Settings(BaseSettings):
    PROJECT_NAME: str = "Good To Go"
    API_V1_STR: str = "/api/v1"
    
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int
    REFRESH_TOKEN_EXPIRE_DAYS: int
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_MAPS_API_KEY: str = ""
    BACKEND_CORS_ORIGINS: list[str] = []

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
