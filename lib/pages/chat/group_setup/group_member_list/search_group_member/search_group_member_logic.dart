import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/chat/group_setup/group_setup_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../../core/controller/im_controller.dart';
import '../../../../../routes/app_navigator.dart';
import '../group_member_list_logic.dart';

/// Constants for search functionality
class _SearchConstants {
  static const int pageSize = 100;
  static const int searchDelayMs = 300;
}

class SearchGroupMemberLogic extends GetxController {
  // Dependencies
  final _imLogic = Get.find<IMController>();
  
  // Controllers and UI components
  final refreshController = RefreshController();
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  
  // Observable data
  final searchResults = <GroupMembersInfo>[].obs;
  final isSearching = false.obs;
  
  // Configuration
  late GroupInfo groupInfo;
  late GroupMemberOpType operationType;
  
  // Subscriptions
  late StreamSubscription _memberInfoSubscription;
  
  // Search debounce timer
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    _initializeFromArguments();
    _setupSearchListener();
    _setupSubscriptions();
    super.onInit();
  }
  
  /// Initialize controller with route arguments
  void _initializeFromArguments() {
    final arguments = Get.arguments as Map<String, dynamic>;
    groupInfo = arguments['groupInfo'] as GroupInfo;
    operationType = arguments['opType'] as GroupMemberOpType;
  }
  
  /// Setup search input listener with debounce
  void _setupSearchListener() {
    searchController.addListener(_onSearchTextChanged);
  }
  
  /// Setup event subscriptions
  void _setupSubscriptions() {
    _memberInfoSubscription = _imLogic.memberInfoChangedSubject.listen(_handleMemberInfoChanged);
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchFocusNode.dispose();
    searchController.dispose();
    _memberInfoSubscription.cancel();
    super.onClose();
  }

  /// Check if search has no results
  bool get hasNoSearchResults =>
      searchController.text.trim().isNotEmpty && searchResults.isEmpty && !isSearching.value;
  
  /// Get current search keyword
  String get searchKeyword => searchController.text.trim();
  
  /// Handle search text changes with debounce
  void _onSearchTextChanged() {
    _searchDebounceTimer?.cancel();
    
    if (searchKeyword.isEmpty) {
      searchResults.clear();
      refreshController.resetNoData();
      return;
    }
    
    _searchDebounceTimer = Timer(
      Duration(milliseconds: _SearchConstants.searchDelayMs),
      () => performSearch(),
    );
  }
  
  /// Handle member info changes from stream
  void _handleMemberInfoChanged(GroupMembersInfo updatedMember) {
    if (updatedMember.groupID != groupInfo.groupID) return;
    
    final existingMemberIndex = searchResults.indexWhere(
      (member) => member.userID == updatedMember.userID
    );
    
    if (existingMemberIndex != -1) {
      final existingMember = searchResults[existingMemberIndex];
      if (updatedMember.roleLevel != existingMember.roleLevel) {
        existingMember.roleLevel = updatedMember.roleLevel;
        searchResults.refresh();
      }
    }
  }

  /// Search group members with given parameters
  Future<List<GroupMembersInfo>> _searchGroupMembers({
    required String keyword,
    required int offset,
  }) async {
    try {
      return await OpenIM.iMManager.groupManager.searchGroupMembers(
        groupID: groupInfo.groupID,
        isSearchMemberNickname: true,
        isSearchUserID: true,
        keywordList: [keyword],
        offset: offset,
        count: _SearchConstants.pageSize,
      );
    } catch (e) {
      IMViews.showToast('Search failed: $e');
      rethrow;
    }
  }

  /// Perform initial search
  Future<void> performSearch() async {
    if (searchKeyword.isEmpty) {
      searchResults.clear();
      return;
    }
    
    isSearching.value = true;
    
    try {
      final results = await _searchGroupMembers(
        keyword: searchKeyword,
        offset: 0,
      );
      
      searchResults.assignAll(results);
      
      // Update refresh controller state
      if (results.length < _SearchConstants.pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    } catch (e) {
      refreshController.loadFailed();
    } finally {
      isSearching.value = false;
    }
  }

  /// Load more search results (pagination)
  Future<void> loadMoreResults() async {
    if (searchKeyword.isEmpty) {
      refreshController.loadComplete();
      return;
    }

    try {
      final moreResults = await _searchGroupMembers(
        keyword: searchKeyword,
        offset: searchResults.length,
      );
      
      searchResults.addAll(moreResults);

      if (moreResults.length < _SearchConstants.pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    } catch (e) {
      refreshController.loadFailed();
    }
  }

  /// Check if member should be hidden based on operation type and permissions
  bool shouldHideMember(GroupMembersInfo member) {
    switch (operationType) {
      case GroupMemberOpType.transferRight:
      case GroupMemberOpType.at:
      case GroupMemberOpType.call:
        // Hide current user for these operations
        return member.userID == OpenIM.iMManager.userID;
        
      case GroupMemberOpType.del:
        return _shouldHideMemberForDeletion(member);
        
      case GroupMemberOpType.view:
      default:
        return false;
    }
  }
  
  /// Check if member should be hidden for deletion operation
  bool _shouldHideMemberForDeletion(GroupMembersInfo member) {
    try {
      final groupSetupLogic = Get.find<GroupSetupLogic>();
      
      // Admin cannot delete other admins or owners
      if (groupSetupLogic.isAdmin) {
        return member.roleLevel == GroupRoleLevel.admin || 
               member.roleLevel == GroupRoleLevel.owner;
      }
      
      // Owner cannot delete other owners
      if (groupSetupLogic.isOwner) {
        return member.roleLevel == GroupRoleLevel.owner;
      }
      
      // Regular members cannot delete anyone
      return true;
    } catch (e) {
      // If GroupSetupLogic is not found, hide all members for safety
      return true;
    }
  }

  /// Handle member selection based on operation type
  Future<void> onMemberTap(GroupMembersInfo member) async {
    switch (operationType) {
      case GroupMemberOpType.transferRight:
        await _handleTransferGroupOwnership(member);
        break;
        
      case GroupMemberOpType.at:
      case GroupMemberOpType.call:
      case GroupMemberOpType.del:
        Get.back(result: member);
        break;
        
      case GroupMemberOpType.view:
      default:
        _viewMemberProfile(member);
        break;
    }
  }

  /// Handle group ownership transfer confirmation
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

  /// View member profile
  void _viewMemberProfile(GroupMembersInfo member) {
    AppNavigator.startUserProfilePane(
      userID: member.userID!,
      groupID: member.groupID,
      nickname: member.nickname,
      faceURL: member.faceURL,
    );
  }
  
  /// Clear search results and reset state
  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    refreshController.resetNoData();
  }
  
  /// Focus on search input
  void focusSearch() {
    searchFocusNode.requestFocus();
  }
}

/// Compatibility extension for existing view code
extension SearchGroupMemberLogicCompat on SearchGroupMemberLogic {
  FocusNode get focusNode => searchFocusNode;
  TextEditingController get searchCtrl => searchController;
  RefreshController get controller => refreshController;
  RxList<GroupMembersInfo> get memberList => searchResults;
  bool get isSearchNotResult => hasNoSearchResults;
  
  Future<void> search() => performSearch();
  Future<void> load() => loadMoreResults();
  bool hiddenMembers(GroupMembersInfo member) => shouldHideMember(member);
  Future<void> clickMember(GroupMembersInfo member) => onMemberTap(member);
}
