# wait for instance
echo -n "waiting for instance"
while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" = "pending"; do
 echo -n . ; sleep 3;
done; echo " $state"
