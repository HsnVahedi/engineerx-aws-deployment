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
        REGION = "us-east-2"
        CLUSTER_NAME = "engineerx"
    }
    stages {
        stage('Providing Access Keys') {
            steps {
                sh('aws configure set aws_access_key_id $ACCESS_KEY_ID')
                sh('aws configure set aws_secret_access_key $SECRET_KEY')
                sh('aws configure set default.region $REGION')
            }
        }
        stage('Setting kubeconfig') {
            steps {
                sh('aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME')
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
                        sh('terraform refresh --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                        sh('terraform destroy --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                        sh('kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                    }
                    if (env.ACTION == 'apply') {
                        sh('terraform refresh --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                        sh('terraform apply --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                    }
                    if (env.ACTION == 'create') {
                        sh('kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                        sh('terraform apply --auto-approve --var region=$REGION --var cluster_name=$CLUSTER_NAME')
                    }
                }
            }
        }
    }
}
