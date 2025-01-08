// Mocks generated by Mockito 5.4.4 from annotations
// in pwd_gen/test/view/pwd_list_viewmodel_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:pwd_gen/data/models/pwd_model.dart' as _i5;
import 'package:pwd_gen/domain/pwd_entity.dart' as _i4;
import 'package:pwd_gen/repository/pwd_repository.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [PwdRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockPwdRepository extends _i1.Mock implements _i2.PwdRepository {
  MockPwdRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> addPwd(_i4.PwdEntity? pwd) => (super.noSuchMethod(
        Invocation.method(
          #addPwd,
          [pwd],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<int> updatePwd(
    _i5.PwdModel? updatedPwd,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePwd,
          [
            updatedPwd,
          ],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);

  @override
  _i3.Future<List<_i4.PwdEntity>> getAllPwds() => (super.noSuchMethod(
        Invocation.method(
          #getAllPwds,
          [],
        ),
        returnValue: _i3.Future<List<_i4.PwdEntity>>.value(<_i4.PwdEntity>[]),
      ) as _i3.Future<List<_i4.PwdEntity>>);

  @override
  _i3.Future<void> deletePwd(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deletePwd,
          [id],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
