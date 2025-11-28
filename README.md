# Система управління навчальними курсами (LMS)

## 1. Загальна інформація

**Мета проєкту:**  
Створити інформаційну систему для управління навчальними курсами, користувачами, записами на курси, навчальним контентом (модулі, уроки), завданнями, відповідями студентів, оцінками, коментарями та сповіщеннями.

**Основні задачі системи:**

- облік користувачів (адміністратори, викладачі, студенти) та їх ролей;
- створення й управління курсами, модулями, уроками;
- запис студентів на курси та відстеження статусу (enrolled, completed тощо);
- видача завдань, прийом рішень (submission), виставлення оцінок;
- додавання коментарів до уроків, прикріплення файлів;
- надсилання сповіщень користувачам (нові завдання, оцінки і т.д.);
- підтримка soft delete та аудиту змін.

**Технології:**

- **СУБД:** PostgreSQL  
- **Клієнт до БД:** Npgsql (ADO.NET)  
- **Архітектура застосунку:** C# Console App + Repository + Unit of Work  
- **Мова програмування:** C# (.NET 8)  
- **Інші інструменти:**  
  - pgAdmin — адміністрування БД  
  - diagrams.net / dbdiagram.io — ER-діаграма  
  - GitHub — зберігання коду та SQL-скриптів  

## 2. Структура бази даних

**Кількість сутностей:** 15+
### Основні таблиці:

- **app_user** – користувачі системи (адмін, викладач, студент)  
- **role** – ролі користувачів  
- **user_role** – зв’язок багато-до-багатьох між користувачами та ролями  

- **course_category** – категорії курсів (Programming, Databases, Web…)  
- **course** – курси  
- **course_instructor** – викладачі курсів (зв’язок курс–викладач)  

- **module** – модулі курсу  
- **lesson** – уроки, які входять до модулів  

- **enrollment** – записи студентів на курси  
- **assignment** – завдання в рамках курсу  
- **submission** – відповіді студентів на завдання  
- **grade** – оцінки за submission  

- **comment** – коментарі до уроків  
- **attachment** – прикріплені файли до уроків  
- **notification** – сповіщення для користувачів  

### Основні зв’язки між сутностями

- **Користувачі та ролі**
  - `app_user` 1–M `user_role` M–1 `role`  
  (користувач може мати кілька ролей, роль може належати кільком користувачам)

- **Категорії та курси**
  - `course_category` 1–M `course`

- **Курси та викладачі**
  - `course` M–M `app_user` (викладачі) через `course_instructor`

- **Курси → модулі → уроки**
  - `course` 1–M `module`  
  - `module` 1–M `lesson`

- **Запис студентів на курси**
  - `app_user` (студент) 1–M `enrollment` M–1 `course`

- **Завдання / відповіді / оцінки**
  - `course` 1–M `assignment`  
  - `assignment` 1–M `submission`  
  - `submission` 1–1 `grade`

- **Коментарі та вкладення**
  - `lesson` 1–M `comment` (коментарі від користувачів)  
  - `lesson` 1–M `attachment` (файли)  

- **Сповіщення**
  - `app_user` 1–M `notification`

### Ключі

- **Первинні ключі:**  
  - автоінкрементні `id` в основних таблицях (app_user, course, module, lesson, …)  
  - складені PK у таблицях-зв’язках:  
    - `user_role(user_id, role_id)`  
    - `course_instructor(course_id, user_id)`

- **Зовнішні ключі:**  
  - у всіх зв’язаних таблицях (course.category_id → course_category.id, module.course_id → course.id, lesson.module_id → module.id, enrollment.student_id → app_user.id, і т.д.)

## 3. Вимоги до даних

### Soft delete

Реалізовано “м’яке видалення” (soft delete) для ключових сутностей:

- **Таблиці з полями soft delete:**
  - `app_user`
  - `course`
  - `module`
  - `lesson`
  - `assignment`
  - `comment`
  - `attachment`

Поля:

- `is_deleted` (boolean)
- `deleted_at` (timestamptz)
- `deleted_by` (user_id)

Видалення (`DELETE`) перехоплюється тригером `soft_delete_row()` і перетворюється на оновлення `is_deleted = true` замість фізичного видалення.

### Аудит змін

Використовуються стандартні поля аудиту:

- `created_at` – дата створення
- `updated_at` – дата останньої зміни
- `updated_by` – користувач, який останнім змінював запис

Для таблиць із аудитом підключений тригер `set_audit_fields()`, який:

- при `INSERT` заповнює `created_at` (якщо поле є);
- при `INSERT`/`UPDATE` завжди оновлює `updated_at`;
- при `INSERT`/`UPDATE` встановлює `updated_by` на основі `current_setting('app.current_user_id')`.


## 4. Реалізація у PostgreSQL

###  Тригерні функції

- `set_audit_fields()`  
  Автоматично заповнює `created_at`, `updated_at`, `updated_by` (якщо ці поля присутні в таблиці).

