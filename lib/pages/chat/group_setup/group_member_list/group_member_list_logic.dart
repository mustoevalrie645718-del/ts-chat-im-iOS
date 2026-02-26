import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../core/controller/im_controller.dart';
import '../group_setup_logic.dart';

/// Group member operation types
enum GroupMemberOpType {
  view,
  transferRight,
  call,
  at,
  del,
}

/// Constants for group member management
class _GroupMemberConstants {
  static const int initialPageSize = 500;
  static const int normalPageSize = 100;
  static const int maxSelectionCount = 10;
  static const int defaultMemberLevel = 1;
}

/// Compatibility getters for existing view code
extension GroupMemberListLogicCompat on GroupMemberListLogic {
  GroupMemberOpType get opType => operationType;
  CustomPopupMenuController get poController => popupController;
  RefreshController get controller => refreshController;
  RxList<GroupMembersInfo> get checkedList => selectedMembers;
  bool get isMultiSelMode => isMultiSelectionMode;
  int get maxLength => maxSelectionCount;
  bool get canLookMembersInfo => canViewMemberInfo;

  Future<void> onLoad() => _loadMembers();
  void search() => searchMembers();
  void delMember() => deleteMember();
  void clickMember(GroupMembersInfo member) => onMemberTap(member);
  bool isChecked(GroupMembersInfo member) => isMemberSelected(member);
  bool hiddenMember(GroupMembersInfo member) => shouldHideMember(member);
  void confirmSelectedMember() => confirmSelectedMembers();
}

class GroupMemberListLogic extends GetxController {
  // Dependencies
  final _imLogic = Get.find<IMController>();
  final _groupSetupLogic = Get.find<GroupSetupLogic>();

  // Controllers
  final refreshController = RefreshController();
  final popupController = CustomPopupMenuController();

  // Observable data
  final memberList = <GroupMembersInfo>[].obs;
  final selectedMembers = <GroupMembersInfo>[].obs;
  final myGroupMemberLevel = _GroupMemberConstants.defaultMemberLevel.obs;

  // Configuration
  late GroupInfo groupInfo;
  late GroupMemberOpType operationType;
  int _pageSize = _GroupMemberConstants.initialPageSize;

  // Subscriptions
  late StreamSubscription _memberInfoSubscription;
  late StreamSubscription _groupInfoSubscription;

  // Permission checks
  bool get canViewMemberInfo => groupInfo.lookMemberInfo != 1 || myGroupMemberLevel.value != GroupRoleLevel.member;

  // Operation mode checks
  bool get isMultiSelectionMode =>
      operationType == GroupMemberOpType.call ||
      operationType == GroupMemberOpType.at ||
      operationType == GroupMemberOpType.del;

  bool get shouldExcludeSelf =>
      operationType == GroupMemberOpType.call ||
      operationType == GroupMemberOpType.at ||
      operationType == GroupMemberOpType.transferRight;

  bool get isDeletingMembers => operationType == GroupMemberOpType.del;

  // Permission checks
  bool get isAdmin => myGroupMemberLevel.value == GroupRoleLevel.admin;
  bool get isOwner => myGroupMemberLevel.value == GroupRoleLevel.owner;
  bool get isOwnerOrAdmin => isAdmin || isOwner;

  // Selection limits
  int get maxSelectionCount => min(groupInfo.memberCount!, _GroupMemberConstants.maxSelectionCount);

  @override
  void onClose() {
    _memberInfoSubscription.cancel();
    _groupInfoSubscription.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    _initializeFromArguments();
    _setupSubscriptions();
    super.onInit();
  }

  /// Initialize controller with route arguments
  void _initializeFromArguments() {
    final arguments = Get.arguments as Map<String, dynamic>;
    groupInfo = arguments['groupInfo'] as GroupInfo;
    operationType = arguments['opType'] as GroupMemberOpType;
  }

  /// Setup event subscriptions
  void _setupSubscriptions() {
    _memberInfoSubscription = _imLogic.memberInfoChangedSubject.listen(_handleMemberInfoChanged);
    _groupInfoSubscription = _imLogic.groupInfoUpdatedSubject.listen(_handleGroupInfoUpdated);
  }

