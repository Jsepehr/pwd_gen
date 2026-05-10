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
  static late String yes;
  static late String no;
  static late String doYouWantToShareTheReminder;
  static late String hint;
  static late String pinMismatch;
  static late String imageMismatch;
  static late String noSavedImage;
  static late String helpForCreateNewPassword;
  static late String loginWithImage;


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
    yes = json['yes'] ?? '';
    no = json['no'] ?? '';
    doYouWantToShareTheReminder =
        json['do_you_want_to_share_the_reminder'] ?? '';
    pinMismatch = json['pin_mismatch'] ?? '';
    imageMismatch = json['image_mismatch'] ?? '';
    noSavedImage = json['no_saved_image'] ?? '';
    helpForCreateNewPassword = json['help_for_create_new_password'] ?? '';
    loginWithImage = json['login_with_image'] ?? '';
  }
}
