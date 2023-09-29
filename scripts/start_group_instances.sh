grupo_instancia="bia"
instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Grupo,Values=$grupo_instancia" --output text)
aws ec2 start-instances  --instance-ids $instance_id
