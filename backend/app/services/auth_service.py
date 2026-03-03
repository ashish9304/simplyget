from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.repository.user_repo import UserRepo
from app.schemas.user_schema import UserCreate, UserLogin, Token
from app.core.security import verify_password, get_password_hash, create_access_token, create_refresh_token

class AuthService:
    def __init__(self, db: AsyncSession):
        self.user_repo = UserRepo(db)

    async def register_user(self, user_in: UserCreate) -> Token:
        existing_user = await self.user_repo.get_by_email(user_in.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )
        
        hashed_password = get_password_hash(user_in.password)
        new_user = await self.user_repo.create(user_in, hashed_password)
        
        access_token = create_access_token(subject=new_user.id)
        refresh_token = create_refresh_token(subject=new_user.id)
        
        return Token(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer"
        )

    async def login_user(self, user_in: UserLogin) -> Token:
        user = await self.user_repo.get_by_email(user_in.email)
        if not user or not verify_password(user_in.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        access_token = create_access_token(subject=user.id)
        refresh_token = create_refresh_token(subject=user.id)
        
        return Token(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer"
        )
