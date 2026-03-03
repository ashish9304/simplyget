from google.oauth2 import id_token
from google.auth.transport import requests
from app.core.config import settings
from app.db.session import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from app.repository.user_repo import UserRepo
from app.schemas.user_schema import UserCreate
from app.core.security import create_access_token, create_refresh_token
from typing import Dict, Any

class GoogleAuthService:
    @staticmethod
    async def verify_google_token(token: str, db: AsyncSession) -> Dict[str, Any]:
        try:
            # Try verifying as ID Token first
            try:
                flow_info = id_token.verify_oauth2_token(
                    token, 
                    requests.Request(), 
                    settings.GOOGLE_CLIENT_ID,
                    clock_skew_in_seconds=10
                )
                email = flow_info.get('email')
                name = flow_info.get('name', 'Google User')
            except ValueError:
                # If ID Token verification fails, try as Access Token
                import requests as req
                response = req.get(
                    f"https://www.googleapis.com/oauth2/v3/userinfo?access_token={token}"
                )
                if response.status_code != 200:
                    raise ValueError("Invalid Token")
                
                user_info = response.json()
                email = user_info.get('email')
                name = user_info.get('name', 'Google User')

            if not email:
                raise ValueError("Email not found in token")
                
            repo = UserRepo(db)
            user = await repo.get_by_email(email)
            
            if not user:
                # Create new user
                user_in = UserCreate(
                    email=email,
                    password="SOCIAL_LOGIN_PLACEHOLDER", # Placeholder to satisfy Pydantic
                    name=name,
                    role='renter' # Default role
                )
                user = await repo.create(user_in, hashed_password=None)
                
            # Generate tokens
            access_token = create_access_token(user.id)
            refresh_token = create_refresh_token(user.id)
            
            return {
                "access_token": access_token,
                "refresh_token": refresh_token,
                "token_type": "bearer",
                "user": {
                    "id": str(user.id),
                    "email": user.email,
                    "name": user.name,
                    "role": user.role
                }
            }
            
        except ValueError as e:
            raise ValueError(f"Invalid Google Token: {str(e)}")
        except Exception as e:
            raise Exception(f"Google Auth Failed: {str(e)}")
