pipeline {
    agent { label 'DockerAgent' } 
    environment {
        DOCKERHUB_CREDENTIALS = credentials('djtoler-dockerhub')
    }
    
    stages {
        stage('BuildFrontend') {
            steps {
              dir('frontend') {
                sh 'sudo docker build -t djtoler/dp9frontend .'
              }
            }
        }
        stage('BuildBackend') {
            steps {
              dir('backend') {
                sh 'sudo docker build -t djtoler/dp9backend .'
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
              }
            }
        }
        stage('PushBackendDockerHub') {
            steps {
              dir('backend') {
                sh 'sudo docker push djtoler/dp9backend'
              }
            }
        }
        
        stage('DeployBackend') {
            agent { label 'KubernetesAgent' }
            steps {
             withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
							 string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
									dir('backend') {	
									   sh 'kubectl apply -f be_deployment.yaml && kubectl apply -f be_service.yaml' 
								}
				}
            }
        }
        
        stage('DeployFrontend') {
            agent { label 'KubernetesAgent' }
            steps {
             withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
							 string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
								 dir('frontend') {
									sh 'kubectl apply -f fe_deployment.yaml && kubectl apply -f fe_service.yaml' 
								}
				}
            }
        }
		
		stage('Init') {
		   agent {label 'awsDeploy'}
		   steps {
			withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
							string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
								dir('initTerraform') {
								  sh 'terraform init' 
								}
				}
			}
		}
		
		stage('Plan') {
		  agent {label 'awsDeploy'}
          steps {
           withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
						   string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                               dir('initTerraform') {
                                 sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"' 
                            }
				}
			}
		}
		
		stage('Apply') {
          agent {label 'awsDeploy'}
          steps {
		   withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                           string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('initTerraform') {
                              sh 'terraform apply plan.tfplan' 
                        }
				}
			}
		}
		
		stage('Destroy') {
		  agent {label 'awsDeploy'}
		  steps {
		   withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
						   string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
							dir('initTerraform') {
							  sh 'terraform destroy -auto-approve -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"'
						}
				}
			}
		}
		
		stage('PythonMessage') {
			steps {
			withCredentials([
				string(credentialsId: 'PYTHON_CRED_URL', variable: 'SLACK_WEBHOOK_URL')
				]) {
					// Your build steps here
					sh 'python slack_message.py'
				}
			}
		}
    }
}
