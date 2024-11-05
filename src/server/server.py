from fastapi import FastAPI
from routes.uploadRoutes import router as upload_router

app = FastAPI()

app.include_router(upload_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