  @override
  void onReady() {
    _queryMyGroupMemberLevel();
    super.onReady();
  }

  /// Handle member info changes from stream
  void _handleMemberInfoChanged(GroupMembersInfo updatedMember) {
    if (updatedMember.groupID != groupInfo.groupID) return;

    // Update member in list if exists
    final existingMemberIndex = memberList.indexWhere((member) => member.userID == updatedMember.userID);

    if (existingMemberIndex != -1) {
      final existingMember = memberList[existingMemberIndex];
      if (updatedMember.roleLevel != existingMember.roleLevel) {
        existingMember.roleLevel = updatedMember.roleLevel;
        _sortMemberList();
      }
    }

    // Update my permission level if it's my info
    if (updatedMember.userID == OpenIM.iMManager.userID) {
      myGroupMemberLevel.value = updatedMember.roleLevel ?? _GroupMemberConstants.defaultMemberLevel;
    }
  }

  /// Handle group info updates from stream
  void _handleGroupInfoUpdated(GroupInfo updatedGroupInfo) {
    if (updatedGroupInfo.groupID == groupInfo.groupID) {
      groupInfo = updatedGroupInfo;
    }
  }

  /// Sort member list by role level and join time
  void _sortMemberList() {
    memberList.sort((a, b) {
      // Sort by role level first (higher roles first)
      if (b.roleLevel != a.roleLevel) {
        return b.roleLevel!.compareTo(a.roleLevel!);
      }
      // Then by join time (newer members first)
      return b.joinTime!.compareTo(a.joinTime!);
    });
  }

  /// Query and set current user's group member level
  void _queryMyGroupMemberLevel() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      try {
        // Process my member info
        final memberInfoList = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
          groupID: groupInfo.groupID,
          userIDList: [OpenIM.iMManager.userID],
        );
        final myInfo = memberInfoList.firstOrNull;
        if (myInfo != null) {
          myGroupMemberLevel.value = myInfo.roleLevel ?? _GroupMemberConstants.defaultMemberLevel;
        }

