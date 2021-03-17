pipeline {
    agent {
        docker {
            image 'hsndocker/aws-cli:latest'
            args '-u root:root'
        }
    }
    parameters {
        string(name: 'ACTION', defaultValue: 'apply')
    }
    environment {
        ACCESS_KEY_ID = credentials('aws-access-key-id')
        SECRET_KEY = credentials('aws-secret-key')
        ACTION = "${params.ACTION}"
    }
    stages {
        stage('Providing Access Keys') {
            steps {
                sh('aws configure set aws_access_key_id $ACCESS_KEY_ID')
                sh('aws configure set aws_secret_access_key $SECRET_KEY')
                sh('aws configure set default.region us-east-2')
            }
        }
        stage('Setting kubeconfig') {
            steps {
                sh('aws eks --region us-east-2 update-kubeconfig --name test-eks-irsa')
            }
        }
        stage('Terraform Initialization') {
            steps {
                sh('terraform init')
            }
        }
        stage('Apply Changes') {
            steps {
                script {
                    if (env.ACTION == 'destroy') {
                        sh('terraform destroy --auto-approve')
                        sh('kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                    }
                    if (env.ACTION == 'apply') {
                        sh('terraform apply --auto-approve')
                    }
                    if (env.ACTION == 'create') {
                        sh('kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                        sh("kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'")
                        sh('terraform apply --auto-approve')
                        // sh('kubectl autoscale deployment php-to-scaleout --cpu-percent=50 --min=1 --max=10')
                    }
                }
            }
        }
    }
}
