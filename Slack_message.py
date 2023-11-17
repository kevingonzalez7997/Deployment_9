import os
import requests
import json

try:
    # Retrieve Slack webhook URL from environment variable
    webhook_url = os.environ.get('SLACK_WEBHOOK_URL')

    if not webhook_url:
        raise ValueError("Error: Slack webhook URL not found in environment variables.")

    message = {'text': "Your Jenkins pipeline has completed."}

    # Send a POST request to the Slack webhook
    response = requests.post(webhook_url, data=json.dumps(message), headers={'Content-Type': 'application/json'})

    # Check if the request was successful (status code 200)
    response.raise_for_status()

    print("Slack message sent successfully.")
except ValueError as ve:
    print(f"Error: {ve}")
except requests.exceptions.RequestException as re:
    print(f"Error sending Slack message: {re}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
