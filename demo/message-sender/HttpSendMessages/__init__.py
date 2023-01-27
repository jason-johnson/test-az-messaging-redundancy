import logging
import os

import azure.functions as func
import asyncio
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
from azure.identity.aio import DefaultAzureCredential

FULLY_QUALIFIED_NAMESPACE =  os.environ.get('FULLY_QUALIFIED_NAMESPACE', "sb-rdncy-demo-weu-main.servicebus.windows.net") 
TOPIC_NAME = os.environ.get("TOPIC_NAME", "sbt-rdncy-demo-weu-main")

credential = DefaultAzureCredential()

def make_message(id, message):
    if id % 5 == 0: return "SLEEP"

    return message

async def send_single_message(sender):
    # Create a Service Bus message
    message = ServiceBusMessage("ORDER")
    # send the message to the topic
    await sender.send_messages(message)
    print("Sent a single message")


async def send_a_list_of_messages(sender):
    # Create a list of messages
    messages = [ServiceBusMessage(make_message(i, "LIST ORDER")) for i in range(50)]
    # send the list of messages to the topic
    await sender.send_messages(messages)
    print("Sent a list of 5 messages")


async def send_batch_message(sender):
    # Create a batch of messages
    async with sender:
        batch_message = await sender.create_message_batch()
        for i in range(100):
            try:
                # Add a message to the batch
                batch_message.add_message(ServiceBusMessage(
                    make_message(i, "BATCH ORDER")))
            except ValueError:
                # ServiceBusMessageBatch object reaches max_size.
                # New ServiceBusMessageBatch object can be created here to send more data.
                break
        # Send the batch of messages to the topic
        await sender.send_messages(batch_message)
    print("Sent a batch of 10 messages")


async def run():
    # create a Service Bus client using the credential.
    async with ServiceBusClient(
            fully_qualified_namespace=FULLY_QUALIFIED_NAMESPACE,
            credential=credential,
            logging_enable=True) as servicebus_client:
        # Get a Topic Sender object to send messages to the topic
        sender = servicebus_client.get_topic_sender(topic_name=TOPIC_NAME)
        async with sender:
            # Send one message
            await send_single_message(sender)
            # Send a list of messages
            await send_a_list_of_messages(sender)
            # Send a batch of messages
            await send_batch_message(sender)
        # Close credential when no longer needed.
        await credential.close()


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    asyncio.run(run())
    print("Done sending messages")
    print("-----------------------")

    if name:
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.")
    else:
        return func.HttpResponse(
            "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
            status_code=200
        )
