import asyncio
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
from azure.identity.aio import DefaultAzureCredential

FULLY_QUALIFIED_NAMESPACE = "sb-rdncy-demo-weu-main.servicebus.windows.net"
TOPIC_NAME = "TOPIC_NAME"

credential = DefaultAzureCredential()

async def send_single_message(sender):
    # Create a Service Bus message
    message = ServiceBusMessage("Single Message")
    # send the message to the topic
    await sender.send_messages(message)
    print("Sent a single message")