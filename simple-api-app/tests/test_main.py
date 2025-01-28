from fastapi.testclient import TestClient
from simple_api_app.main import app
import pytest
from bson import ObjectId

client = TestClient(app)

# Test data
test_product = {
    "name": "Test Product",
    "description": "Test Description",
    "price": 99.99
}

def test_create_product():
    response = client.post("/products", json=test_product)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == test_product["name"]
    assert data["description"] == test_product["description"]
    assert data["price"] == test_product["price"]
    assert "id" in data
    return data["id"]

def test_read_products():
    response = client.get("/products")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_read_product():
    # First create a product
    product_id = test_create_product()
    
    # Then read it
    response = client.get(f"/products/{product_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == test_product["name"]
    assert data["description"] == test_product["description"]
    assert data["price"] == test_product["price"]

def test_read_product_invalid_id():
    response = client.get("/products/invalid_id")
    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid product ID"

def test_update_product():
    # First create a product
    product_id = test_create_product()
    
    # Update data
    updated_product = {
        "name": "Updated Product",
        "description": "Updated Description",
        "price": 199.99
    }
    
    response = client.put(f"/products/{product_id}", json=updated_product)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == updated_product["name"]
    assert data["description"] == updated_product["description"]
    assert data["price"] == updated_product["price"]

def test_delete_product():
    # First create a product
    product_id = test_create_product()
    
    # Then delete it
    response = client.delete(f"/products/{product_id}")
    assert response.status_code == 200
    assert response.json()["status"] == "success"

def test_webhook_handler():
    webhook_payload = {
        "event": "test_event",
        "data": {
            "test": "data"
        }
    }
    response = client.post("/webhook", json=webhook_payload)
    assert response.status_code == 200
    assert response.json()["status"] == "success" 