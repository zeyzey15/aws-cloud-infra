import json
import boto3
import os
import logging
from urllib.parse import unquote_plus

# Configure logging
logger = logging.getLogger()
log_level = os.environ.get('LOG_LEVEL', 'INFO').upper()
logger.setLevel(getattr(logging, log_level, logging.INFO))

def lambda_handler(event, context):
    logger.info("Lambda function started")
    logger.debug(f"Received event: {json.dumps(event)}")
    
    # Initialize SNS client
    sns = boto3.client('sns')
    
    # Get environment variables
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    enable_detailed_logging = os.environ.get('ENABLE_DETAILED_LOGGING', 'false').lower() == 'true'
    
    logger.info(f"SNS Topic ARN: {sns_topic_arn}")
    logger.info(f"Detailed logging enabled: {enable_detailed_logging}")
    
    try:
        # Parse S3 event
        records_count = len(event['Records'])
        logger.info(f"Processing {records_count} S3 event record(s)")
        
        for i, record in enumerate(event['Records']):
            logger.debug(f"Processing record {i+1}/{records_count}")
            
            # Extract S3 information
            bucket_name = record['s3']['bucket']['name']
            object_key = unquote_plus(record['s3']['object']['key'])
            event_name = record['eventName']
            
            if enable_detailed_logging:
                logger.info(f"Record details - Bucket: {bucket_name}, Object: {object_key}, Event: {event_name}")
            
            # Check if it's a modification or deletion event
            if event_name.startswith('ObjectCreated') or event_name.startswith('ObjectRemoved'):
                
                # Determine action type
                if event_name.startswith('ObjectCreated'):
                    action = "modified"
                else:
                    action = "deleted"
                
                logger.info(f"Object {object_key} was {action} in bucket {bucket_name}")
                
                # Create email message
                subject = f"S3 Bucket Alert: Object {action.capitalize()}"
                message = f"Your object {object_key} was {action} please go to check ur s3 bucket {bucket_name}"
                
                if enable_detailed_logging:
                    logger.debug(f"Email subject: {subject}")
                    logger.debug(f"Email message: {message}")
                
                # Send SNS notification
                logger.info(f"Sending SNS notification to topic: {sns_topic_arn}")
                response = sns.publish(
                    TopicArn=sns_topic_arn,
                    Message=message,
                    Subject=subject
                )
                
                logger.info(f"SNS notification sent successfully for {object_key} in {bucket_name}")
                logger.info(f"Message ID: {response['MessageId']}")
                
                if enable_detailed_logging:
                    logger.debug(f"SNS response: {json.dumps(response, default=str)}")
            else:
                logger.warning(f"Ignoring event type: {event_name} for object {object_key}")
    
    except KeyError as e:
        error_msg = f"Missing required field in S3 event: {str(e)}"
        logger.error(error_msg)
        raise e
    except Exception as e:
        error_msg = f"Error processing S3 event: {str(e)}"
        logger.error(error_msg)
        logger.exception("Full exception traceback:")
        raise e
    
    logger.info("Lambda function completed successfully")
    return {
        'statusCode': 200,
        'body': json.dumps('S3 event processed successfully')
    }


