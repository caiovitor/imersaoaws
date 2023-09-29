grupo="bia"
instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Grupo,Values=$grupo" --output text)
aws ec2 stop-instances  --instance-ids $instance_id
