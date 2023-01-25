import logging
import time

import azure.functions as func


def main(message: func.ServiceBusMessage, context: func.Context):
    # Log the Service Bus Message as plaintext

    message_content_type = message.content_type
    message_body = message.get_body().decode("utf-8")

    if message_body == "SLEEP":
        logging.info(f"#### Got sleep message ({context.invocation_id})!")
        time.sleep(30)
        logging.info(f"#### Sleep complete ({context.invocation_id})")

    logging.info("Python ServiceBus topic trigger processed message.")
    logging.info(f"Message Content Type: {message_content_type}")
    logging.info(f"Message Body: {message_body}")