- `soft_delete_row()`  
  Перехоплює `DELETE` і виконує “м’яке” видалення через оновлення полів `is_deleted`, `deleted_at`, `deleted_by`.

- `course_search_vector_update()`  
  Оновлює поле `search_vector` для таблиці `course` для підтримки повнотекстового пошуку.

###  Тригери

Приклади тригерів:

- `trg_course_audit`, `trg_module_audit`, `trg_lesson_audit`,  
  `trg_assignment_audit`, `trg_submission_audit`, `trg_grade_audit`,  
  `trg_comment_audit`, `trg_attachment_audit`  
  → викликають `set_audit_fields()`.

- `trg_course_soft_delete`, `trg_module_soft_delete`, `trg_lesson_soft_delete`,  
  `trg_assignment_soft_delete`, `trg_comment_soft_delete`, `trg_attachment_soft_delete`  
  → викликають `soft_delete_row()`.

- `trg_course_search_vector`  
  → викликає `course_search_vector_update()` при `INSERT/UPDATE` на `course`.

###  Збережені функції (Stored Functions / Procedures)

(назви можуть трохи відрізнятися в реальній БД, суть така:)

- `fn_create_course(title, description, category_id, creator_id)`  
  Створює курс, заповнює audit-поля, повертає `course_id`.

- `fn_soft_delete_course(course_id, actor_id)`  
  Логічно видаляє курс (soft delete) із заповненням `deleted_at`/`deleted_by`.

- `fn_enroll_student(course_id, student_id, actor_id)`  
  Записує студента на курс, перевіряє дублікати, повертає `enrollment_id`.

- `fn_unenroll_student(course_id, student_id, actor_id)`  
  Відраховує студента з курсу (оновлення статусу).

- `fn_update_submission_grade(submission_id, grader_id, score, feedback)`  
  Створює/оновлює оцінку за конкретний submission.

Ці функції використовуються як єдиний інтерфейс для бізнес-операцій зі сторони C# (через Repository).

###  Представлення (View)

- `v_courses_active`  
  Активні (не видалені) курси із базовою інформацією.

- `v_lessons_active`  
  Уроки з приєднаними модулями та курсами (без soft-deleted).

- `v_enrollments_detailed`  
  Деталізовані записи зарахувань: назва курсу, ПІБ студента, статус, дата.

- `v_assignment_results`  
  Результати по завданнях: курс, завдання, студент, оцінка, коментар викладача.

###  Індекси

**Типи індексів (мінімум 2 різні):**

- **B-Tree (за замовчуванням):**

  ```sql
  CREATE UNIQUE INDEX idx_enrollment_student_course
      ON enrollment(student_id, course_id);
  Використовується для швидкої перевірки унікальності запису студента на курс.

- GIN – для повнотекстового пошуку:

CREATE INDEX idx_course_search
    ON course USING GIN(search_vector);

Дозволяє виконувати запити типу:

SELECT * FROM v_courses_active
WHERE search_vector @@ plainto_tsquery('postgresql');

##  2. Робота з БД через C# (Repository + Unit of Work)

**Патерни**

Repository
Інкапсулює логіку доступу до БД для окремої групи сутностей.

Приклади:

CourseRepository

GetActiveCoursesAsync() – читає із v_courses_active

CreateCourseAsync(...) – викликає fn_create_course(...)

SoftDeleteCourseAsync(...) – викликає fn_soft_delete_course(...)

EnrollmentRepository

GetEnrollmentsAsync() – читає із v_enrollments_detailed

EnrollStudentAsync(...) – викликає fn_enroll_student(...)

UnenrollStudentAsync(...) – викликає fn_unenroll_student(...)

**Unit of Work (PgUnitOfWork)**

Відповідає за:

- створення та відкриття NpgsqlConnection;

- початок транзакції (NpgsqlTransaction);

- надання доступу до репозиторіїв:

--ICourseRepository Courses { get; }

--IEnrollmentRepository Enrollments { get; }

- фіксацію змін через CommitAsync().

**Приклад використання**

await using var uow = new PgUnitOfWork(ConnectionString);

// 1. Отримати активні курси (через VIEW)

var courses = await uow.Courses.GetActiveCoursesAsync();

foreach (var c in courses)

{

    Console.WriteLine($"[{c.Id}] {c.Title} ({c.Level})");

}

// 2. Записати студента на курс (через stored function)

int enrollmentId = await uow.Enrollments.EnrollStudentAsync(

    courseId: 1,
    studentId: 4,
    actorId: 1 // admin
    
);

// 3. Подивитися детальні записи зарахувань (через VIEW)

var enrollments = await uow.Enrollments.GetEnrollmentsAsync();

foreach (var e in enrollments)
{

    Console.WriteLine($"[{e.EnrollmentId}] {e.StudentName} → {e.CourseTitle} ({e.Status})");
    
}

// 4. Зафіксувати транзакцію

await uow.CommitAsync();


**Усі запити до БД йдуть:**

-тільки через VIEW та збережені функції,
-без прямого доступу до таблиць з коду, що відповідає вимогам завдання.
