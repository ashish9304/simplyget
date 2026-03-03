from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.security import OAuth2PasswordRequestForm
from app.db.session import get_db
from app.services.auth_service import AuthService
from app.schemas.user_schema import UserCreate, UserLogin, Token, UserResponse
from app.core.dependencies import get_current_user
from app.models.user_model import User

router = APIRouter()

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(user_in: UserCreate, db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    return await auth_service.register_user(user_in)

@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    user_login = UserLogin(email=form_data.username, password=form_data.password)
    return await auth_service.login_user(user_login)

@router.get("/me", response_model=UserResponse)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/google")
async def google_login(token_data: dict, db: AsyncSession = Depends(get_db)):
    """
    Google Login Endpoint.
    Expects {'token': 'google_id_token'}
    """
    token = token_data.get('token')
    if not token:
        raise HTTPException(status_code=400, detail="Token required")
    
    from app.services.google_auth_service import GoogleAuthService
    return await GoogleAuthService.verify_google_token(token, db)
