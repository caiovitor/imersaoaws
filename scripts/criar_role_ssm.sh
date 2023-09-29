role_name="role-acesso-ssm"
policy_name="AmazonSSMManagedInstanceCore"
profile="--profile bia"

aws iam create-role --role-name $role_name --assume-role-policy-document file://ec2_principal.json $profile
# Cria o perfil de instância
aws iam create-instance-profile --instance-profile-name $role_name $profile

# Adiciona a função IAM ao perfil de instância
aws iam add-role-to-instance-profile --instance-profile-name $role_name --role-name $role_name $profile

aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/$policy_name $profile
