E-Commerce App — AWS EKS + Helm + GitHub Actions (CI/CD)

## 🎯 Proje Amacı

Bu proje, **microservices mimarisi** kullanılarak geliştirilen bir e-ticaret uygulamasının **AWS EKS (Elastic Kubernetes Service)** üzerinde **Helm** ile yönetilmesini ve **GitHub Actions** üzerinden **tam otomatik CI/CD pipeline** kurulmasını amaçlamaktadır.

Hedefimiz gerçek bir üretim senaryosuna yakın olacak şekilde, aşağıdaki adımları içeren bir altyapı kurmak.
1. Terraform ile AWS altyapısının oluşturulması (VPC, Subnet, EKS, Node Group, IAM, ECR, ALB)
2. Dockerize edilmiş frontend & backend microservislerinin ECR’a push edilmesi
3. Helm chart yapısı üzerinden EKS’e otomatik deployment
4. GitHub Actions ile CI/CD sürecinin yönetilmesi
5. ALB (Application Load Balancer) ile dış dünyaya erişim sağlanması

🧱 1. Altyapı Katmanı (Terraform)


Terraform kullanarak EKS Cluster, Node Group, VPC, Subnets, Internet Gateway, Route Table, Security Group, ECR Repository, ve S3 Backend + DynamoDB Locking yapılarını oluşturuldu

Kullanılan AWS Kaynakları:

aws_vpc, aws_subnet, aws_internet_gateway, aws_route_table, aws_security_group
aws_eks_cluster, aws_eks_node_group
aws_ecr_repository
aws_s3_bucket (Terraform state için)
aws_dynamodb_table (state lock için)

Terraform apply sonrasında Kubernetes cluster otomatik olarak oluşturuldu ve kubeconfig konfigüre edildi.

🐳 2. Microservices Katmanı (Frontend & Backend)

🧠Backend (Node.js + Express)
  Basit bir RESTful API içeriyor (/api/products, /health).
  Ürün listeleme, ekleme ve silme endpoint’leri mevcut.
  Port: 4000
  Dockerfile:

🌐Frontend (Nginx + HTML/CSS)
  Statik bir arayüz üzerinden ürün yönetimi yapılabiliyor.
  /api istekleri nginx.conf dosyası ile backend servisine yönlendiriliyor.
  Port: 80
  Dockerfile:

🪣 3. ECR (Elastic Container Registry)

Docker image’build edilip ECR a push ediliyor:  

4. Kubernetes (Helm Chart ile Deployment)

Uygulamanın Kubernetes deployment’ı Helm Chart üzerinden gerçekleştirildi.

    📁 Helm Chart Yapısı
    charts/ecommerce/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        └── ingress.yaml

🚀 5. CI/CD Süreci (GitHub Actions)

GitHub Actions pipeline tamamen otomatik bir şekilde çalışıyor.
Bu yapı sayesinde main branch’e her push sonrası:
Docker image’lar build edilir.
ECR’a push edilir.
Helm release otomatik olarak güncellenir.
Deployment sonrasında pod ve ingress doğrulanır.
Helm chart otomatik olarak aws de alb üretir ve uygulamaya bu endpoint üzerinden ulaşılır
    kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    http://k8s-default-ecommerc-101dc88a48.us-east-1.elb.amazonaws.com/
    http://k8s-default-ecommerc-101dc88a48.us-east-1.elb.amazonaws.com/api/products

🧰 6. Kullanılan Teknolojiler
Katman	            Teknoloji
Cloud	            AWS (EKS, ECR, ALB, IAM, VPC)
Container	        Docker
Orchestration	    Kubernetes
IaC	                Terraform
Deployment	        Helm Charts
CI/CD	            GitHub Actions
Backend	            Node.js (Express)
Frontend	        Nginx (HTML/CSS)

🏁 9. Sonuç

Bu proje ile:

AWS üzerinde production-ready bir EKS ortamı oluşturuldu.
Helm Chart ile frontend + backend microservice deployment sağlandı.
GitHub Actions ile tam otomatik CI/CD pipeline oluşturuldu.
ALB üzerinden public erişim sağlandı.
Bu yapı, hem DevOps süreçlerini hem de Kubernetes ekosistemini uçtan uca gösterebilen tam entegre bir çözümdür.
Gerçek dünya projelerinde yeniden kullanılabilir bir template olarak tasarlanmıştır.