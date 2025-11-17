# SocialMediaFeed

Приложение представляет упрощённую ленту социальной сети с загрузкой данных из публичного API, кешированием постов в CoreData, возможностью лайкать записи и поддержкой оффлайн-режима. Реализовано на UIKit с использованием MVC, Alamofire, CoreData, DI-контейнера и простой state machine.

---

## Скриншоты

Лента:
<img src="https://github.com/user-attachments/assets/f02a9185-2acf-406d-891e-657c56ad9fe7"
     width="300" alt="Feed screenshot" />

Лайк:
<img src="https://github.com/user-attachments/assets/49bcea36-1b24-4a96-b1ab-667d62297004"
     width="300" alt="Like screenshot" />

---

## Описание проекта

Приложение получает данные из следующих API-ендпоинтов:

- `https://jsonplaceholder.typicode.com/posts` — список постов  
- `https://jsonplaceholder.typicode.com/users` — список пользователей  

Каждый пост связывается с пользователем по `userId` и отображается в виде таблицы.  
Для каждого поста отображаются:

- имя пользователя  
- заголовок  
- основной текст  
- аватар (через сервис Lorem Picsum: `https://picsum.photos/seed/{userId}/80`)  
- состояние лайка  

После загрузки данные сохраняются в CoreData, что позволяет просматривать ленту оффлайн.  
Обновление ленты доступно через жест pull-to-refresh.

---

## Архитектура

### MVC

**Model**
- DTO-модели для загрузки данных из сети  
- CoreData сущности `PostEntity` и `UserEntity`  
- агрегированная модель `FeedPost` для отображения  

**View**
- `FeedViewController`  
- `FeedTableViewCell`  
- UIKit + AutoLayout  

**Controller**
- загрузка данных через репозиторий  
- переключение состояний state machine  
- обновление интерфейса  
- обработка жестов и лайков  

### Дополнительные компоненты

**DI Container**  
Простой контейнер для управления зависимостями (NetworkService, FeedRepository).

**State Machine**  
Используются состояния:
- `idle`
- `loading`
- `loaded`
- `error`

**Repository (FeedRepository)**  
- объединяет сетевой сервис и CoreData  
- кеширует загруженные данные  
- отвечает за обработку лайков  
- обеспечивает доступ к агрегированной модели `FeedPost`

---

## Используемые технологии

- Swift  
- UIKit  
- AutoLayout  
- MVC  
- Alamofire  
- CoreData  
- Kingfisher
- Pull-to-refresh  
- DI контейнер  
- Простая state machine  

---

## Инструкция по сборке

1. Клонировать проект:
    ```bash
    git clone <repo-url>
    ```

2. Перейти в каталог проекта:
    ```bash
    cd <project-folder>
    ```

3. Открыть проект в Xcode:
    ```bash
    open SocialMediaFeed.xcodeproj
    ```

4. Проверить окружение:
    - Xcode 14+
    - iOS 15+ (в зависимости от минимальной версии проекта)
    - CoreData модель `FeedModel.xcdatamodeld` настроена корректно:
        - Codegen = **Class Definition**,  
        либо  
        - ручные классы сущностей добавлены в Target Membership

5. Дождаться загрузки зависимостей (если используются Swift Package Manager).

6. Собрать и запустить:
    ```text
    ⌘ + R
    ```