        // Process member list
        final newMembers = await _fetchGroupMembers();
        _processFetchedMembers(newMembers);
      } catch (e) {
        refreshController.loadFailed();
        IMViews.showToast('Failed to load member info: $e');
      }
    });
  }

  /// Process fetched members and update UI state
  void _processFetchedMembers(List<GroupMembersInfo> newMembers) {
    // Sort new members
    newMembers.sort((a, b) {
      if (b.roleLevel != a.roleLevel) {
        return b.roleLevel!.compareTo(a.roleLevel!);
      }
      return b.joinTime!.compareTo(a.joinTime!);
    });

    memberList.addAll(newMembers);

    // Update refresh controller state
    if (newMembers.length < _pageSize) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  /// Fetch group members with pagination
  Future<List<GroupMembersInfo>> _fetchGroupMembers() async {
    final members = await OpenIM.iMManager.groupManager.getGroupMemberList(
      groupID: groupInfo.groupID,
      count: _pageSize,
      offset: memberList.length,
    );

    // Filter members based on operation type and permissions
    final filteredMembers = _filterMembersForOperation(members);

    // Update page size for subsequent requests
    _pageSize = _GroupMemberConstants.normalPageSize;

    return filteredMembers;
  }

  /// Filter members based on current operation and user permissions
  List<GroupMembersInfo> _filterMembersForOperation(List<GroupMembersInfo> members) {
    if (!isDeletingMembers) return members;

    return members.where((member) {
      // Owner can delete everyone except other owners
      if (isOwner) {
        return member.roleLevel != GroupRoleLevel.owner;
      }
      // Admin can delete members but not admins or owners
      if (isAdmin) {
        return member.roleLevel != GroupRoleLevel.admin && member.roleLevel != GroupRoleLevel.owner;
      }
      // Regular members cannot delete anyone
      return false;
    }).toList();
  }

  /// Load members with pagination
  Future<void> _loadMembers() async {
    try {
      final newMembers = await _fetchGroupMembers();

      // Sort new members
      newMembers.sort((a, b) {
        if (b.roleLevel != a.roleLevel) {
          return b.roleLevel!.compareTo(a.roleLevel!);
        }
        return b.joinTime!.compareTo(a.joinTime!);
      });

      memberList.addAll(newMembers);

      // Update refresh controller state
      if (newMembers.length < _pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    } catch (e) {
      refreshController.loadFailed();
      IMViews.showToast('Failed to load members: $e');
    }
  }

  /// Check if member is selected
  bool isMemberSelected(GroupMembersInfo member) => selectedMembers.contains(member);

  /// Handle member click based on operation type
  Future<void> onMemberTap(GroupMembersInfo member) async {
    if (operationType == GroupMemberOpType.transferRight) {
      await _handleTransferGroupOwnership(member);
      return;
    }

    if (isMultiSelectionMode) {
      _toggleMemberSelection(member);
    } else {
      _viewMemberProfile(member);
    }
  }

  /// Toggle member selection in multi-selection mode
  void _toggleMemberSelection(GroupMembersInfo member) {
    if (isMemberSelected(member)) {
      selectedMembers.remove(member);
    } else if (selectedMembers.length < maxSelectionCount) {
      selectedMembers.add(member);
    } else {
      IMViews.showToast(sprintf(StrRes.maxSelectedItems, [maxSelectionCount]));
    }
  }

  /// Handle group ownership transfer
  Future<void> _handleTransferGroupOwnership(GroupMembersInfo member) async {
    final confirmed = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => CustomDialog(
        title: sprintf(StrRes.confirmTransferGroupToUser, [member.nickname]),
      ),
    );

    if (confirmed == true) {
      Get.back(result: member);
    }
  }

  /// Remove member from selection
  void removeSelectedMember(GroupMembersInfo member) {
    selectedMembers.remove(member);
  }

  /// View member profile if permitted
  void _viewMemberProfile(GroupMembersInfo member) {
    if (!canViewMemberInfo) {
      IMViews.showToast('No permission to view member info');
      return;
    }

    AppNavigator.startUserProfilePane(
      userID: member.userID!,
      groupID: member.groupID,
      nickname: member.nickname,
      faceURL: member.faceURL,
    );
  }

  /// Add new members to group
  Future<void> addMember() async {
    popupController.hideMenu();
    await _groupSetupLogic.addMember();
    await refreshData();
  }

  /// Refresh member list data
  Future<void> refreshData() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      memberList.clear();
      _pageSize = _GroupMemberConstants.initialPageSize;
      await _loadMembers();
    });
  }

  /// Delete selected members from group
  Future<void> deleteMember() async {
    popupController.hideMenu();
    await _groupSetupLogic.removeMember();
    await refreshData();
  }

  /// Search for group members
  Future<void> searchMembers() async {
    final memberInfo = await AppNavigator.startSearchGroupMember(
      groupInfo: groupInfo,
      opType: operationType,
    );

    if (memberInfo == null) return;

    if (operationType == GroupMemberOpType.transferRight) {
      Get.back(result: memberInfo);
    } else if (isMultiSelectionMode) {
      await onMemberTap(memberInfo);
    }
  }

  /// Create special member info for @everyone
  static GroupMembersInfo _createEveryoneMemberInfo() => GroupMembersInfo(
        userID: OpenIM.iMManager.conversationManager.atAllTag,
        nickname: StrRes.everyone,
      );

  /// Select everyone (@all) option
  void selectEveryone() {
    Get.back(result: <GroupMembersInfo>[_createEveryoneMemberInfo()]);
  }

  /// Confirm selected members and return result
  void confirmSelectedMembers() {
    Get.back(result: selectedMembers.toList());
  }

  /// Check if member should be hidden from list
  bool shouldHideMember(GroupMembersInfo member) => shouldExcludeSelf && member.userID == OpenIM.iMManager.userID;
}
