# https://gist.github.com/sgnl/b8df35ae166223cebf85

git clone git@github.com:beeNotice/hungryman.git
cd hungryman
git remote add gm2552 git@github.com:gm2552/hungryman.git
git fetch gm2552
git branch --track gm2552 origin/main

kubectl apply -f /mnt/c/Dev/workspaces/hungryman/config/service-operator/
kubectl apply -f /mnt/c/Dev/workspaces/hungryman/config/app-operator/
kubectl apply -f /mnt/c/Dev/workspaces/hungryman/config/developer/


# Delete
kubectl delete -f /mnt/c/Dev/workspaces/hungryman/config/developer/
kubectl delete -f /mnt/c/Dev/workspaces/hungryman/config/app-operator/
kubectl delete -f /mnt/c/Dev/workspaces/hungryman/config/service-operator/
