### Prerequisites
- Create a GCP project.
- Enable GKE.
- Enable IAM.
- Enable Storage.
- Create Terraform State bucket.
- Create a Service Account for Github with admin rights.
- Create a `GCP_SA_SECRET` on Github with the `.json` key.
- Create a `ARTIFACTORY_USERNAME` secret on Github. 
- Create a `ARTIFACTORY_PASSWORD` secret on Github. 


### Usage
Run the initial build github action twice, as the first time, it will try to connect to kubernetes, but it's not fully up and running yet (giving connection refused errors).

### After successful deployment
- Change the default ArgoCd password by running:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
argocd login <ARGOCD_SERVER>  # e.g. localhost:8080 or argocd.example.com
argocd account update-password
```
