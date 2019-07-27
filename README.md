# kotlin-nativ-lib-iosapp-demo
Демо-приложение для workshop-а по общей кодовой базе на kotlin для iOS проекта

https://www.meetup.com/ru-RU/CocoaHeads-Khabarovsk/events/262315906/

1. создание мультиплатформенного проекта на kotlin
IntelliJ IDEA Community Edition + Kotlin plugin 1.3.41

https://www.jetbrains.com/idea/download/

2. забираем данные, работаем с сетевыми запросами

https://github.com/ktorio/ktor

https://github.com/ktorio/ktor-samples/tree/master/mpp/client-mpp

3. реализуем работу с БД в общем коде

https://github.com/square/sqldelight

4. получаем разрешение экрана (expect/actual код)
используя платформозависимую функцию (expect/actual) в котлин и platform.UIKit.UIScreen в конкретной реализации для iOS

5. сборка и подключение в iOS:
подключаем библиотеку в проекте нажимая + в Embedded binaries в General настройках проекта в Xcode

6. тюнинг Xcode и Gradle

https://github.com/touchlab/xcode-kotlin

https://github.com/touchlab/KotlinXcodeSync

7. проверка на устройстве.
Не забываем изменить в build.gradle изменить iosX64 -> iosArm64 для сборки проекта под процессор реального устройства
