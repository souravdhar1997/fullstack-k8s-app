param(
    [Parameter(Mandatory = $true)]
    [string]$ImageTag,

    [string]$Namespace = "notes-app",

    [string]$BackendDeployment = "backend",

    [string]$FrontendDeployment = "frontend"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host "KUBERNETES DEPLOYMENT STARTED"
Write-Host "========================================"

Write-Host "Namespace : $Namespace"
Write-Host "Image Tag : $ImageTag"

Write-Host ""
Write-Host "Current Images"

kubectl get deployment $BackendDeployment `
    -n $Namespace `
    -o=jsonpath="{.spec.template.spec.containers[*].image}"

Write-Host ""

kubectl get deployment $FrontendDeployment `
    -n $Namespace `
    -o=jsonpath="{.spec.template.spec.containers[*].image}"

Write-Host ""
Write-Host ""

Write-Host "Rollout History"

kubectl rollout history deployment/$BackendDeployment -n $Namespace
kubectl rollout history deployment/$FrontendDeployment -n $Namespace

try {

    ########################################################
    # Update Images
    ########################################################

    Write-Host ""
    Write-Host "Updating Backend"

    kubectl set image deployment/$BackendDeployment `
        backend=savvydhar/backend:$ImageTag `
        -n $Namespace

    Write-Host ""

    Write-Host "Updating Frontend"

    kubectl set image deployment/$FrontendDeployment `
        frontend=savvydhar/frontend:$ImageTag `
        -n $Namespace

    ########################################################
    # Wait for Rollout
    ########################################################

    Write-Host ""
    Write-Host "Waiting for Backend Rollout"

    kubectl rollout status deployment/$BackendDeployment `
        -n $Namespace `
        --timeout=180s

    Write-Host ""

    Write-Host "Waiting for Frontend Rollout"

    kubectl rollout status deployment/$FrontendDeployment `
        -n $Namespace `
        --timeout=180s

    ########################################################
    # Success
    ########################################################

    Write-Host ""
    Write-Host "Deployment Successful"
    Write-Host ""

    Write-Host "Running Pods"

    kubectl get pods -n $Namespace -o wide

    Write-Host ""
    Write-Host "Images After Deployment"

    kubectl get deployment $BackendDeployment `
        -n $Namespace `
        -o=jsonpath="{.spec.template.spec.containers[*].image}"

    Write-Host ""

    kubectl get deployment $FrontendDeployment `
        -n $Namespace `
        -o=jsonpath="{.spec.template.spec.containers[*].image}"

    Write-Host ""

}
catch {

    Write-Host ""
    Write-Host "Deployment Failed"
    Write-Host ""

    ########################################################
    # Troubleshooting Info
    ########################################################

    Write-Host "Events"

    kubectl get events `
        -n $Namespace `
        --sort-by=.metadata.creationTimestamp

    Write-Host ""

    Write-Host "Pods"

    kubectl get pods -n $Namespace

    Write-Host ""

    ########################################################
    # Rollback
    ########################################################

    Write-Host "Rolling Back Backend"

    kubectl rollout undo deployment/$BackendDeployment `
        -n $Namespace

    Write-Host ""

    Write-Host "Rolling Back Frontend"

    kubectl rollout undo deployment/$FrontendDeployment `
        -n $Namespace

    Write-Host ""

    Write-Host "Waiting for Rollback"

    kubectl rollout status deployment/$BackendDeployment `
        -n $Namespace

    kubectl rollout status deployment/$FrontendDeployment `
        -n $Namespace

    Write-Host ""
    Write-Host "Rollback Completed"

    exit 1
}