I want it to be as easy as possible for people to use the product

Easiest way is I do everything for them:
- they still need an account

Second easiest way is for people who have used github


Login (create an account)

sudo apt install git -y

git clone https://github.com/josephf123/indicum-package.git

chmod +x indicum.service run-on-device.sh indicum-client

sudo cp indicum.service /etc/systemd/system/

sudo cp run-on-device.sh indicum-client /usr/local/bin

sudo systemctl daemon-reload




when user generates account:
- server generates a secret token

user then git clones repo
runs 
ansible-playbook playbook.yml "secret-token"

creates username based on email

generates public and private key and stores in /home/.indicum

sets up indicum.service

enable/restart service

