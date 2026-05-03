# FastAPI Authentication & User Management System

A complete, production-ready authentication and user management API built with FastAPI and PostgreSQL. Perfect for bootstrapping any web application that needs user accounts.

## ✨ Features

- **🔐 JWT Authentication** - Secure access and refresh tokens
- **👤 User Management** - Complete CRUD operations for users
- **🎭 Role-Based Access** - Admin, Moderator, and User roles
- **📧 Email/Username Login** - Flexible authentication options
- **🔄 Token Refresh** - Seamless token rotation without re-login
- **✅ Email Verification Ready** - Structure in place for email verification
- **🔒 Password Hashing** - bcrypt for secure password storage
- **🛡️ Security First** - Protected routes, token revocation, and more
- **📝 Swagger Docs** - Automatic API documentation at `/docs`

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- PostgreSQL (running locally or remotely)
- pip package manager

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/fastapi-auth-system.git
cd fastapi-auth-system
```

2. **Set up virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure database**

Create a PostgreSQL database:
```bash
sudo -u postgres createdb authdb
# or using psql
psql -U postgres
CREATE DATABASE authdb;
```

5. **Set up environment variables**

Create a `.env` file in the root directory:
```env
DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/authdb
SECRET_KEY=change-this-to-a-very-long-random-string-in-production
ENVIRONMENT=development
DEBUG=True
```

> ⚠️ **IMPORTANT**: Generate a real secret key for production:
> ```python
> python -c "import secrets; print(secrets.token_urlsafe(32))"
> ```

6. **Run the application**
```bash
uvicorn main:app --reload
```

Your API is now running at `http://localhost:8000`

## 📚 API Documentation

Once running, visit:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

### Main Endpoints

#### Authentication Routes (`/auth`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Create a new user account |
| POST | `/auth/login` | Login with email/username + password |
| POST | `/auth/refresh` | Get new access token using refresh token |
| POST | `/auth/logout` | Logout and invalidate refresh tokens |
| POST | `/auth/change-password` | Change user password |
| GET | `/auth/me` | Get current user profile |

#### User Management Routes (`/users`) - Admin only

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/` | List all users |
| GET | `/users/{user_id}` | Get specific user details |
| PUT | `/users/{user_id}` | Update user information |
| DELETE | `/users/{user_id}` | Delete user account |
| PATCH | `/users/{user_id}/activate` | Activate a user |
| PATCH | `/users/{user_id}/deactivate` | Deactivate a user |
| PATCH | `/users/{user_id}/role` | Change user role |

### Quick Test with curl

**Register a new user:**
```bash
curl -X POST "http://localhost:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "john_doe",
    "full_name": "John Doe",
    "password": "securepassword123"
  }'
```

**Login:**
```bash
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username_or_email": "john_doe",
    "password": "securepassword123"
  }'
```

**Access protected endpoint:**
```bash
curl -X GET "http://localhost:8000/auth/me" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 🏗️ Project Structure

```
.
├── main.py              # FastAPI app entry point
├── config.py            # Configuration settings
├── database.py          # Database connection setup
├── models.py            # SQLAlchemy database models
├── schemas.py           # Pydantic schemas for validation
├── auth.py              # Authentication utilities
├── dependencies.py      # FastAPI dependencies (auth, permissions)
├── router/
│   ├── auth.py          # Authentication endpoints
│   └── users.py         # User management endpoints
├── requirements.txt     # Python dependencies
└── .env                 # Environment variables (create this)
```

## 🔑 Authentication Flow

1. **Registration** → User creates account with email, username, password
2. **Login** → Server validates credentials, returns access & refresh tokens
3. **API Calls** → Client includes access token in `Authorization: Bearer <token>` header
4. **Token Expiry** → Access tokens expire (default: 30 min)
5. **Refresh** → Use refresh token to get new access token
6. **Logout** → Server revokes refresh tokens

## 👥 Role System

The system comes with three built-in roles:

- **Admin** (`admin`) - Full system access, can manage all users
- **Moderator** (`moderator`) - Extended privileges (customize as needed)
- **User** (`user`) - Standard access (default role)

Permission checks are built into the dependencies, making it easy to protect routes:

```python
@router.get("/admin-only")
async def admin_endpoint(current_user = Depends(require_admin)):
    return {"message": "Only admins can see this"}
```

## 🛠️ Development

### Adding New Features

1. **Create a new model** in `models.py`
2. **Create schemas** in `schemas.py` for request/response validation
3. **Add routes** in `router/` directory
4. **Test endpoints** using Swagger or curl

### Database Migrations (Alembic)

While the app creates tables automatically on startup, for production use Alembic:

```bash
pip install alembic
alembic init alembic
# Configure alembic.ini and env.py
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

### Running Tests

```bash
pytest tests/  # When you add tests
```

## 🔒 Security Features

- Passwords hashed with bcrypt (12 rounds)
- JWT tokens with expiration
- Refresh token rotation (new token on each refresh)
- Token revocation on logout
- SQL injection protection (SQLAlchemy ORM)
- CORS middleware (configure for production)

## 📦 Deployment

### Using Docker

Create a `Dockerfile`:

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t fastapi-auth .
docker run -p 8000:8000 --env-file .env fastapi-auth
```

### Production Considerations

1. **Change default settings** in `.env`:
   - Use strong `SECRET_KEY`
   - Set `DEBUG=False`
   - Use production database URL

2. **Use HTTPS** in production (via nginx or cloud provider)

3. **Add rate limiting** to prevent brute force attacks

4. **Implement email verification** (structure is ready in the `User` model with `is_verified` field)

5. **Add logging and monitoring**

6. **Use PostgreSQL connection pooling**

5. Open a Pull Request

## 🙏 Acknowledgments

- [FastAPI](https://fastapi.tiangolo.com/) - The awesome web framework
- [SQLAlchemy](https://www.sqlalchemy.org/) - SQL toolkit and ORM
- [python-jose](https://github.com/mpdavis/python-jose) - JWT handling
- [passlib](https://passlib.readthedocs.io/) - Password hashing

## 💬 Support

- Open an issue for bugs or feature requests
- Star the repo if you find it useful 😊
- Share with others who might benefit

---

**Made with ❤️ using FastAPI**
