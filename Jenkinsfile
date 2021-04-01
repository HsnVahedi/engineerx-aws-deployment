pipeline {
    agent {
        docker {
            image 'hsndocker/aws-cli:latest'
            args "-u root:root --entrypoint=''"
        }
    }
    parameters {
        string(name: 'ACTION', defaultValue: 'apply')
        string(name: 'BACKEND_VERSION', defaultValue: 'latest')
        string(name: 'FRONTEND_VERSION', defaultValue: 'latest')
        string(name: 'CLUSTER_NAME', defaultValue: 'engineerx')
        string(name: 'REGION', defaultValue: 'us-east-2')
        string(name: 'HOST')
    }
    environment {
        ACCESS_KEY_ID = credentials('aws-access-key-id')
        SECRET_KEY = credentials('aws-secret-key')
        ACTION = "${params.ACTION}"
        REGION = "${params.REGION}"
        CLUSTER_NAME = "${params.CLUSTER_NAME}"
        BACKEND_VERSION = "${params.BACKEND_VERSION}"
        FRONTEND_VERSION = "${params.FRONTEND_VERSION}"
        POSTGRES_PASSWORD = credentials('postgres-password')
        DOCKERHUB_CRED = credentials('dockerhub-repo')
        DJANGO_SECRET_KEY = credentials('django-secret-key')
        HOST = "${params.HOST}"
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
                        sh('terraform destroy --var host=$HOST --var django_secret_key=$DJANGO_SECRET_KEY --var region=$REGION --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD --auto-approve')
                        sh('kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                    }
                    if (env.ACTION == 'apply') {
                        sh('terraform apply --var host=$HOST --var django_secret_key=$DJANGO_SECRET_KEY --var region=$REGION --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD --auto-approve')
                    }
                    if (env.ACTION == 'create') {
                        sh('kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml')
                        sh('terraform apply --var host=$HOST --var django_secret_key=$DJANGO_SECRET_KEY --var region=$REGION --var dockerhub_username=$DOCKERHUB_CRED_USR --var dockerhub_password=$DOCKERHUB_CRED_PSW --var backend_version=$BACKEND_VERSION --var frontend_version=$FRONTEND_VERSION --var postgres_password=$POSTGRES_PASSWORD --auto-approve')
                    }
                }
            }
        }
    }
}
