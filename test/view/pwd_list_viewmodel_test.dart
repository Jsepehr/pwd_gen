/* import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pwd_gen/view/pwd_list_viewmodel.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';

import 'pwd_list_viewmodel_test.mocks.dart';

// Generate mocks using Mockito's annotations
@GenerateMocks([PwdRepository])
void main() {
  late PwdListViewModel viewModel;
  late MockPwdRepository mockRepository;

  setUp(() {
    // Initialize the mock repository and ViewModel
    mockRepository = MockPwdRepository();
    viewModel = PwdListViewModel();
  });

  test('loadPwds sorts the list in descending order of usageCount', () async {
    // Arrange: Prepare mock data
    final mockPwds = [
      PwdEntity(id: '1', hint: 'Hint 1', password: 'Pwd1', usageCount: 3),
      PwdEntity(id: '2', hint: 'Hint 2', password: 'Pwd2', usageCount: 5),
      PwdEntity(id: '3', hint: 'Hint 3', password: 'Pwd3', usageCount: 1),
    ];

    // Mock the repository to return the mock data
    when(mockRepository.getAllPwds()).thenAnswer((_) async => mockPwds);

    // Act: Call loadPwds
    await viewModel.loadPwds();

    // Assert: Verify the list is sorted in descending order
    expect(viewModel.pwdList[0].usageCount, 5); // Highest usageCount
    expect(viewModel.pwdList[1].usageCount, 3);
    expect(viewModel.pwdList[2].usageCount, 1); // Lowest usageCount
  });
}
 */