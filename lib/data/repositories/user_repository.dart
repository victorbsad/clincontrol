import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../database/db_helper.dart';
import '../models/user.dart';

class UserRepository {
  final DbHelper _db = DbHelper();

  Future<AppUser> defineCurrentUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Nome do usuario nao pode estar vazio.');
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw ArgumentError('Email invalido.');
    }
    if (password.isEmpty) {
      throw ArgumentError('Senha nao pode estar vazia.');
    }

    final now = DateTime.now();
    final passwordHash = _hashPassword(password);

    final existing = await _db.fetchUserByEmail(normalizedEmail);

    if (existing != null) {
      existing.name = normalizedName;
      existing.email = normalizedEmail;
      existing.passwordHash = passwordHash;
      existing.isCurrent = true;
      existing.updatedAt = now;
      await _db.updateUser(existing);
      await _db.setCurrentUserById(existing.id!);
    } else {
      await _db.clearCurrentUser();
      final id = await _db.insertUser(
        AppUser(
          name: normalizedName,
          email: normalizedEmail,
          passwordHash: passwordHash,
          isCurrent: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _db.setCurrentUserById(id);
    }

    final current = await _db.fetchCurrentUser();
    if (current == null) {
      throw StateError('Nao foi possivel definir o usuario atual.');
    }
    return current;
  }

  Future<AppUser?> getCurrentUser() => _db.fetchCurrentUser();

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
