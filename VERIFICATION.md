# Kết quả kiểm tra — 04/10/2026

Đã chạy thực tế trên máy Windows:

- Docker Compose: `docker compose -f ss8/exercise_01/docker-compose.yml config --quiet` thành công với biến môi trường giả chỉ dùng kiểm tra cú pháp; chưa đăng ký runner.
- Script compare-images.ps1: PowerShell parser không báo lỗi.
- cart-service: Gradle 8.10 `bootJar` thành công, biên dịch đích Java 17 bằng JDK 21; output exercise_02/cart-service/build/libs/app.jar.
- payment-service: Gradle 8.10 `bootJar` thành công bằng JDK 21; output exercise_03/payment-service/build/libs/app.jar.
- Chạy cart JAR ở localhost:18081: /actuator/health trả UP, /api/cart trả service=cart-service, mode=demo và items rỗng.
- Chạy payment JAR ở localhost:18082: /actuator/health trả UP, /api/payments/status trả service=payment-service, mode=demo, status=ready.
- Đã dừng hai tiến trình Java sau kiểm tra.

Chưa kiểm chứng:

- Docker image build, kích thước single/multi và chạy container: Docker daemon ban đầu không kết nối được; sau khi khởi động Docker Desktop, lệnh docker version không phản hồi và đã dừng lệnh kiểm tra đó.
- Đăng ký self-hosted runner, đăng nhập/push GHCR và GitHub Actions: chưa có repository SS8 đích và thông tin xác thực cần thiết.
- Chưa có ảnh hoặc URL run/package thành công để nộp.

Kết quả JAR local không thay thế cho minh chứng Docker/GitHub Actions mà đề yêu cầu.
