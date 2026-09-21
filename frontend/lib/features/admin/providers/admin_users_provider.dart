import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../models/admin_models.dart';
import 'admin_access_provider.dart';

class AdminUsersState {
  const AdminUsersState({
    this.email = '',
    this.user,
    this.isSearching = false,
    this.isPromoting = false,
    this.emailError,
    this.message,
    this.isError = false,
  });

  final String email;
  final AdminUserSummary? user;
  final bool isSearching;
  final bool isPromoting;
  final String? emailError;
  final String? message;
  final bool isError;
}

final adminUsersEnabledProvider = Provider.autoDispose<bool>((ref) {
  final session = ref.watch(adminAccessContextProvider);

  return ref.watch(adminAccessStateProvider) == AdminAccess.allowed &&
      session.userId != null &&
      session.token != null &&
      session.hasValidCredential &&
      !session.restoring &&
      session.network == NetworkStatus.online;
});

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  AdminUsersNotifier(
    this._ref, {
    required void Function() Function() keepAlive,
  })  : _keepAlive = keepAlive,
        super(const AdminUsersState());

  final Ref _ref;
  final void Function() Function() _keepAlive;

  int _revision = 0;

  void changeEmail(String email) {
    if (state.isPromoting) return;

    //invalidate any in flight lookup, immediately clear its old result
    _revision++;
    state = AdminUsersState(email: email);
  }

  Future<void> search() async {
    if (state.isSearching || state.isPromoting) return;

    final email = state.email.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      state = AdminUsersState(
        email: state.email,
        emailError: 'Enter a valid email address.',
      );
      return;
    }

    if (!_ref.read(adminUsersEnabledProvider)) {
      state = AdminUsersState(
        email: state.email,
        message: 'An online connection and valid admin session are required.',
        isError: true,
      );
      return;
    }

    final revision = ++_revision;
    final repository = _ref.read(adminRepositoryProvider);

    state = AdminUsersState(
      email: email,
      isSearching: true,
    );

    try {
      final user = await repository.findUserByEmail(email);
      if (!mounted || revision != _revision) return;

      state = AdminUsersState(
        email: email,
        user: user,
        message: user.isAdmin ? 'This user is already an administrator.' : null,
      );
    } catch (error) {
      if (!mounted || revision != _revision) return;

      state = AdminUsersState(
        email: email,
        message: _errorMessage(error, promoting: false),
        isError: true,
      );
      _handleAccessError(error);
    }
  }

  Future<void> promote({
    required AdminUserSummary confirmedUser,
    required AdminAccessContext confirmedSession,
  }) async {
    if (state.isPromoting || state.isSearching) return;

    final user = state.user;
    final session = _ref.read(adminAccessContextProvider);

    if (user == null ||
        user.userId != confirmedUser.userId ||
        user.email != confirmedUser.email ||
        user.isAdmin) {
      return;
    }

    if (!_ref.read(adminUsersEnabledProvider) ||
        session.userId != confirmedSession.userId ||
        session.token != confirmedSession.token) {
      state = AdminUsersState(
        email: state.email,
        message:
            'Your session or connection changed. Search for the user again.',
        isError: true,
      );
      return;
    }

    final email = state.email;
    final repository = _ref.read(adminRepositoryProvider);
    final revision = ++_revision;
    final release = _keepAlive();

    state = AdminUsersState(
      email: email,
      user: user,
      isPromoting: true,
    );

    try {
      final updated = await repository.promoteUser(user.userId);
      if (!mounted || revision != _revision) return;

      if (updated.userId != user.userId || !updated.isAdmin) {
        state = AdminUsersState(
          email: email,
          message: 'The server returned an unexpected result. '
              'Search for the user again to verify their role.',
          isError: true,
        );
        return;
      }

      state = AdminUsersState(
        email: email,
        user: updated,
        message: '${updated.displayName} is now an administrator.',
      );
    } catch (error) {
      if (!mounted || revision != _revision) return;

      //clear selection after failure + new lookup required before another promotion, including when result uncertain
      state = AdminUsersState(
        email: email,
        message: _errorMessage(error, promoting: true),
        isError: true,
      );
      _handleAccessError(error);
    } finally {
      release();
    }
  }

  void _handleAccessError(Object error) {
    if (error is DioException &&
        (error.response?.statusCode == 401 ||
            error.response?.statusCode == 403)) {
      _ref.invalidate(adminAccessProvider);
    }
  }

  String _errorMessage(Object error, {required bool promoting}) {
    if (error is DioException) {
      if (promoting && error.response?.statusCode == 409) {
        return 'This user is already an administrator. '
            'Search again to refresh their details.';
      }

      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        final message = (data['message'] as String).trim();
        if (message.isNotEmpty) return message;
      }

      if (error.response?.statusCode == 404) {
        return promoting
            ? 'The user is no longer available. Search again.'
            : 'No user was found with that email address.';
      }

      if (error.response == null) {
        return promoting
            ? 'The promotion could not be confirmed. '
                'Search again to check the user’s role before retrying.'
            : 'Could not connect to search for this user. Please try again.';
      }
    }

    return promoting
        ? 'Could not promote this user. Search again before retrying.'
        : 'Could not search for this user. Please try again.';
  }
}

final adminUsersProvider =
    StateNotifierProvider.autoDispose<AdminUsersNotifier, AdminUsersState>(
  (ref) {
    ref.watch(
      adminAccessContextProvider.select(
        (session) => (
          session.userId,
          session.token,
          session.hasValidCredential,
          session.restoring,
        ),
      ),
    );

    return AdminUsersNotifier(
      ref,
      keepAlive: () {
        final link = ref.keepAlive();
        return link.close;
      },
    );
  },
);
