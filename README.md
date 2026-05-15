# Node.js + Express on AWS Lambda

Ứng dụng này là một Express app bình thường, được đưa lên AWS Lambda bằng
`serverless-http` với lượng thay đổi tối thiểu:

- `app.js` vẫn giữ nguyên logic Express
- `server.js` vẫn dùng để chạy local
- `lambda.js` là entrypoint dành riêng cho Lambda
- `template.yaml` mô tả hạ tầng bằng CloudFormation/SAM
- `deploy.ps1` đóng gói và deploy toàn bộ bằng một lệnh

## 1. Yêu cầu trước khi chạy

Cần có sẵn:

- Node.js 22+
- npm
- AWS CLI v2
- PowerShell
- Một AWS account có quyền tạo:
  - S3 bucket
  - CloudFormation stack
  - Lambda function
  - API Gateway HTTP API
  - CloudWatch Logs
  - IAM role do CloudFormation tạo cho Lambda

Kiểm tra nhanh:

```powershell
node -v
npm -v
aws --version
```

## 2. Cấu hình AWS CLI

Nếu máy chưa đăng nhập AWS CLI:

```powershell
aws configure
```

Nhập:

- `AWS Access Key ID`
- `AWS Secret Access Key`
- `Default region name`: nên dùng `us-west-2`
- `Default output format`: có thể để `json`

Kiểm tra credentials hiện tại:

```powershell
aws sts get-caller-identity
```

Nếu lệnh này trả về `Account` và `Arn`, credentials đã dùng được.

## 3. Cài dependency

```powershell
npm install
```

## 4. Chạy local

```powershell
npm start
```

App local mặc định chạy tại:

```text
http://localhost:3000
```

Test nhanh:

```powershell
curl http://localhost:3000/
curl http://localhost:3000/api/hello/Lan
curl -Method POST http://localhost:3000/api/echo `
  -ContentType 'application/json' `
  -Body '{"hi":"there"}'
```

## 5. Deploy bằng một lệnh

```powershell
.\deploy.ps1
```

Script sẽ tự:

1. lấy AWS Account ID hiện tại
2. tạo S3 artifact bucket nếu chưa có
3. package source code bằng CloudFormation
4. deploy stack
5. in ra API URL sau khi hoàn tất

Mặc định:

- Region: `us-west-2`
- Stack name: `byol-node-express`

Nếu muốn đổi:

```powershell
.\deploy.ps1 -Region us-east-1 -StackName my-express-lambda
```

## 6. Test API sau khi deploy

Sau khi deploy xong, script sẽ in ra URL dạng:

```text
Deployed: https://xxxxxxxxxx.execute-api.us-west-2.amazonaws.com
```

Ví dụ:

```powershell
$API = aws cloudformation describe-stacks `
  --stack-name byol-node-express `
  --region us-west-2 `
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" `
  --output text

curl $API
curl "$API/api/hello/Lan"
curl -Method POST "$API/api/echo" `
  -ContentType 'application/json' `
  -Body '{"hi":"there"}'
```

## 7. Cấu trúc chính

```text
.
├── app.js          # Express app thuần
├── server.js       # Chạy local
├── lambda.js       # Lambda handler
├── template.yaml   # CloudFormation/SAM template
├── deploy.ps1      # Deploy một lệnh
└── package.json
```

## 8. Gỡ hạ tầng

```powershell
aws cloudformation delete-stack `
  --stack-name byol-node-express `
  --region us-west-2
```

Nếu đã đổi stack name hoặc region lúc deploy, dùng đúng giá trị tương ứng khi xóa.

## 9. Lỗi thường gặp

### `Unable to locate credentials`

AWS CLI chưa được cấu hình. Chạy:

```powershell
aws configure
```

### `AccessDenied`

IAM user/role hiện tại thiếu quyền với S3, CloudFormation, Lambda, API Gateway,
CloudWatch Logs hoặc IAM.

### API trả về `502 Bad Gateway`

Kiểm tra:

- `template.yaml` đang dùng `Handler: lambda.handler`
- `lambda.js` có export `handler`
- `npm install` đã chạy để có `serverless-http`

### Deploy lại nhưng không có thay đổi

Đây là bình thường. Script dùng:

```text
--no-fail-on-empty-changeset
```

nên không xem đó là lỗi.
