class AppStrings {
  static late String addAHintForEachPassword;
  static late String apply;
  static late String cancel;
  static late String confirm;
  static late String corruptedFile;
  static late String editPasswordsAndHints;
  static late String everythingStaysOnYourDevice;
  static late String exportToDownloads;
  static late String fileStoredOk;
  static late String generate;
  static late String imageNotSelected;
  static late String import;
  static late String importYourListAnytime;
  static late String keepYourDigitalLifeSecureWithoutCompromises;
  static late String kmgNotSelected;
  static late String localAndPrivateByDesign;
  static late String manageAndExportYourVault;
  static late String next;
  static late String noDataCollection;
  static late String noInternetAccess;
  static late String ok;
  static late String permissionNotGranted;
  static late String readyToBegin;
  static late String resetAllPwds;
  static late String search;
  static late String secretImage;
  static late String secretPhrase;
  static late String securePrivateSmart;
  static late String selectSecretImageDecrypt;
  static late String selectSecretImageEncrypt;
  static late String smartPasswordGeneration;
  static late String somethingWentWrong;
  static late String start;
  static late String useAPhotoAndKeywordToGenerateStrongPasswords;
  static late String welcomeToMyPasswordGenerator;
  static late String wrongImage;
  static late String wrongSelectedFileFormat;
  static late String yourOfflinePasswordGeneratorAndManager;
  static late String hint;

  static fromJson(Map<String, dynamic> json) {
    welcomeToMyPasswordGenerator =
        json['welcome_to_my_password_generator'] ?? '';
    securePrivateSmart = json['secure_private_smart'] ?? '';
    yourOfflinePasswordGeneratorAndManager =
        json['your_offline_password_generator_and_manager'] ?? '';
    localAndPrivateByDesign = json['local_and_private_by_design'] ?? '';
    noInternetAccess = json['no_internet_access'] ?? '';
    noDataCollection = json['no_data_collection'] ?? '';
    everythingStaysOnYourDevice = json['everything_stays_on_your_device'] ?? '';
    smartPasswordGeneration = json['smart_password_generation'] ?? '';
    useAPhotoAndKeywordToGenerateStrongPasswords =
        json['use_a_photo_and_keyword_to_generate_strong_passwords'] ?? '';
    addAHintForEachPassword = json['add_a_hint_for_each_password'] ?? '';
    manageAndExportYourVault = json['manage_and_export_your_vault'] ?? '';
    editPasswordsAndHints = json['edit_passwords_and_hints'] ?? '';
    exportToDownloads = json['export_to_downloads'] ?? '';
    importYourListAnytime = json['import_your_list_anytime'] ?? '';
    readyToBegin = json['ready_to_begin'] ?? '';
    keepYourDigitalLifeSecureWithoutCompromises =
        json['keep_your_digital_life_secure_without_compromises'] ?? '';
    fileStoredOk = json['file_stored_ok'] ?? '';
    imageNotSelected = json['image_not_selected'] ?? '';
    kmgNotSelected = json['kmg_not_selected'] ?? '';
    wrongImage = json['wrong_image'] ?? '';
    wrongSelectedFileFormat = json['wrong_selected_file_format'] ?? '';
    somethingWentWrong = json['something_went_wrong'] ?? '';
    resetAllPwds = json['reset_all_pwds'] ?? '';
    corruptedFile = json['corrupted_file'] ?? '';
    permissionNotGranted = json['permission_not_granted'] ?? '';
    selectSecretImageDecrypt = json['select_secret_image_decrypt'] ?? '';
    selectSecretImageEncrypt = json['select_secret_image_encrypt'] ?? '';
    import = json['import'] ?? '';
    generate = json['generate'] ?? '';
    ok = json['ok'] ?? '';
    search = json['search'] ?? '';
    start = json['start'] ?? '';
    next = json['next'] ?? '';
    secretPhrase = json['secret_phrase'] ?? '';
    secretImage = json['secret_image'] ?? '';
    apply = json['apply'] ?? '';
    cancel = json['cancel'] ?? '';
    confirm = json['confirm'] ?? '';
    hint = json['hint'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'welcome_to_my_password_generator': welcomeToMyPasswordGenerator,
      'secure_private_smart': securePrivateSmart,
      'your_offline_password_generator_and_manager':
          yourOfflinePasswordGeneratorAndManager,
      'local_and_private_by_design': localAndPrivateByDesign,
      'no_internet_access': noInternetAccess,
      'no_data_collection': noDataCollection,
      'everything_stays_on_your_device': everythingStaysOnYourDevice,
      'smart_password_generation': smartPasswordGeneration,
      'use_a_photo_and_keyword_to_generate_strong_passwords':
          useAPhotoAndKeywordToGenerateStrongPasswords,
      'add_a_hint_for_each_password': addAHintForEachPassword,
      'manage_and_export_your_vault': manageAndExportYourVault,
      'edit_passwords_and_hints': editPasswordsAndHints,
      'export_to_downloads': exportToDownloads,
      'import_your_list_anytime': importYourListAnytime,
      'ready_to_begin': readyToBegin,
      'keep_your_digital_life_secure_without_compromises':
          keepYourDigitalLifeSecureWithoutCompromises,
      'file_stored_ok': fileStoredOk,
      'image_not_selected': imageNotSelected,
      'kmg_not_selected': kmgNotSelected,
      'wrong_image': wrongImage,
      'wrong_selected_file_format': wrongSelectedFileFormat,
      'something_went_wrong': somethingWentWrong,
      'reset_all_pwds': resetAllPwds,
      'corrupted_file': corruptedFile,
      'permission_not_granted': permissionNotGranted,
      'select_secret_image_decrypt': selectSecretImageDecrypt,
      'select_secret_image_encrypt': selectSecretImageEncrypt,
      'import': import,
      'generate': generate,
      'ok': ok,
      'search': search,
      'start': start,
      'next': next,
      'secret_phrase': secretPhrase,
      'secret_image': secretImage,
      'apply': apply,
      'cancel': cancel,
      'confirm': confirm,
      'hint': hint,
    };
  }
}
