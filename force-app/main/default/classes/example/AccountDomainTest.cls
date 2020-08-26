@isTest
public with sharing class AccountDomainTest {
  @isTest
  public static void it_should_return_one_account() {
    String mockedMethodName = 'getOneAccount';

    //setup
    Account mockAccount = new Account(Name = 'Mock Account');
    UniversalMocker mock = UniversalMocker.mock(AccountDBService.class);
    mock.when(mockedMethodName).thenReturn(mockAccount);

    AccountDBService mockService = (AccountDBService) mock.createStub();
    AccountDomain acctDomainInstance = new AccountDomain(mockService);

    //test
    Test.startTest();
    Account accountDetail = acctDomainInstance.getAccountDetail();
    Test.stopTest();

    //verify
    system.assertEquals(mockAccount.Name, accountDetail.Name);
    mock.assertThat().method(mockedMethodName).wasCalled(1).timesExactly();
  }

  @isTest
  public static void it_should_create_a_public_account() {
    String mockedMethodName = 'doInsert';

    //setup
    UniversalMocker mock = UniversalMocker.mock(AccountDBService.class);
    AccountDBService mockService = (AccountDBService) mock.createStub();
    AccountDomain acctDomainInstance = new AccountDomain(mockService);

    //test
    Test.startTest();
    acctDomainInstance.createPublicAccount('Mock Account');
    Test.stopTest();

    //verify
    Account newAccount = (Account) mock.forMethod(mockedMethodName).andInvocationNumber(0).getValueOf('acct');
    system.assertEquals('Mock Account', newAccount.Name);
    system.assertEquals('Public', newAccount.Ownership);
  }

  @isTest
  public static void it_should_verify_call_counts_correctly() {
    String mockedMethodName = 'getOneAccount';
    Account mockAccount = new Account(Name = 'Mock Account');

    //setup
    UniversalMocker mock = UniversalMocker.mock(AccountDBService.class);
    mock.when(mockedMethodName).thenReturn(mockAccount);

    AccountDBService mockService = (AccountDBService) mock.createStub();
    AccountDomain acctDomainInstance = new AccountDomain(mockService);

    //test
    Test.startTest();
    Account accountDetail = acctDomainInstance.getAccountDetail();
    acctDomainInstance.getAccountDetail();
    Test.stopTest();

    //verify
    system.assertEquals(mockAccount.Name, accountDetail.Name);
    mock.assertThat().method(mockedMethodName).wasCalled(1).timesOrMore();
    mock.assertThat().method(mockedMethodName).wasCalled(2).timesOrMore();
    mock.assertThat().method(mockedMethodName).wasCalled(2).timesExactly();
    mock.assertThat().method(mockedMethodName).wasCalled(2).timesOrLess();
    mock.assertThat().method(mockedMethodName).wasCalled(3).timesOrLess();
  }

  @isTest
  public static void it_should_call_overloaded_methods_correctly() {
    String mockedMethodName = 'getMatchingAccounts';
    Account acctOne = new Account(Name = 'Account with matching Id');
    Account acctTwo = new Account(Name = 'Account with matching name');

    //setup
    UniversalMocker mock = UniversalMocker.mock(AccountDBService.class);
    mock.when(mockedMethodName).withParamTypes(new List<Type>{ Id.class }).thenReturn(new List<Account>{ acctOne });
    mock.when(mockedMethodName).withParamTypes(new List<Type>{ String.class }).thenReturn(new List<Account>{ acctTwo });

    AccountDBService mockService = (AccountDBService) mock.createStub();
    AccountDomain acctDomainInstance = new AccountDomain(mockService);

    //test
    Test.startTest();
    Id mockAccountId = '001000000000001';
    List<Account> acctsWithMatchingId = acctDomainInstance.getMatchingAccounts(mockAccountId);
    List<Account> acctsWithMatchingName = acctDomainInstance.getMatchingAccounts('Account with matching name');
    Test.stopTest();

    //verify
    mock.assertThat().method(mockedMethodName).withParamTypes(new List<Type>{ Id.class }).wasCalled(1).timesExactly();
    mock.assertThat().method(mockedMethodName).withParamTypes(new List<Type>{ String.class }).wasCalled(1).timesExactly();
    Id accountIdParam = (Id) mock.forMethod(mockedMethodName).andInvocationNumber(0).withParamTypes(new List<Type>{ Id.class }).getValueOf('accountId');
    String acctNameParam = (String) mock.forMethod(mockedMethodName)
      .andInvocationNumber(0)
      .withParamTypes(new List<Type>{ String.class })
      .getValueOf('accountName');

    System.assertEquals(mockAccountId, accountIdParam);
    System.assertEquals('Account with matching name', acctNameParam);
    System.assertEquals(acctOne.Name, acctsWithMatchingId[0].Name);
    System.assertEquals(acctTwo.Name, acctsWithMatchingName[0].Name);
  }
}