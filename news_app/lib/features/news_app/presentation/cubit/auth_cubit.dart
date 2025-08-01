import 'package:bloc/bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/services/local_auth_service.dart';
import '../../utils/validation_utils.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalAuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  /// Attempts to log in user with [email] and [password].
  /// If [rememberMe] is true, stores credentials for auto-login.
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

  /// Attempts to register a new user with [userData].
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

  /// Logs out the current user.
  Future<void> logout() async {
    await _authService.logout();
    emit(AuthLoggedOut());
  }

  /// Checks if user is already authenticated.
  Future<void> checkAuthStatus() async {
    final currentUserMap = await _authService.getCurrentUser();
    if (currentUserMap == null) {
      emit(AuthLoggedOut());
      return;
    }

    final user = User.fromMap(currentUserMap);
    emit(AuthSuccess(user));
  }

  /// Validates registration or profile form data.
  /// Emits [AuthValidationError] if any validation errors exist.
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

  /// Updates the user profile with [userData].
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

  /// Changes user password from [oldPass] to [newPass].
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
