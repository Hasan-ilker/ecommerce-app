replicaCount: 1

backend:
  name: backend
  port: 4000
  path: /api
  image:
    repository: "952732862406.dkr.ecr.us-east-1.amazonaws.com/e-commerce-app-backend"
    tag: "latest"
    pullPolicy: IfNotPresent

frontend:
  name: frontend
  port: 80
  path: /
  image:
    repository: "952732862406.dkr.ecr.us-east-1.amazonaws.com/e-commerce-app-frontend"
    tag: "latest"
    pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/success-codes: "200,301,302"

    # 🔹 Backend için özel ALB koşulu ("/api/*" isteklerini backend'e yönlendir)
    alb.ingress.kubernetes.io/conditions.ecommerce-backend: >
      [{"Field":"path-pattern","PathPatternConfig":{"Values":["/api/*"]}}]

  hosts:
    - host: ""
      paths:
        # 🔹 Frontend (tüm genel trafiği alır)
        - path: /
          pathType: Prefix
          backend:
            service:
              name: ecommerce-frontend
              port:
                number: 80

        # 🔹 Backend (/api/* istekleri backend servisine gider)
        - path: /api
          pathType: Prefix
          backend:
            service:
              name: ecommerce-backend
              port:
                number: 4000
  tls: []
