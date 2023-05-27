pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                echo "Cloning repo..."
                sh 'which git'
                git branch: "master", url: 'https://github.com/ShafiqueMahen/static-website-advanced.git'
                sh 'ls'
            }
        }

        stage('Rebuild with Updated Repo') {
            steps {
                echo "Rebuilding with updated repo..."
                sh '''
                    ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/id_rsa ec2-user@18.170.9.236 'sudo rm -rf /home/jenkins/static-website-advanced/public/*'
                    ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/id_rsa ec2-user@18.170.9.236 'sudo mkdir -p /home/jenkins/static-website-advanced/public/'
                    scp -i /var/lib/jenkins/.ssh/id_rsa -r public/assets public/css public/index.html public/living.html public/products.html public/recipes.html public/report.html public/travel.html ec2-user@18.170.9.236:/home/jenkins/static-website-advanced/public/
                '''
            }
        }
    }
}
