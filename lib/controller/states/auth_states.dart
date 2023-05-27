abstract class AuthStates {}

class AuthInitial extends AuthStates {}

class LoginLoadingState extends AuthStates {}

class LoginSuccessState extends AuthStates {}

class LoginErrorState extends AuthStates {
  final String error;

  LoginErrorState(this.error);
}

class ChangeSuffixIcon extends AuthStates {}

class RegisterLoading extends AuthStates{}
class RegisterSuccess extends AuthStates{}
class RegisterError extends AuthStates{}
