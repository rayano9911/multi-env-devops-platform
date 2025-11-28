# 🔬 أمثلة عملية وحالات استخدام

## مثال 1: نشر تطبيق بسيط على Development

### الخطوة 1: بناء صورة Docker

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8080

CMD ["python", "app.py"]
```

```bash
# requirements.txt
flask==2.0.0
gunicorn==20.1.0
```

```python
# app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return {
        "message": "Hello from Multi-Env DevOps Platform",
        "environment": "development"
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

### الخطوة 2: بناء ودفع الصورة

```bash
# الدخول إلى ECR
make ecr-login

# الحصول على عنوان ECR
ECR_URI=$(aws ecr describe-repositories \
  --query 'repositories[?contains(repositoryName, `dev`)].repositoryUri' \
  --output text \
  --region us-east-1)

# بناء الصورة
docker build -t my-app:1.0 .

# وسم الصورة
docker tag my-app:1.0 $ECR_URI/my-app:1.0

# دفع الصورة
docker push $ECR_URI/my-app:1.0

# التحقق
aws ecr describe-images \
  --repository-name multi-env-devops-platform-dev \
  --region us-east-1
```

### الخطوة 3: نشر على Kubernetes

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
  labels:
    app: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: YOUR_ECR_URI/my-app:1.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: web
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: web
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: web
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  namespace: default
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
    name: web
```

```bash
# نشر التطبيق
kubectl apply -f deployment.yaml

# التحقق من الـ Deployment
kubectl get deployments
kubectl get pods

# عرض السرفيس
kubectl get service my-app-service

# الانتظار للحصول على External IP
kubectl get service my-app-service --watch

# اختبار التطبيق
curl http://<EXTERNAL-IP>
```

---

## مثال 2: توسيع Staging من 2 إلى 4 عقد

### الطريقة الأولى: تعديل Variables

```bash
# تحرير الملف
cd infra/envs/staging
vim terraform.tfvars

# غير:
# desired_size = 4
# max_size = 6

# معاينة
terraform plan -out=tfplan

# تطبيق
terraform apply tfplan

# التحقق
kubectl get nodes
```

### الطريقة الثانية: استخدام Command Line

```bash
cd infra/envs/staging

terraform apply -var="desired_size=4" -var="max_size=6"
```

### الطريقة الثالثة: استخدام Makefile

```bash
# لا توجد طريقة مباشرة، استخدم الطريقة الأولى أو الثانية
```

---

## مثال 3: ترقية Kubernetes من 1.29 إلى 1.30

### الخطوة 1: اختبر في Development أولاً

```bash
cd infra/envs/dev

# عدّل variables.tfvars
vim terraform.tfvars
# غير: kubernetes_version = "1.30"

# معاينة
terraform plan -out=dev-upgrade.tfplan

# تطبيق
terraform apply dev-upgrade.tfplan

# التحقق
kubectl version --short
```

### الخطوة 2: إذا نجح، ارقِ Staging

```bash
cd infra/envs/staging

vim terraform.tfvars
# غير: kubernetes_version = "1.30"

terraform plan && terraform apply
```

### الخطوة 3: أخيراً Production

```bash
cd infra/envs/prod

vim terraform.tfvars
# غير: kubernetes_version = "1.30"

# قبل التطبيق، قم بـ backup
terraform state pull > prod-backup.tfstate

terraform plan && terraform apply
```

---

## مثال 4: نسخ احتياطي واستعادة State

### إنشاء نسخة احتياطية

```bash
# نسخة من Development
cd infra/envs/dev
terraform state pull > dev-backup-$(date +%Y%m%d).tfstate

# نسخة من Staging
cd infra/envs/staging
terraform state pull > staging-backup-$(date +%Y%m%d).tfstate

# نسخة من Production (الأكثر أهمية!)
cd infra/envs/prod
terraform state pull > prod-backup-$(date +%Y%m%d).tfstate

# أرسل النسخ إلى مكان آمن
aws s3 cp *.tfstate s3://my-backups-bucket/terraform/
```

### استعادة State

```bash
# في حالة الضرورة
cd infra/envs/dev

# استعد من النسخة الاحتياطية
terraform state push dev-backup-20251120.tfstate

