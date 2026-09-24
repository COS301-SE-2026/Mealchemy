import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import '../models/vault_member.dart';
import 'vault_repository.dart';
import '../models/vault_invitation.dart';

class MockVaultRepository implements VaultRepository {
  static const int _mockUserId = 1;
  static const Map<int, String> _mockEmails = {
    1: 'sofia@example.com',
    2: 'gabriela@example.com',
    3: 'chef@example.com',
  };

  MockVaultRepository() {
    // An incoming invitation lets the preview exercise acceptance and the accessible-vault list
    final now = DateTime.now().toUtc();

    _vaults.add(
      Vault(
        vaultId: _nextVaultId++,
        ownerId: 2,
        vaultType: VaultTypes.shared,
        name: 'Friends',
        createdAt: now,
      ),
    );

    _invitations.add(
      VaultInvitation(
        invitationId: _nextInvitationId++,
        vaultId: _vaults.last.vaultId,
        vaultName: 'Friends',
        invitedEmail: _mockEmails[_mockUserId]!,
        invitedByEmail: _mockEmails[2]!,
        status: VaultInvitationStatus.pending,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      ),
    );
  }

  final List<Vault> _vaults = [
    Vault(
      vaultId: 1,
      ownerId: _mockUserId,
      vaultType: VaultTypes.private,
      name: 'My Vault',
      createdAt: DateTime.parse('2026-07-01T08:00:00Z'),
    ),
    Vault(
      vaultId: 2,
      ownerId: _mockUserId,
      vaultType: VaultTypes.shared,
      name: 'Family',
      createdAt: DateTime.parse('2026-07-10T10:00:00Z'),
    ),
  ];

  final List<VaultFolder> _folders = [
    VaultFolder(
      folderId: 1,
      vaultId: 1,
      folderName: 'General',
      createdAt: DateTime.parse('2026-07-01T08:00:00Z'),
    ),
    VaultFolder(
      folderId: 2,
      vaultId: 1,
      folderName: 'Weeknight Dinners',
      createdAt: DateTime.parse('2026-07-05T17:30:00Z'),
    ),
    VaultFolder(
      folderId: 3,
      vaultId: 2,
      folderName: 'General',
      createdAt: DateTime.parse('2026-07-10T10:01:00Z'),
    ),
  ];

  final List<VaultFolderRecipe> _folderRecipes = [
    VaultFolderRecipe(
        id: 1,
        folderId: 1,
        recipeId: 1,
        addedAt: DateTime.parse('2026-07-01T08:05:00Z'),
        addedByUserId: _mockUserId),
    VaultFolderRecipe(
        id: 2,
        folderId: 1,
        recipeId: 2,
        addedAt: DateTime.parse('2026-07-01T08:05:00Z'),
        addedByUserId: _mockUserId),
    VaultFolderRecipe(
        id: 3,
        folderId: 2,
        recipeId: 1,
        addedAt: DateTime.parse('2026-07-05T17:32:00Z'),
        addedByUserId: _mockUserId),
    VaultFolderRecipe(
        id: 4,
        folderId: 3,
        recipeId: 2,
        addedAt: DateTime.parse('2026-07-10T10:05:00Z'),
        addedByUserId: _mockUserId),
  ];

  final List<VaultMember> _members = [];
  final List<VaultInvitation> _invitations = [];
  int _nextInvitationId = 1;

  int _nextVaultId = 3;
  int _nextFolderId = 4;
  int _nextFolderRecipeId = 5;
  int _nextMemberId = 1;

  Future<void> _networkDelay() =>
      Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<Vault>> getMyVaults() async {
    await _networkDelay();

    return _vaults.where((vault) {
      return vault.ownerId == _mockUserId ||
          _members.any(
            (member) =>
                member.vaultId == vault.vaultId && member.userId == _mockUserId,
          );
    }).toList();
  }

  @override
  Future<Vault> getVaultById(int vaultId) async {
    await _networkDelay();
    try {
      return _vaults.firstWhere((v) => v.vaultId == vaultId);
    } catch (_) {
      throw StateError('Vault not found.');
    }
  }

