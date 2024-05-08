import boto3
import json


def lambda_handler(event, context):
        # Print the received event to understand its structure
    print("Received event:")
    print(json.dumps(event, indent=3))
    
    # Check if the event is from a branch creation/update
    if 'detail' in event and 'event' in event['detail']:
        detail = event['detail']
        event_type = detail['event']
        
        if detail['referenceType'] == 'branch' and event_type in ['referenceCreated', 'referenceUpdated']:
            # Extract the commit ID from the latest commit in the branch
            commit_id = detail['commitId']


        # Start the CodePipeline execution
        codepipeline_client = boto3.client('codepipeline')
        response = codepipeline_client.start_pipeline_execution(
            name='aim-be-codepipeline',
            sourceRevisions=[
                {
                    'actionName': 'Download-Source',
                    'revisionType': 'COMMIT_ID',
                    'revisionValue': commit_id
                },
            ]
        )

        # Log the response
        print(response)