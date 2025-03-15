# RSVP Webpage by AWS

This project is an **RSVP Webpage** hosted on **AWS S3** with **CloudFront for HTTPS** and **Route 53 for custom domain mapping**. It allows users to RSVP for an event via a simple and responsive web interface.

## 🚀 Features
- Simple **RSVP form** for event registration.
- Hosted on **AWS S3** as a static website.
- Uses **CloudFront** for global distribution and **HTTPS support**.
- Configured with **Route 53** for custom domain integration.
- Implemented via **Terraform** for Infrastructure as Code (IaC).

## 🛠 Deployment Steps

### 1️⃣ **Clone the Repository**
```sh
 git clone https://github.com/ogulcanaydogan/RSVPwebpageByAWS.git
 cd RSVPwebpageByAWS
```

### 2️⃣ **Set Up AWS Credentials**
Ensure you have the AWS CLI configured with credentials:
```sh
 aws configure
```

### 3️⃣ **Initialize Terraform**
```sh
 terraform init
```

### 4️⃣ **Deploy Infrastructure**
```sh
 terraform apply -auto-approve
```
> 🔹 This will create an **S3 bucket, CloudFront distribution, and Route 53 DNS records**.

### 5️⃣ **Upload Website Files to S3**
After the infrastructure is deployed, upload the frontend files:
```sh
 aws s3 cp index.html s3://rsvp.ogulcanaydogan.com/ --acl public-read
```

### 6️⃣ **Verify Deployment**
Once the deployment is complete, your website should be accessible at:
```sh
 https://rsvp.ogulcanaydogan.com
```

## 📜 Infrastructure Overview

### **Terraform Resources:**
- **S3 Bucket** → Stores the static website files.
- **CloudFront Distribution** → Enables HTTPS and caching.
- **Route 53 DNS Record** → Maps the domain `rsvp.ogulcanaydogan.com` to CloudFront.

## 📌 Configuration
- Update `YOUR_ACM_CERTIFICATE_ARN` in Terraform with the correct **AWS Certificate Manager ARN**.
- Replace `YOUR_ROUTE53_ZONE_ID` with your **Route 53 Hosted Zone ID**.

## 🛠 Troubleshooting
### **403 Forbidden (CloudFront)**
1. Ensure **S3 Bucket Policy** allows public access (see `terraform apply` output).
2. Verify **CloudFront Origin** is set to **S3 Website Endpoint**, not the bucket itself.
3. Try clearing the CloudFront cache:
   ```sh
   aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
   ```

## 📜 License
This project is licensed under the MIT License.

## 👤 Author
**Ogulcan Aydogan**  
🔗 [GitHub](https://github.com/ogulcanaydogan)  
🔗 [Website](https://rsvp.ogulcanaydogan.com)
