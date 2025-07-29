import 'package:bloc/bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/services/local_auth_service.dart';
import '../../utils/validation_utils.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalAuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> login(String email, String password, bool rememberMe) async {
    emit(AuthLoading());

    final success = await _authService.login(email, password);
    if (!success) {
      emit(AuthError('Invalid credentials', 'email'));
      return;
    }

    final currentUserMap = await _authService.getCurrentUser();
    if (currentUserMap == null) {
      emit(AuthError('User session not found', 'session'));
      return;
    }

    final user = User.fromMap(currentUserMap);
    emit(AuthSuccess(user));
  }

  Future<void> register(Map<String, dynamic> userData) async {
    emit(AuthLoading());

    final success = await _authService.register(userData);
    if (!success) {
      emit(AuthError('User already exists', 'email'));
      return;
    }

    final currentUserMap = await _authService.getCurrentUser();
    final user = currentUserMap != null
        ? User.fromMap(currentUserMap)
        : User.fromMap(userData);

    emit(AuthRegistered(user));
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(AuthLoggedOut());
  }

  Future<void> checkAuthStatus() async {
    final currentUserMap = await _authService.getCurrentUser();
    if (currentUserMap == null) {
      emit(AuthLoggedOut());
      return;
    }

    final user = User.fromMap(currentUserMap);
    emit(AuthSuccess(user));
  }

  void validateForm(Map<String, dynamic> formData) {
    final errors = <String, String>{};

    if (!ValidationUtils.validateEmail(formData['email'])) {
      errors['email'] = 'Invalid email format';
    }

    if (!ValidationUtils.validatePassword(formData['password'])) {
      errors['password'] =
          'Password must be 8+ chars, include upper, number, special char';
    }

    if (!ValidationUtils.validateName(formData['firstName'])) {
      errors['firstName'] = 'Invalid first name';
    }

    if (!ValidationUtils.validateName(formData['lastName'])) {
      errors['lastName'] = 'Invalid last name';
    }

    if (!ValidationUtils.validateAge(formData['dateOfBirth'])) {
      errors['dateOfBirth'] = 'Must be at least 18 years old';
    }

    if (!ValidationUtils.validatePhone(formData['phoneNumber'])) {
      errors['phoneNumber'] = 'Invalid phone format';
    }

    if (errors.isNotEmpty) {
      emit(AuthValidationError(errors));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> userData) async {
    emit(AuthLoading());

    final success = await _authService.updateProfile(userData);
    if (!success) {
      emit(AuthError('Failed to update profile', 'update'));
      return;
    }

    final currentUserMap = await _authService.getCurrentUser();
    final user = currentUserMap != null
        ? User.fromMap(currentUserMap)
        : User.fromMap(userData);

    emit(AuthSuccess(user));
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    emit(AuthLoading());

    final success = await _authService.changePassword(oldPass, newPass);
    if (!success) {
      emit(AuthError('Incorrect old password', 'password'));
      return;
    }

    final currentUserMap = await _authService.getCurrentUser();
    if (currentUserMap != null) {
      final user = User.fromMap(currentUserMap);
      emit(AuthSuccess(user));
    } else {
      emit(AuthError('Password changed but session lost', 'password'));
    }
  }
}
