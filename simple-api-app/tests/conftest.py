import pytest
from mongomock import MongoClient
import mongomock
import os
from simple_api_app.main import app

# Override the MongoDB client with mongomock
@pytest.fixture(autouse=True)
def mock_mongodb_connection(monkeypatch):
    mock_client = MongoClient()
    monkeypatch.setattr("simple_api_app.main.client", mock_client)
    monkeypatch.setattr("simple_api_app.main.db", mock_client.products_db)
    return mock_client 