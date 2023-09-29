image_id="ami-0e692fe1bae5ca24c"
quantidade=1
instance_type="t3.micro"
profile="--profile bia"
my_public_ip=$(curl -s https://ipinfo.io/ip)
volume_size=30
volume_type="gp2"
nome_instancia="automacao_awscli"
grupo_instancia="bia"
region="us-east-1"
key_name="acesso_bastion"
vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text $profile)
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id Name=availabilityZone,Values=us-east-1a \
--query "Subnets[0].SubnetId" --output text $profile)
role_name="role-acesso-ssm"

#Verificar se o security-group esta criado, se não tiver criá-lo e definir id
security_group_id=$(aws ec2 describe-security-groups --group-names "AcessoSSH" $profile --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "[OK] Security-group já existe, não é necessário criar um novo."
else
  echo "Criando Security-Group AcessoSSH"
  security_group_id=$(aws ec2 create-security-group \
  --group-name AcessoSSH \
  --description "Security group for SSH access" \
  --query 'GroupId' \
  --output text $profile)
fi

#Verificar se a rule já existe, se não existe criar
rule_ok=$(aws ec2 describe-security-group-rules --filters Name="group-id",Values="'$security_group_id'" --output text --query 'SecurityGroupRules[?CidrIpv4==`'$my_public_ip'/32`].FromPort' $profile)
if [ -z $rule_ok ]
then
  echo "Criando security-group-rule"
  aws ec2 authorize-security-group-ingress \
  --group-id $security_group_id \
  --protocol tcp \
  --port 22 \
  --cidr $my_public_ip/32 \
  $profile
else
  echo "[OK] Security-group-rule já existe, não é necessário criar um novo"
fi

if aws iam get-role --role-name $role_name $profile &>/dev/null; then
    echo "[OK] A role 'role-acesso-ssm' já existe, não é necessário criar uma nova"
else
    echo "Criando role-acesso-ssm"
    /bin/bash criar_role_ssm.sh
fi

#Criar instancias
instance_id=$(aws ec2 run-instances --image-id ami-0e692fe1bae5ca24c --count 1 --instance-type t3.micro \
--security-group-ids $security_group_id --subnet-id $subnet_id \
--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":'$volume_size',"VolumeType":"'$volume_type'"}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$nome_instancia'},{Key=Grupo,Value='$grupo_instancia'}]' \
--iam-instance-profile Name=$role_name --key-name $key_name \
--region $region --user-data user_data_ec2_zona_a.sh $profile --output text \
--query 'Instances[*].InstanceId[]')

if [ -z $instance_id ]; then
   echo "[ERRO] Erro ao criar instância"
else
   echo "[OK] Instância criada com sucesso. InstanceId = ${instance_id}"
fi
