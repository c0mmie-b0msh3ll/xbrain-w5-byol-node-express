# NOTES

## Strategy đã chọn

Mình chọn **`serverless-http` adapter**.

## Lý do chọn

- Đây là cách có số dòng thay đổi rất ít:
  - thêm `lambda.js`
  - thêm dependency `serverless-http`
  - đổi `Handler` trong `template.yaml`
- `app.js` vẫn giữ nguyên là Express app thuần, không bị trộn logic Lambda vào code nghiệp vụ.
- So với tự viết adapter thủ công, cách này giảm rủi ro sai khác request/response mapping với API Gateway.
- So với Lambda Web Adapter, cách này vẫn rất gọn nhưng dễ đọc hơn cho bài tập vì toàn bộ wiring nằm ngay trong repo.

## Deploy

- AWS account: `589077667575`
- Region: `us-west-2`
- Stack name: `byol-node-express`
- API Gateway URL:
  - `https://yp2lyeagpk.execute-api.us-west-2.amazonaws.com`

## Cold start đã đo

Lần gọi đầu tiên sau khi deploy ghi nhận trong CloudWatch Logs:

- `Init Duration: 267.70 ms`
- `Duration: 19.05 ms`
- `Billed Duration: 287 ms`

Nguồn đo: log stream `/aws/lambda/byol-node-express` sau lần gọi đầu tiên vào API.
