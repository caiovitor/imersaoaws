grupo="bia"
profile="--profile bia"
instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Grupo,Values=$grupo" Name=instance-state-name,Values=running --output text $profile)
aws ec2 stop-instances  --instance-ids $instance_id $profile
