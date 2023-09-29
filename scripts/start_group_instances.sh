grupo_instancia="bia"
profile="--profile bia"
instance_id=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Grupo,Values=$grupo_instancia" --output text $profile)
aws ec2 start-instances  --instance-ids $instance_id $profile
