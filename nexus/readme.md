helm repo add sonatype https://sonatype.github.io/helm3-charts/
helm upgrade --install --namespace nexus -f nexus/values.yaml nexus-repo sonatype/nexus-repository-manager