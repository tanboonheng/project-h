import pytest
from mongomock import MongoClient
import mongomock
import os
from main import app

# Override the MongoDB client with mongomock
@pytest.fixture(autouse=True)
def mock_mongodb_connection(monkeypatch):
    mock_client = MongoClient()
    monkeypatch.setattr("main.client", mock_client)
    monkeypatch.setattr("main.db", mock_client.products_db)
    return mock_client 