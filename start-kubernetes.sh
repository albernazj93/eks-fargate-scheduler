handler () {
    set -e

    # Event Data is sent as the first parameter
    EVENT_DATA=$1

    # This is the Event Data
    echo $EVENT_DATA

    # Example of command usage
    EVENT_JSON=$(echo $EVENT_DATA | jq .)

    # Create Kube config
    export KUBECONFIG="/tmp/.kube/config"
    kubeconfig=$(aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION --kubeconfig ${KUBECONFIG})

    for deploy in $(kubectl get deployments -n dev | tail | cut -d ' ' -f 1); do \
        replicas=$(kubectl get deployment/$deploy -n dev -o jsonpath='{@.metadata.annotations.previous-replicas}'); \
        kubectl scale --replicas $replicas deployment/$deploy -n dev; \
    done

    # This is the return value because it's being sent to stderr (>&2)
    echo "{\"success\": true}" >&2
}