# My CV Application

This project is a Frontendweb application designed to display a user's CV. It is containerized using Docker and can be deployed on Kubernetes. The project demonstrates the use of Docker for building images and running containers, and it is set up to work seamlessly with Kubernetes for deployment.

## Project Structure

```
My-cv-app/
│
├── app/
│   ├── templates/
│   │   └── index.html  # HTML template for displaying the CV
│   ├── static/
│   │   └── css/
│   │       └── styles.css  # CSS for styling the CV
│
├── Dockerfile  # Dockerfile for building the Docker image
└── docker-compose.yml  # Docker Compose file for running the application
```

## Prerequisites

- Docker
- Docker Compose
- Kubernetes (Minikube or any other cluster)
- Ansible (for automation)

## Getting Started

1. **Clone the Repository**

   Clone the repository to your local machine:

   ```bash
   git clone https://github.com/Ahmed3019/My-cv-app.git
   cd My-cv-app
   ```

2. **Build the Docker Image**

   Build the Docker image using the following command:

   ```bash
   docker build -t ahmedsalama3014/frontend-task:v1 .
   ```

3. **Run the Docker Container**

   You can run the Docker container using:

   ```bash
   docker run -d --name frontend-task -p 8020:80 ahmedsalama3014/frontend-task:v1
   ```

4. **Push the Docker Image to Docker Hub**

   Push the Docker image to your Docker Hub account:

   ```bash
   docker push ahmedsalama3014/frontend-task:v1
   ```

## Deployment on Kubernetes

To deploy the application on a Kubernetes cluster, you can use the following commands:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Make sure to replace the image name in the deployment YAML file with `ahmedsalama3014/frontend-task:v1`.

## Ansible Playbook for Automation

The following Ansible playbook can be used to automate the Docker build and deployment process:

```yaml
---
- name: "Automate Docker Build using Ansible"
  hosts: localhost
  tasks:
    - name: Stop running container
      command: docker stop frontend-task
      ignore_errors: yes

    - name: Remove stopped container
      command: docker rm frontend-task
      ignore_errors: yes

    - name: Remove used image
      command: docker rmi ahmedsalama3014/frontend-task:v1
      ignore_errors: yes

    - name: Build new image
      command: docker build -t ahmedsalama3014/frontend-task:v1 .
      args:
        chdir: /home/control/depi-study/argoCD/My-cv-app

    - name: Push docker image
      command: docker push ahmedsalama3014/frontend-task:v1

    - name: Run new container
      command: docker run -d --name frontend-task -p 8020:80 ahmedsalama3014/frontend-task:v1
```

### Usage

1. Save the above playbook as `docker_build.yml`.
2. Run the playbook using:

   ```bash
   ansible-playbook docker_build.yml
   ```

## Conclusion

This Frontendweb application serves as a simple CV display, showcasing the integration of Docker, Kubernetes, and Ansible for modern application deployment. For further improvements, consider adding features like user authentication or a database for storing multiple CVs.
