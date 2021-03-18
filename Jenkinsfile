pipeline {
    agent {
        docker {
            image 'hsndocker/aws-cli:latest'
            args '-u root:root'
        }
    }
    parameters {
        string(name: 'ACTION', defaultValue: 'apply')
        string(name: 'BACKEND_VERSION', defaultValue: 'latest')
        string(name: 'FRONTEND_VERSION', defaultValue: 'latest')
        string(name: 'EFS_ID')
    }
    environment {
        ACCESS_KEY_ID = credentials('aws-access-key-id')
        SECRET_KEY = credentials('aws-secret-key')
        ACTION = "${params.ACTION}"
        REGION = "us-east-2"
        CLUSTER_NAME = "engineerx"
        BACKEND_VERSION = "${params.BACKEND_VERSION}"
        FRONTEND_VERSION = "${params.FRONTEND_VERSION}"
        POSTGRES_PASSWORD = credentials('postgres-password')
        EFS_ID = "${params.EFS_ID}"
        DOCKERHUB_CRED = credentials('dockerhub-repo')  
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
                        sh('terraform refresh --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var efs_id=$EFS_ID --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD')
                        sh('terraform destroy --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var efs_id=$EFS_ID --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD --auto-approve')
                        sh('kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                    }
                    if (env.ACTION == 'apply') {
                        sh('terraform refresh --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var efs_id=$EFS_ID --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD')
                        sh('terraform apply --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var efs_id=$EFS_ID --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD --auto-approve')
                    }
                    if (env.ACTION == 'create') {
                        sh('kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                        sh('terraform apply --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var efs_id=$EFS_ID --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD --auto-approve')
                    }
                }
            }
        }
    }
}
