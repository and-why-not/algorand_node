# Created by &WhyNot
# Visit https://andwhynot.co/algorand/ for more information
# Version: 1.0.0
# Tested instance types: c6gd.large

# Update instance
sudo yum update -y

# Define algorand data directory
echo export ALGORAND_NODE_DATA=/var/data/ >> ~/.bash_profile
echo export ALGORAND_DATA=/var/data/algorand >> ~/.bash_profile

# Reload profile
. ~/.bash_profile

# Create default Algorand folder
mkdir ~/algorand

# Create data folder
sudo mkdir $ALGORAND_NODE_DATA

# Format instance storage
sudo mkfs.ext4 -E nodiscard /dev/nvme1n1

# Mount instance storage to $ALGORAND_NODE_DATA
sudo mount /dev/nvme1n1 $ALGORAND_NODE_DATA

#Create algorand data folder
sudo mkdir $ALGORAND_DATA

# Change ownership of algorand data folder
sudo chown ec2-user:ec2-user $ALGORAND_DATA

## Start installing Algorand Participation Node
cd ~/algorand

# Retrieve algorand node install
wget https://raw.githubusercontent.com/algorand/go-algorand-doc/master/downloads/installers/update.sh

# Change permission of the update script
chmod 744 update.sh

# Run node installer
./update.sh -i -n -c stable -p ~/algorand -d $ALGORAND_DATA -n

# Configure telemetry
./diagcfg telemetry name -n AndWhyNot-Algo

# Enable telemetry
./diagcfg telemetry enable

# Create alias to start_node
echo 'alias algo_node_start="/home/ec2-user/algorand/goal node start -d $ALGORAND_DATA"' >> ~/.bash_profile

# Create alias to stop_node
echo 'alias algo_node_stop="/home/ec2-user/algorand/goal node stop -d $ALGORAND_DATA"' >> ~/.bash_profile

# Create alias to get status of node
echo 'alias algo_node_status="/home/ec2-user/algorand/goal node status -d $ALGORAND_DATA"' >> ~/.bash_profile

# Reload profile
. ~/.bash_profile

# Start node and configure catchpoint
algo_node_start && ~/algorand/goal node catchup $(wget https://algorand-catchpoints.s3.us-east-2.amazonaws.com/channel/mainnet/latest.catchpoint -q -O -)

# Configure update cron script
crontab -l | { cat; echo "30 * * * * /home/ec2-user/algorand/update.sh -d $ALGORAND_DATA >/home/ec2-user/algorand/update.log 2>&1"; } | crontab -
