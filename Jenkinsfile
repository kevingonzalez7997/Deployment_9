pipeline {
    agent { label 'DockerAgent' } 
    environment {
        DOCKERHUB_CREDENTIALS = credentials('djtoler-dockerhub')
        PATH = "/home/ubuntu/.nvm/versions/node/v10.24.1/bin:$PATH"
    }
    
    stages {
        stage('TestFrontend') {
            steps {
                //list docker layers that are taking up instance space and pass the list to the remove command
                //remove a Deployment9 directory if it exists
                //kill any process running on port 3000 which we need clear to test our frontend app
                //clone the repo & move into the frontend directory
                //npm ci vs npm install: faster, made for ci pipelines, skips checking for updates or version compatability
                //start the frontend in the backgroud and keep it running to capture the output and write it to a file
                //give the frontend 30 seconds to fully start
                //search the output txt file for the success message
                sh '''#!/bin/bash
                  docker images -f "dangling=true" -q | xargs docker rmi
                  rm -rf Deployment9
                  npx kill-port 3000
                  git clone https://github.com/djtoler/Deployment9
                  cd Deployment9/frontend
                  npm install --save-dev @babel/plugin-proposal-private-property-in-object
                  npm ci
                  nohup npm start > frontend_start.txt &
                  sleep 30
                  grep "Compiled successfully!" frontend_start.txt
              '''
            }
        }

        stage('BuildFrontend') {
            steps {
              dir('frontend') {
                sh 'pwd'
                sh 'docker build --no-cache -t djtoler/dp9frontend .'
              }
            }
        }

        stage('BuildTestBackend') {
            steps {
              dir('backend') {
                //stop and remove any of our backend containers that may still be on our instance
                //build the backend image 
                //start the backend container
                //dynamically grab the current ip address of our instance
                //store it in a variable
                //curl a backend api endpoint with the -f(failure) flag so the script stops when theres a 400/500 response and keeps going otherwise
                //after a successful request, stop and remove the container
                sh '''#!/bin/bash
                docker stop be_test || true
                docker rm be_test || true
                sudo docker build --no-cache -t djtoler/dp9backend .
                docker run -d -p 8000:8000 --name be_test djtoler/dp9backend
                IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=DP9_Docker_Instance" --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
                export IP
                echo "IP is $IP"
                curl -f http://$IP:8000/api/products/
                docker stop be_test
                docker rm be_test
              '''
              }
            }
        }
        
        stage('DockerHubLogin') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | sudo docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        
        stage('PushFrontendDockerHub') {
            steps {
              dir('frontend') {
                sh 'sudo docker push djtoler/dp9frontend'
                sh 'docker rmi djtoler/dp9frontend:latest'
              }
            }
        }

        stage('PushBackendDockerHub') {
            steps {
              dir('backend') {
                sh 'sudo docker push djtoler/dp9backend'
                sh 'docker rmi djtoler/dp9backend:latest'
              }
            }
        }
        
        stage('DeployBackend') {
            agent { label 'KubernetesAgent' }
            steps {
              dir('backend') {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    sh 'kubectl apply -f be_deployment.yaml && kubectl apply -f be_service.yaml' 
                }
              }
            }
        }
        
        stage('DeployFrontend') {
            agent { label 'KubernetesAgent' }
            steps {
              dir('frontend') {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    sh 'kubectl apply -f fe_deployment.yaml && kubectl apply -f fe_service.yaml' 
                }
              }
            }
        }

        // Added stages from the second Jenkinsfile start here
        stage('Init') {
            agent {label 'awsDeploy'}
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    dir('initTerraform') {
                        sh 'terraform init' 
                    }
                }
            }
        }
        
        stage('Plan') {
            agent {label 'awsDeploy'}
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    dir('initTerraform') {
                        sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"' 
                    }
                }
            }
        }
        
        stage('Apply') {
            agent {label 'awsDeploy'}
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    dir('initTerraform') {
                        sh 'terraform apply plan.tfplan' 
                    }
                }
            }
        }

        // Uncomment if needed
        // stage('Destroy') {
        //     agent {label 'awsDeploy'}
        //     steps {
        //         withCredentials([
        //             string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
        //             string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
        //         ]) {
        //             dir('initTerraform') {
        //                 sh 'terraform destroy -auto-approve -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"'
        //             }
        //         }
        //     }
        // }

        stage('PythonMessage') {
            steps {
                withCredentials([
                    string(credentialsId: 'PYTHON_CRED_URL', variable: 'SLACK_WEBHOOK_URL')
                ]) {
                    sh 'python slack_message.py'
                }
            }
        }
    }
}

