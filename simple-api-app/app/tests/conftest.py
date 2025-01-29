import pytest
from mongomock import MongoClient
import mongomock
import os
from app.main import app

# Override the MongoDB client with mongomock
API_KEY = os.getenv('API_KEY', 'default-api-key')  # Use env var or default

@pytest.fixture(autouse=True)
def mock_mongodb_connection(monkeypatch):
    mock_client = MongoClient()
    monkeypatch.setattr("app.main.client", mock_client)
    monkeypatch.setattr("app.main.db", mock_client.products_db)
    monkeypatch.setattr("app.main.API_KEY", API_KEY)  # Mock the API key
    return mock_client 