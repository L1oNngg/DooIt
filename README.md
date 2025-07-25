# Kế hoạch phát triển ứng dụng To-Do List (DooIt)

## Tổng quan  
Ứng dụng To-Do List được thiết kế để giúp người dùng quản lý nhiệm vụ cá nhân một cách hiệu quả, với khả năng phân loại nhiệm vụ thành "cuộc sống hàng ngày" và "công việc". Trang chính sẽ hiển thị tất cả nhiệm vụ hiện tại từ các bảng khác nhau, đảm bảo giao diện rõ ràng và dễ sử dụng. Người dùng có thể tạo bảng dự án tùy chỉnh, đặt mục tiêu hàng tháng hoặc hàng năm, và sử dụng các tính năng như nhiệm vụ lặp lại và thông báo để quản lý thời gian. Ứng dụng được xây dựng bằng Flutter và Firebase, với thiết kế cơ sở dữ liệu hỗ trợ mở rộng trong tương lai, chẳng hạn như thêm tính năng hợp tác nhóm.

## Tech Stack

| **Thành phần**         | **Công nghệ**                              |
|-------------------------|--------------------------------------------|
| Frontend                | Flutter (Dart)                            |
| Backend                 | Firebase                                  |
| Xác thực                | Firebase Authentication                   |
| Cơ sở dữ liệu           | Firestore                                 |
| Thông báo               | Firebase Cloud Messaging                  |
| Quản lý trạng thái      | Provider hoặc Riverpod                    |
| Gói bổ sung             | cloud_firestore, firebase_auth, firebase_messaging, intl, flutter_local_notifications, v.v. |

### Giải thích Tech Stack  
- **Flutter (Dart)**: Flutter là framework đa nền tảng, cho phép phát triển ứng dụng chạy trên cả iOS và Android với giao diện mượt mà. Các widget của Flutter hỗ trợ tạo giao diện thân thiện, như bảng điều khiển chính và lịch tích hợp.  
- **Firebase**:  
  - **Firebase Authentication**: Quản lý đăng nhập người dùng, cần thiết để phân tách dữ liệu khi thêm tính năng hợp tác nhóm sau này.  
  - **Firestore**: Cơ sở dữ liệu NoSQL thời gian thực, lý tưởng cho việc lưu trữ và đồng bộ nhiệm vụ, bảng, và mục tiêu.  
  - **Firebase Cloud Messaging (FCM)**: Gửi thông báo đẩy để nhắc nhở người dùng về hạn chót nhiệm vụ.  
- **Quản lý trạng thái**: Provider hoặc Riverpod giúp quản lý dữ liệu động, như danh sách nhiệm vụ hoặc trạng thái hoàn thành, đảm bảo hiệu suất ứng dụng.  
- **Gói bổ sung**: Các thư viện như `intl` hỗ trợ định dạng ngày giờ, `flutter_local_notifications` cho thông báo cục bộ, và các gói Firebase để tích hợp backend.  

