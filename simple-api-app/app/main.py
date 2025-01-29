from fastapi import FastAPI, HTTPException, Body, Depends, Security, status, Request
from fastapi.security.api_key import APIKeyHeader
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from pymongo import MongoClient
from bson import ObjectId
from bson.errors import InvalidId
from pydantic import BaseModel
from typing import Optional, List
import os
import secrets

app = FastAPI()

# Rate limiting setup
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# API Key setup
API_KEY = os.getenv("API_KEY", "default-api-key")  # In production, always use env var
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=True)

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid API Key"
        )
    return api_key

# MongoDB connection
MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongodb:27017")
client = MongoClient(MONGO_URI)
db = client.products_db

class Product(BaseModel):
    name: str
    description: str
    price: float

class ProductResponse(Product):
    id: str

def check_db_objectid(product_id):
    try:
        object_id = ObjectId(product_id)
    except InvalidId:
        raise HTTPException(status_code=400, detail="Invalid product ID")

@app.post("/webhook")
@limiter.limit("5/minute")  # Limit to 5 requests per minute
async def webhook_handler(request: Request, payload: dict = Body(...)):
    db.webhook_events.insert_one(payload)
    return {"status": "success", "message": "Webhook received"}

# CRUD Operations with API Key authentication and rate limiting
@app.post("/products", response_model=ProductResponse)
@limiter.limit("10/minute")
async def create_product(
    request: Request,
    product: Product,
    api_key: str = Depends(verify_api_key)
):
    product_dict = product.dict()
    result = db.products.insert_one(product_dict)
    product_dict["id"] = str(result.inserted_id)
    return product_dict

@app.get("/products", response_model=List[ProductResponse])
@limiter.limit("30/minute")
async def read_products(
    request: Request,
    api_key: str = Depends(verify_api_key)
):
    products = []
    for product in db.products.find():
        product["id"] = str(product.pop("_id"))
        products.append(product)
    return products

@app.get("/products/{product_id}", response_model=ProductResponse)
@limiter.limit("30/minute")
async def read_product(
    request: Request,
    product_id: str,
    api_key: str = Depends(verify_api_key)
):
    check_db_objectid(product_id)
    product = db.products.find_one({"_id": ObjectId(product_id)})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    product["id"] = str(product.pop("_id"))
    return product

@app.put("/products/{product_id}", response_model=ProductResponse)
@limiter.limit("10/minute")
async def update_product(
    request: Request,
    product_id: str,
    product: Product,
    api_key: str = Depends(verify_api_key)
):
    check_db_objectid(product_id)
    updated = db.products.find_one_and_update(
        {"_id": ObjectId(product_id)},
        {"$set": product.dict()},
        return_document=True
    )
    if not updated:
        raise HTTPException(status_code=404, detail="Product not found")
    updated["id"] = str(updated.pop("_id"))
    return updated

@app.delete("/products/{product_id}")
@limiter.limit("10/minute")
async def delete_product(
    request: Request,
    product_id: str,
    api_key: str = Depends(verify_api_key)
):
    check_db_objectid(product_id)
    result = db.products.delete_one({"_id": ObjectId(product_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"status": "success"}