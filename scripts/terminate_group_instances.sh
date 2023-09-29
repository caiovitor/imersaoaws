grupo="bia"
profile="--profile bia"
instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Grupo,Values=$grupo" Name=instance-state-name,Values=stopped,running --output text $profile)
aws ec2 terminate-instances  --instance-ids $instance_id $profile
