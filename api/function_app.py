import azure.functions as func
import logging
import os
import json
from azure.cosmos import CosmosClient
from azure.cosmos.exceptions import CosmosResourceExistsError, CosmosResourceNotFoundError

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

COUNTER_ID = "counter"
INCREMENT = [{"op": "incr", "path": "/count", "value": 1}]


def _json_response(body: dict, status_code: int) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps(body),
        status_code=status_code,
        mimetype="application/json",
    )


def _increment(container) -> int:
    try:
        item = container.patch_item(
            item=COUNTER_ID, partition_key=COUNTER_ID, patch_operations=INCREMENT
        )
    except CosmosResourceNotFoundError:
        try:
            item = container.create_item(body={"id": COUNTER_ID, "count": 1})
        except CosmosResourceExistsError:
            # A concurrent first request created the document; increment it.
            item = container.patch_item(
                item=COUNTER_ID, partition_key=COUNTER_ID, patch_operations=INCREMENT
            )
    return item["count"]


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
        container = client.get_database_client("visitors-db").get_container_client("visitors")
        return _json_response({"count": _increment(container)}, 200)
    except Exception as e:
        logging.error(f"Error accessing Cosmos DB: {e}")
        return func.HttpResponse(
            f"Internal Server Error: {e}", status_code=500
        )