  @override
  Future<Vault> createVault(String name) async {
    await _networkDelay();
    final vault = Vault(
      vaultId: _nextVaultId++,
      ownerId: _mockUserId,
      vaultType: VaultTypes.shared,
      name: name,
      createdAt: DateTime.now().toUtc(),
    );
    _vaults.add(vault);
    return vault;
  }

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async {
    await _networkDelay();
    if (!_vaults.any((v) => v.vaultId == vaultId)) {
      throw StateError('Vault not found.');
    }
    return _folders.where((f) => f.vaultId == vaultId).toList();
  }

  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) async {
    await _networkDelay();
    if (!_vaults.any((v) => v.vaultId == vaultId)) {
      throw StateError('Vault not found.');
    }
    final folder = VaultFolder(
      folderId: _nextFolderId++,
      vaultId: vaultId,
      folderName: folderName,
      createdAt: DateTime.now().toUtc(),
    );
    _folders.add(folder);
    return folder;
  }

  @override
  Future<VaultFolder> renameFolder(
      int folderId, int vaultId, String folderName) async {
    await _networkDelay();
    final index = _folders.indexWhere((f) => f.folderId == folderId);
    if (index == -1) throw StateError('Folder not found.');
    final updated = VaultFolder(
      folderId: folderId,
      vaultId: vaultId,
      folderName: folderName,
      createdAt: _folders[index].createdAt,
    );
    _folders[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteFolder(int folderId, int vaultId) async {
    await _networkDelay();
    _folders.removeWhere((f) => f.folderId == folderId);
    _folderRecipes.removeWhere((fr) => fr.folderId == folderId);
  }

  @override
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId) async {
    await _networkDelay();
    if (!_folders.any((f) => f.folderId == folderId)) {
      throw StateError('Folder not found.');
    }
    return _folderRecipes.where((fr) => fr.folderId == folderId).toList();
  }

  @override
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId) async {
    await _networkDelay();
    return _folderRecipes.where((fr) => fr.recipeId == recipeId).toList();
  }

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(
      int folderId, int recipeId) async {
    await _networkDelay();
    if (!_folders.any((f) => f.folderId == folderId)) {
      throw StateError('Folder not found.');
    }
    final record = VaultFolderRecipe(
      id: _nextFolderRecipeId++,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime.now().toUtc(),
      addedByUserId: _mockUserId,
    );
    _folderRecipes.add(record);
    return record;
  }

  @override
  Future<VaultFolderRecipe> moveRecipe(
      int folderRecipeId, int targetFolderId) async {
    await _networkDelay();
    final index = _folderRecipes.indexWhere((fr) => fr.id == folderRecipeId);
    if (index == -1) throw StateError('No record found');

    final currentFolder = _folders.firstWhere(
      (f) => f.folderId == _folderRecipes[index].folderId,
      orElse: () => throw StateError('Folder not found.'),
    );
    final targetFolder = _folders.firstWhere(
      (f) => f.folderId == targetFolderId,
      orElse: () => throw StateError('New folder not found.'),
    );

    if (currentFolder.vaultId != targetFolder.vaultId) {
      throw StateError(
          'Recipes can only moved between folders in the same vault.');
    }

    final moved = VaultFolderRecipe(
      id: folderRecipeId,
      folderId: targetFolderId,
      recipeId: _folderRecipes[index].recipeId,
      addedAt: _folderRecipes[index].addedAt,
      addedByUserId: _folderRecipes[index].addedByUserId,
    );
    _folderRecipes[index] = moved;
    return moved;
  }

  @override
  Future<void> removeRecipeFromFolder(int folderRecipeId) async {
    await _networkDelay();
    _folderRecipes.removeWhere((fr) => fr.id == folderRecipeId);
  }

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async {
    await _networkDelay();
    final vault = _findVault(vaultId);

    final canRead = vault.ownerId == _mockUserId ||
        _members.any(
          (member) => member.vaultId == vaultId && member.userId == _mockUserId,
        );

    if (!canRead) throw StateError('Vault not found.');

    return [
      VaultMember(
        id: null,
        vaultId: vaultId,
        userId: vault.ownerId!,
        email: _mockEmails[vault.ownerId]!,
        joinedAt: vault.createdAt,
        role: VaultMemberRole.owner,
      ),
      ..._members.where((member) => member.vaultId == vaultId),
    ];
  }

  @override
  Future<VaultMember> addMember(int vaultId, String email) async {
    await _networkDelay();
    _requireOwnedSharedVault(vaultId);

    final userId = _findUserId(email);
    if (userId == _mockUserId) {
      throw StateError('You cannot add yourself.');
    }

    return _addViewer(vaultId, userId);
  }

  @override
  Future<void> removeMember(int vaultId, int userId) async {
    await _networkDelay();
    _requireOwnedSharedVault(vaultId);

    final index = _members.indexWhere(
      (member) => member.vaultId == vaultId && member.userId == userId,
    );

    if (index == -1) throw StateError('Vault member not found.');
    _members.removeAt(index);
  }

  @override
  Future<VaultMember> changeMemberRole(
    int vaultId,
    int userId,
    VaultMemberRole role,
  ) async {
    await _networkDelay();
    _requireOwnedSharedVault(vaultId);

    if (role == VaultMemberRole.owner) {
      throw ArgumentError('OWNER cannot be assigned to a member.');
    }

    final index = _members.indexWhere(
      (member) => member.vaultId == vaultId && member.userId == userId,
    );

    if (index == -1) throw StateError('Vault member not found.');

    final updated = _members[index].copyWithRole(role);
    _members[index] = updated;
    return updated;
  }

  @override
  Future<VaultInvitation> createInvitation(int vaultId, String email) async {
    await _networkDelay();
    final vault = _requireOwnedSharedVault(vaultId);
    final userId = _findUserId(email);
    final invitedEmail = _mockEmails[userId]!;

    if (userId == _mockUserId) {
      throw StateError('You cannot invite yourself.');
    }

    if (_members.any(
      (member) => member.vaultId == vaultId && member.userId == userId,
    )) {
      throw StateError('User already a member of this vault.');
    }

    if (_invitations.any(
      (invite) =>
          invite.vaultId == vaultId &&
          invite.invitedEmail == invitedEmail &&
          invite.isPending,
    )) {
      throw StateError('User already has a pending invitation for vault.');
    }

    final now = DateTime.now().toUtc();
    final invitation = VaultInvitation(
      invitationId: _nextInvitationId++,
      vaultId: vaultId,
      vaultName: vault.name,
      invitedEmail: invitedEmail,
      invitedByEmail: _mockEmails[_mockUserId]!,
      status: VaultInvitationStatus.pending,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );

    _invitations.add(invitation);
    return invitation;
  }

  @override
  Future<List<VaultInvitation>> getVaultInvitations(int vaultId) async {
    await _networkDelay();
    _requireOwnedSharedVault(vaultId);

    return _invitations.where((invite) => invite.vaultId == vaultId).toList();
  }

  @override
  Future<List<VaultInvitation>> getMyInvitations() async {
    await _networkDelay();

    return _invitations
        .where(
          (invite) =>
              invite.invitedEmail == _mockEmails[_mockUserId] &&
              invite.isPending,
        )
        .toList();
  }

  @override
  Future<VaultMember> acceptInvitation(int invitationId) async {
    await _networkDelay();
    final index = _pendingInvitationIndex(invitationId);
    final invite = _invitations[index];
    _requireInvitee(invite);

    final member = _addViewer(invite.vaultId, _mockUserId);

    _invitations[index] = invite.withResponse(
      VaultInvitationStatus.accepted,
      DateTime.now().toUtc(),
    );

    return member;
  }

  @override
  Future<VaultInvitation> declineInvitation(int invitationId) async {
    await _networkDelay();
    final index = _pendingInvitationIndex(invitationId);
    final invite = _invitations[index];
    _requireInvitee(invite);

    final updated = invite.withResponse(
      VaultInvitationStatus.declined,
      DateTime.now().toUtc(),
    );

    _invitations[index] = updated;
    return updated;
  }

  @override
  Future<void> cancelInvitation(int invitationId) async {
    await _networkDelay();
    final index = _pendingInvitationIndex(invitationId);
    final invite = _invitations[index];
    _requireOwnedSharedVault(invite.vaultId);

    _invitations[index] = invite.withResponse(
      VaultInvitationStatus.cancelled,
      DateTime.now().toUtc(),
    );
  }

  Vault _findVault(int vaultId) {
    return _vaults.firstWhere(
      (vault) => vault.vaultId == vaultId,
      orElse: () => throw StateError('Vault not found.'),
    );
  }

  Vault _requireOwnedSharedVault(int vaultId) {
    final vault = _findVault(vaultId);

    if (vault.ownerId != _mockUserId || vault.vaultType != VaultTypes.shared) {
      throw StateError('Only the shared vault owner can do this.');
    }

    return vault;
  }

  int _findUserId(String email) {
    final trimmed = email.trim();

    for (final entry in _mockEmails.entries) {
      if (entry.value == trimmed) return entry.key;
    }

    throw StateError('Email not found.');
  }

  VaultMember _addViewer(int vaultId, int userId) {
    if (_members.any(
      (member) => member.vaultId == vaultId && member.userId == userId,
    )) {
      throw StateError('User already a member of this vault.');
    }

    final member = VaultMember(
      id: _nextMemberId++,
      vaultId: vaultId,
      userId: userId,
      email: _mockEmails[userId]!,
      joinedAt: DateTime.now().toUtc(),
      role: VaultMemberRole.viewer,
    );

    _members.add(member);
    return member;
  }

  int _pendingInvitationIndex(int invitationId) {
    final index = _invitations.indexWhere(
      (invite) => invite.invitationId == invitationId,
    );

    if (index == -1) throw StateError('Vault invitation not found.');
    if (!_invitations[index].isPending) {
      throw StateError('Invitation has the wrong status.');
    }

    return index;
  }

  void _requireInvitee(VaultInvitation invitation) {
    if (invitation.invitedEmail != _mockEmails[_mockUserId]) {
      throw StateError('User not the intended recipient.');
    }
  }

  @override
  Future<void> deleteVault(int vaultId) async {
    await _networkDelay();
    _vaults.removeWhere((v) => v.vaultId == vaultId);
    final folderIds = _folders
        .where((f) => f.vaultId == vaultId)
        .map((f) => f.folderId)
        .toList();
    _folders.removeWhere((f) => f.vaultId == vaultId);
    _folderRecipes.removeWhere((fr) => folderIds.contains(fr.folderId));
    _members.removeWhere((m) => m.vaultId == vaultId);
    _invitations.removeWhere((invite) => invite.vaultId == vaultId);
  }
}
