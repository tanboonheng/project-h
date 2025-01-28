from fastapi import FastAPI, HTTPException, Body
from pymongo import MongoClient
from bson import ObjectId
from bson.errors import InvalidId
from pydantic import BaseModel
from typing import Optional, List
import os

app = FastAPI()

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


# Webhook endpoint
@app.post("/webhook")
async def webhook_handler(payload: dict = Body(...)):
    # Store webhook events in MongoDB
    db.webhook_events.insert_one(payload)
    return {"status": "success", "message": "Webhook received"}

# CRUD Operations
@app.post("/products", response_model=ProductResponse)
async def create_product(product: Product):
    product_dict = product.dict()
    result = db.products.insert_one(product_dict)
    product_dict["id"] = str(result.inserted_id)
    return product_dict

@app.get("/products", response_model=List[ProductResponse])
async def read_products():
    products = []
    for product in db.products.find():
        product["id"] = str(product.pop("_id"))
        products.append(product)
    return products

@app.get("/products/{product_id}", response_model=ProductResponse)
async def read_product(product_id: str):
    check_db_objectid(product_id)
    product = db.products.find_one({"_id": ObjectId(product_id)})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    product["id"] = str(product.pop("_id"))
    return product

@app.put("/products/{product_id}", response_model=ProductResponse)
async def update_product(product_id: str, product: Product):
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
async def delete_product(product_id: str):
    check_db_objectid(product_id)
    result = db.products.delete_one({"_id": ObjectId(product_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"status": "success"}