# تحقق
terraform state list
```

---

## مثال 5: حذف بيئة بأمان

### حذف Development

```bash
cd infra/envs/dev

# معاينة ما سيتم حذفه
terraform plan -destroy

# حذف فعلي
terraform destroy

# تأكيد بـ yes

# التحقق من الحذف
aws ec2 describe-vpcs --filter "Name=tag:Environment,Values=dev"
```

### حذف جميع البيئات

⚠️ **تحذير**: هذا سيحذف كل شيء!

```bash
# Development
cd infra/envs/dev && terraform destroy -auto-approve

# Staging
cd infra/envs/staging && terraform destroy -auto-approve

# Production
cd infra/envs/prod && terraform destroy -auto-approve

# نظف S3
aws s3 rm s3://multi-env-rayan --recursive

# احذف DynamoDB
aws dynamodb delete-table --table-name terraform-locks
```

---

## مثال 6: مراقبة الموارد

```bash
# عرض استهلاك CPU و Memory
kubectl top nodes
kubectl top pods

# مراقبة حالة المجموعة
kubectl cluster-info

# عرض الأحداث
kubectl get events -A --sort-by='.lastTimestamp'

# عرض الـ Services المتاحة
kubectl get services -A

# عرض الـ Ingresses
kubectl get ingress -A

# مراقبة مستمرة للـ Pods
kubectl get pods -A --watch
```

---

## مثال 7: سكيلينج تلقائي (Horizontal Pod Autoscaler)

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

```bash
# تطبيق HPA
kubectl apply -f hpa.yaml

# مراقبة
kubectl get hpa --watch
```

---

## مثال 8: بيانات مستمرة (Persistent Volumes)

```yaml
# persistent-volume.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-with-storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: YOUR_ECR_URI/my-app:1.0
        volumeMounts:
        - name: data
          mountPath: /app/data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: app-data
```

---

## مثال 9: إعدادات البيئة (ConfigMap و Secrets)

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: "staging"
  LOG_LEVEL: "debug"
  DATABASE_HOST: "postgres.default.svc.cluster.local"
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  DATABASE_PASSWORD: "your-secret-password"
  API_KEY: "your-api-key"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-configured
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: YOUR_ECR_URI/my-app:1.0
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets
```

---

## مثال 10: Cleanup والصيانة الدورية

```bash
#!/bin/bash
# cleanup.sh - تنظيف شهري موصى به

echo "🧹 تنظيف الموارد غير المستخدمة..."

# حذف الصور غير المستخدمة من ECR
aws ecr list-images \
  --repository-name multi-env-devops-platform-dev \
  --query 'imageIds[?type==`UNTAGGED`]' \
  --output text | \
  xargs -I {} aws ecr batch-delete-image \
  --repository-name multi-env-devops-platform-dev \
  --image-ids imageTag={}

# حذف تجاوزات Terraform القديمة
find . -name "*.tfplan" -mtime +7 -delete
find . -name "*-backup.tfstate" -mtime +30 -delete

# تنظيف Docker
docker system prune -a -f

# تحديث Terraform
terraform init -upgrade

echo "✅ تم التنظيف!"
```

---

## أفضليات وتجنب الأخطاء الشائعة

### ✅ افعل:
```bash
# ✅ معاينة قبل التطبيق
terraform plan -out=tfplan
terraform apply tfplan

# ✅ حفظ النسخ الاحتياطية
terraform state pull > backup.tfstate

# ✅ تحديث الحالة
terraform refresh

# ✅ اختبر في Dev أولاً
# ثم Staging
# ثم Production
```

### ❌ لا تفعل:
```bash
# ❌ لا تطبق مباشرة بدون معاينة
terraform apply

# ❌ لا تحذف state file مباشرة
rm terraform.tfstate

# ❌ لا تعدّل state يدويا (بدون معرفة)
terraform state rm resource_name

# ❌ لا تنشر تطبيقات في Production مباشرة
# اختبر في Dev و Staging أولاً
```

---

**آخر تحديث**: نوفمبر 2025
**الإصدار**: 1.0

هذه الأمثلة تغطي الحالات الشائعة. للمزيد، راجع الملفات الأخرى!
