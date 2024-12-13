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

    stage('Build Docker Image') {
      steps {
        sh '''
        docker build -t your-dockerhub-username/wordpress:latest .
        docker login -u $DOCKER_CREDENTIALS_USR -p $DOCKER_CREDENTIALS_PSW
        docker push your-dockerhub-username/wordpress:latest
        '''
      }
    }

    stage('Deploy Application') {
      steps {
        sshagent(['ec2-instance-ssh-key']) {
          sh '''
          ssh -o StrictHostKeyChecking=no ec2-user@<ec2-public-ip> << EOF
          docker pull your-dockerhub-username/wordpress:latest
          docker run -d -p 80:80 --name wordpress your-dockerhub-username/wordpress:latest
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
