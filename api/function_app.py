import azure.functions as func
import logging
import os
import json
from azure.cosmos import CosmosClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="get_count", methods=["GET"])
def get_count(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request")

    connection_string = os.environ.get("COSMOS_DB_CONNECTION_STRING")
    if not connection_string:
        return func.HttpResponse(
            "Cosmos DB connection string not found",
            status_code=500
        )

    try:
        client = CosmosClient.from_connection_string(connection_string)
        database = client.get_database_client("visitors-db")
        container = database.get_container_client("visitors")

        try:
            item = container.read_item(item="counter", partition_key="counter")
            item["count"] += 1
            container.replace_item(item="counter", body=item)
        except Exception:
            item = {"id": "counter", "count": 1}
            container.create_item(body=item)
        
        return func.HttpResponse(
            json.dumps({"count": item["count"]}),
            status_code=200,
        )
    except Exception as e:
        logging.error(f"Error accessing Cosmos DB: {e}")
        return func.HttpResponse(
            f"Internal Server Error: {e}", status_code=500
        )