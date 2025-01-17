// register_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

// Evento
abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String sobrenome;
  final String cpf;
  final String email;
  final String password;

  RegisterSubmitted({
    required this.name,
    required this.sobrenome,
    required this.cpf,
    required this.email,
    required this.password,
  });
}

// Estado
abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String message;

  RegisterSuccess(this.message);
}

class RegisterFailure extends RegisterState {
  final String error;

  RegisterFailure(this.error);
}

// BLoC
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial());

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterSubmitted) {
      yield RegisterLoading();
      try {
        // Simule uma chamada de registro
        await Future.delayed(Duration(seconds: 2));
        yield RegisterSuccess('Registro realizado com sucesso');
      } catch (e) {
        yield RegisterFailure('Erro ao registrar');
      }
    }
  }
}
