pipeline {
  agent any

  environment {
    DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // Replace with your DockerHub credentials ID
    AWS_ACCESS_KEY_ID     = credentials('aws-credentials')
    AWS_SECRET_ACCESS_KEY = credentials('aws-credentials')
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'git@github.com:satishgonella2024/wordpress-app-deployment.git'
      }
    }
    stage('Dockerize') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    passwordVariable: 'DOCKER_PASSWORD',
                    usernameVariable: 'DOCKER_USERNAME'
                )]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker build -t satish2024/wordpress:latest .
                        docker push satish2024/wordpress:latest
                        docker logout
                    '''
                }
            }
        }

    stage('Deploy Application') {
      steps {
        sshagent(['ec2-instance-ssh-key']) {
          sh '''
          ssh -o StrictHostKeyChecking=no ec2-user@<ec2-public-ip> << EOF
          docker pull satish2024/wordpress:latest
          docker run -d -p 80:80 --name wordpress satish2024/wordpress:latest
          EOF
          '''
        }
      }
    }

    stage('Post-Deployment Validation') {
      steps {
        sh './scripts/validate-deployment.sh'
      }
    }
  }

  post {
    success {
      echo 'WordPress deployment successful.'
    }
    failure {
      echo 'WordPress deployment failed.'
    }
  }
}