Tech stack này được lựa chọn dựa trên sự phổ biến và hiệu quả, như được đề cập trong các tài liệu tham khảo như bài viết trên Medium về ứng dụng To-Do List với Flutter và Firebase ([Medium](https://kymoraa.medium.com/to-do-list-app-with-flutter-firebase-7910bc42cf14)).

## Mô tả hệ thống  
Ứng dụng To-Do List được phát triển bằng Flutter, cung cấp giao diện đa nền tảng cho thiết bị di động. Backend sử dụng Firebase để lưu trữ dữ liệu, quản lý người dùng, và gửi thông báo. Người dùng có thể:  
- Tổ chức nhiệm vụ vào các bảng như "cuộc sống hàng ngày" và "công việc".  
- Tạo bảng dự án tùy chỉnh và xóa bảng mặc định nếu cần.  
- Đặt mục tiêu hàng tháng hoặc hàng năm, liên kết với nhiệm vụ hoặc bảng.  
- Xem tất cả nhiệm vụ hiện tại trên bảng điều khiển chính.  
- Sử dụng các tính năng như lọc, tìm kiếm, nhiệm vụ lặp lại, và tích hợp lịch để quản lý thời gian hiệu quả.  

Hệ thống hỗ trợ đồng bộ thời gian thực qua Firestore, đảm bảo dữ liệu luôn cập nhật trên các thiết bị. Thông báo đẩy qua FCM giúp nhắc nhở người dùng về các hạn chót quan trọng.

## Các chức năng hiện tại  
Dựa trên yêu cầu và giao diện minh họa, tính năng hợp tác nhóm đã được thay thế bằng **nhiệm vụ lặp lại** để tập trung vào quản lý cá nhân. Danh sách 8 chức năng bao gồm:  

| **Chức năng**                  | **Mô tả chi tiết**                                                                 | **Mức độ cần thiết** |
|--------------------------------|-----------------------------------------------------------------------------------|----------------------|
| Quản lý nhiệm vụ               | Tạo, chỉnh sửa, xóa nhiệm vụ với chi tiết như tiêu đề, mô tả, ngày đến hạn, ưu tiên, thẻ. | Rất cao              |
| Bảng dự án                    | Phân loại nhiệm vụ vào các bảng như "cuộc sống hàng ngày", "công việc", và bảng tùy chỉnh. | Rất cao              |
| Thiết lập và theo dõi mục tiêu | Đặt mục tiêu theo tháng/năm, liên kết với nhiệm vụ hoặc dự án, theo dõi tiến độ.   | Cao                  |
| Bảng điều khiển chính          | Hiển thị tất cả nhiệm vụ hiện tại từ các bảng, giúp dễ dàng theo dõi và quản lý.    | Cao                  |
| Lọc và tìm kiếm nhiệm vụ       | Tìm kiếm theo từ khóa, lọc theo trạng thái, ưu tiên, ngày đến hạn, hoặc thẻ.       | Trung bình           |
| Nhiệm vụ lặp lại              | Thiết lập nhiệm vụ lặp lại theo khoảng thời gian (hàng ngày, hàng tuần, hàng tháng). | Cao                  |
| Quản lý thời gian             | Tích hợp lịch, đặt nhắc nhở, và quản lý lịch trình nhiệm vụ.                      | Cao                  |
| Thông báo                     | Gửi thông báo cho nhiệm vụ sắp đến hạn và các cập nhật khác.                      | Cao                  |

### Lý do lựa chọn  
- **Quản lý nhiệm vụ** và **bảng dự án** là cốt lõi, đáp ứng yêu cầu phân loại nhiệm vụ và tạo bảng tùy chỉnh.  
- **Thiết lập mục tiêu** được bao gồm để hỗ trợ mục tiêu tháng/năm, phù hợp với mục "Goals" trong giao diện minh họa.  
- **Nhiệm vụ lặp lại** thay thế hợp tác nhóm, vì đây là tính năng thiết yếu cho quản lý cá nhân, như các công việc hàng ngày hoặc cuộc họp định kỳ.  
- **Bảng điều khiển chính**, **lọc/tìm kiếm**, **quản lý thời gian**, và **thông báo** được thêm vào dựa trên giao diện minh họa (các mục như "Today," "Upcoming," "Filters & Labels") và các ứng dụng To-Do List phổ biến như Todoist ([Zapier](https://zapier.com/blog/best-todo-list-apps/)).  

## Thiết kế cơ sở dữ liệu trong Firebase  
Cơ sở dữ liệu Firestore được thiết kế để lưu trữ và quản lý dữ liệu một cách hiệu quả, với các bộ sưu tập sau:  

- **Users Collection**:  
  - **Document ID**: userId (ID người dùng duy nhất).  
  - **Fields**:  
    - name: Tên người dùng.  
    - email: Địa chỉ email.  
    - createdAt: Thời gian tạo tài khoản.  

- **Boards Collection**:  
  - **Document ID**: boardId (ID bảng duy nhất).  
  - **Fields**:  
    - name: Tên bảng (e.g., "cuộc sống hàng ngày", "công việc").  
    - userId: ID người dùng sở hữu bảng.  
    - createdAt: Thời gian tạo bảng.  

- **Tasks Collection**:  
  - **Document ID**: taskId (ID nhiệm vụ duy nhất).  
  - **Fields**:  
    - title: Tiêu đề nhiệm vụ.  
    - description: Mô tả nhiệm vụ.  
    - dueDate: Ngày đến hạn.  
    - priority: Mức độ ưu tiên (e.g., cao, trung bình, thấp).  
    - status: Trạng thái (e.g., chưa hoàn thành, hoàn thành).  
    - tags: Danh sách thẻ (array).  
    - boardId: ID bảng liên kết.  
    - userId: ID người dùng sở hữu.  
    - isRecurring: Boolean, xác định nhiệm vụ có lặp lại hay không.  
    - recurrence: Object, chứa thông tin lặp lại (e.g., { frequency: "daily", interval: 1, endDate: null }).  
    - createdAt: Thời gian tạo.  
    - updatedAt: Thời gian cập nhật.  

- **Goals Collection**:  
  - **Document ID**: goalId (ID mục tiêu duy nhất).  
  - **Fields**:  
    - title: Tiêu đề mục tiêu.  
    - description: Mô tả mục tiêu.  
    - timeframe: Loại mục tiêu (e.g., "monthly", "yearly").  
    - startDate: Ngày bắt đầu.  
    - endDate: Ngày kết thúc.  
    - userId: ID người dùng sở hữu.  
    - linkedTasks: Danh sách ID nhiệm vụ liên kết (array).  
    - linkedBoards: Danh sách ID bảng liên kết (array).  
    - progress: Tiến độ hoàn thành (e.g., phần trăm).  

### Lưu ý về nhiệm vụ lặp lại  
- Nhiệm vụ lặp lại được quản lý bằng các trường `isRecurring` và `recurrence`.  
- Ứng dụng sẽ xử lý logic để hiển thị các phiên bản nhiệm vụ dựa trên mẫu lặp lại (e.g., hàng ngày, hàng tuần).  
- Ví dụ: Một nhiệm vụ "Tập yoga" có thể được đặt lặp lại hàng ngày với `recurrence: { frequency: "daily", interval: 1 }`.  

## Công việc trong Firebase  
Firebase sẽ được sử dụng để hỗ trợ các chức năng sau:  
- **Firebase Authentication**:  
  - Quản lý đăng ký, đăng nhập, và thông tin hồ sơ người dùng.  
  - Đảm bảo dữ liệu được phân tách theo người dùng, hỗ trợ mở rộng cho hợp tác nhóm sau này.  
- **Firestore Database**:  
  - Lưu trữ và truy xuất dữ liệu người dùng, bảng, nhiệm vụ, và mục tiêu.  
  - Hỗ trợ đồng bộ thời gian thực để cập nhật nhiệm vụ trên các thiết bị.  
  - Cho phép truy vấn linh hoạt, như lấy tất cả nhiệm vụ của một người dùng hoặc nhiệm vụ trong một bảng cụ thể.  
- **Firebase Cloud Messaging**:  
  - Gửi thông báo đẩy để nhắc nhở người dùng về hạn chót nhiệm vụ hoặc các cập nhật quan trọng.  
  - Ví dụ: Gửi thông báo khi một nhiệm vụ sắp đến hạn.  
- **Cloud Functions (tùy chọn)**:  
  - Có thể sử dụng để tự động hóa các tác vụ, như gửi thông báo dựa trên ngày đến hạn hoặc cập nhật tiến độ mục tiêu.  
  - Trong giai đoạn đầu, thông báo có thể được xử lý phía client để đơn giản hóa.  

## Công việc cần làm  
Để triển khai ứng dụng, bạn cần:  
1. **Thiết lập dự án Flutter**: Tạo dự án Flutter và tích hợp các gói như `cloud_firestore`, `firebase_auth`, và `firebase_messaging`.  
2. **Thiết lập Firebase**: Tạo dự án Firebase, bật Authentication, Firestore, và Cloud Messaging.  
3. **Xây dựng giao diện**: Sử dụng Flutter để tạo các màn hình như bảng điều khiển chính, lịch, và trang mục tiêu, dựa trên giao diện minh họa.  
4. **Triển khai cơ sở dữ liệu**: Thiết lập các bộ sưu tập Firestore như mô tả ở trên.  
5. **Xử lý logic nhiệm vụ lặp lại**: Viết mã để tạo và hiển thị các phiên bản nhiệm vụ lặp lại dựa trên mẫu lặp lại.  
6. **Tích hợp thông báo**: Sử dụng FCM để gửi thông báo đẩy, hoặc bắt đầu với `flutter_local_notifications` cho thông báo cục bộ.  
7. **Kiểm tra và tối ưu**: Đảm bảo ứng dụng hoạt động mượt mà trên cả iOS và Android, với đồng bộ thời gian thực và thông báo chính xác.  
8. **Lên kế hoạch mở rộng**: Chuẩn bị cấu trúc dữ liệu để dễ dàng thêm tính năng hợp tác nhóm sau này.  

## Kết luận  
Kế hoạch này cung cấp một lộ trình rõ ràng để phát triển ứng dụng To-Do List với Flutter và Firebase, tập trung vào các tính năng thiết yếu như quản lý nhiệm vụ, bảng dự án, mục tiêu, và nhiệm vụ lặp lại. Thiết kế cơ sở dữ liệu Firestore đảm bảo tính linh hoạt và khả năng mở rộng, trong khi FCM hỗ trợ thông báo kịp thời. Bạn có thể tham khảo thêm các tài liệu sau:  
- [Medium: To-Do List App with Flutter & Firebase](https://kymoraa.medium.com/to-do-list-app-with-flutter-firebase-7910bc42cf14)  
- [Zapier: Best To-Do List Apps](https://zapier.com/blog/best-todo-list-apps/)  
- [Fireship.io: Flutter & Firebase Course](https://fireship.io/courses/flutter-firebase/)  

Hy vọng kế hoạch này sẽ giúp bạn triển khai ứng dụng một cách hiệu quả!