# Escuta Mobile App / Aplicativo Mobile Escuta

A mobile application developed in **Flutter** and **Dart**, using a **MySQL** database. It includes a user login and management system, real-time chat through WebSockets, offline and updated bus schedules, tips and messages from administrators, notifications via **One Signal**, and an alert system for updates and important system messages. Additionally, it features a seasonal ticket purchase system for events, managed by administrators.

Um aplicativo móvel desenvolvido em **Flutter** e **Dart**, utilizando um banco de dados **MySQL**. Inclui um sistema de login e gerenciamento de usuários, chat em tempo real via WebSockets, horários de ônibus atualizados e disponíveis offline, dicas e mensagens que os administradores podem enviar aos usuários, notificações via **One Signal** e um sistema de avisos para atualizações e mensagens importantes sobre o sistema. Além disso, possui uma funcionalidade de compra de ingressos para eventos, liberada sazonalmente pelos administradores.

---

## Download

- [Google Play Store](https://play.google.com/store/apps/details?id=amttdetra.horarios_transporte&hl=pt_BR)

---

## Features / Funcionalidades

### 1. **User Login and Management / Login e Gerenciamento de Usuários**
- Secure user authentication.
- Password recovery system.
- User roles and permissions.

- Autenticação segura de usuários.
- Sistema de recuperação de senhas.
- Funções e permissões de usuários.

### 2. **Real-Time Chat / Chat em Tempo Real**
- Communication between users and administrators through **WebSockets**.
- Notification of new messages.

- Comunicação entre usuários e administradores via **WebSockets**.
- Notificação de novas mensagens.

### 3. **Bus Schedules / Horários de Ônibus**
- Displays updated schedules.
- Offline availability of bus schedules.

- Exibe horários atualizados.
- Disponibilidade offline dos horários de ônibus.

### 4. **Notifications / Notificações**
- Sends important updates and announcements via **One Signal**.

- Envia atualizações importantes e avisos via **One Signal**.

### 5. **Ticket Purchase / Compra de Ingressos**
- Seasonal event ticket purchase feature, enabled by administrators.

- Funcionalidade sazonal para compra de ingressos de eventos, habilitada pelos administradores.

---

## Technologies Used / Tecnologias Utilizadas

- **Frontend**: Flutter (Dart)
- **Backend**: MySQL Database
- **Real-Time Communication**: WebSockets
- **Notifications**: One Signal
- **Event Ticket System**: Custom implementation for seasonal events

- **Frontend**: Flutter (Dart)
- **Backend**: Banco de Dados MySQL
- **Comunicação em Tempo Real**: WebSockets
- **Notificações**: One Signal
- **Sistema de Ingressos**: Implementação personalizada para eventos sazonais

---

## Installation / Instalação

### Prerequisites / Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- MySQL database server
- One Signal account for notifications setup

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Servidor de banco de dados MySQL
- Conta do One Signal para configuração de notificações

### Steps / Passos

1. Clone the repository / Clone o repositório:

   ```bash
   git clone https://github.com/diluan135/conecta_bus.git

2. Install the dependencies / Instale as dependências:

   ```bash
   flutter pub get
   
3. Configure the .env file with your database and One Signal credentials / Configure o arquivo .env com as credenciais do banco de dados e do One Signal.

   ```bash
   flutter pub get
   
4. Run the app on a simulator or device / Execute o aplicativo em um simulador ou dispositivo:
