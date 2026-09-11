class AppTranslation {
  static Map<String, Map<String, String>> translations = {
    'EN_US': Locales.EN_US,
    'KM_KH': Locales.KM_KH,
  };
}

class LocaleKeys {
  LocaleKeys._();
  static const unableToConnectToTheInternet = 'unableToConnectToTheInternet';
  static const cancelled = 'cancelled';
  static const yourRequestHasBeenCancelled = 'yourRequestHasBeenCancelled';
  static const connectionTimeout = 'connectionTimeout';
  static const yourConnectionIsTimeout = 'yourConnectionIsTimeout';
  static const recieveTimeout = 'recieveTimeout';
  static const yourRecievingDataIsTimeout = 'yourRecievingDataIsTimeout';
  static const somethingWentWrong = 'somethingWentWrong';
  static const notFound = 'notFound';
  static const yourRequestedUrlWasNotFound = 'yourRequestedUrlWasNotFound';
  static const areYouSureYourWantToLogout = 'areYouSureYourWantToLogout';
  static const areYouSureYourWantToDelete = 'areYouSureYourWantToDelete';
  static const youHaveSuccessfullyCreated = 'youHaveSuccessfullyCreated';
  static const unableToPickImagePleaseTryAgain =
      'unableToPickImagePleaseTryAgain';
  static const studentprofileinformation = "studentProfileInformation";
  static const studentprofileinformationSub = "studentProfileInformationSub";
  static const successfully = 'successfully';
  static const youHavesuccessfullyCreatedTheBooking =
      'youHavesuccessfullyCreatedTheBooking';
  static const forgotPassword = 'forgotPassword';
  static const password = 'password';
  static const cannotBeEmpty = 'cannotBeEmpty';
  static const invalidPhoneNumber = 'invalidPhoneNumber';
  static const loginWithUsernameEmail = 'loginWithUsernameEmail';
  static const email = 'email';
  static const loginWithPhoneNumber = 'loginWithPhoneNumber';
  static const invalidEmail = 'invalidEmail';
  static const passwordDoNotMatch = 'passwordDoNotMatch';
  static const newPassword = 'newPassword';
  static const loginFailed = 'loginFailed';
  static const loginFailedMessage = 'loginFailedMessage';
  static const noResponseFromServer = 'noResponseFromServer';
  static const invalidCredentials = 'invalidCredentials';
  static const invalidServerResponse = 'invalidServerResponse';
  static const tokenMissing = 'tokenMissing';
  static const selectedRoleIs = 'selectedRoleIs';
  static const pleaseSwitchRoleAndTryAgain = 'pleaseSwitchRoleAndTryAgain';
  static const pleaseEnterValidPhoneNumber = 'pleaseEnterValidPhoneNumber';
  static const somethingWentWrongTryAgain = 'somethingWentWrongTryAgain';
  static const dashboard = 'dashboard';
  static const attendanceRecordTitle = 'attendanceRecordTitle';
  static const attendanceRecordSubTitle = 'attendanceRecordSubTitle';
  static const leavesTitle = 'leavesTitle';
  static const leavesSubTitle = 'leavesSubTitle';
  static const leavesTeacherSubTitle = 'leavesTeacherSubTitle';
  static const studentAttendanceTitle = 'studentAttendanceTitle';
  static const studentAttendanceSubTitle = 'studentAttendanceSubTitle';
  static const studentAttendanceTeacherSubTitle =
      'studentAttendanceTeacherSubTitle';
  static const noAttendanceLogsFound = 'noAttendanceLogsFound';
  static const noStaffAttendanceLogsFound = 'noStaffAttendanceLogsFound';
  static const morningIn = 'morningIn';
  static const morningOut = 'morningOut';
  static const afternoonIn = 'afternoonIn';
  static const afternoonOut = 'afternoonOut';
  static const scanQrCodeToLogAttendance = 'scanQrCodeToLogAttendance';
  static const scheduleTitle = 'scheduleTitle';
  static const scheduleSubTitle = 'scheduleSubTitle';
  static const scheduleStudentRequired = 'scheduleStudentRequired';
  static const invalidResponseData = 'invalidResponseData';
  static const failedToLoadSchedule = 'failedToLoadSchedule';
  static const studentNameLabel = 'studentNameLabel';
  static const classLabel = 'classLabel';
  static const dateLabel = 'dateLabel';
  static const sectionLabel = 'sectionLabel';
  static const subjectLabel = 'subjectLabel';
  static const noClass = 'noClass';
  static const sessionNumber = 'sessionNumber';
  static const teacherLabel = 'teacherLabel';
  static const taLabel = 'taLabel';
  static const timeLabel = 'timeLabel';
  static const noticesLabel = 'noticesLabel';
  static const roomLabel = 'roomLabel';
  static const mondayShort = 'mondayShort';
  static const tuesdayShort = 'tuesdayShort';
  static const wednesdayShort = 'wednesdayShort';
  static const thursdayShort = 'thursdayShort';
  static const fridayShort = 'fridayShort';
  static const saturdayShort = 'saturdayShort';
  static const sundayShort = 'sundayShort';
  static const requestLeaveTitle = 'requestLeaveTitle';
  static const requestLeaveSubTitle = 'requestLeaveSubTitle';
  static const requestLeaveSelectStudent = 'requestLeaveSelectStudent';
  static const requestLeaveFillInfo = 'requestLeaveFillInfo';
  static const student = 'student';
  static const studentId = 'studentId';
  static const teacherId = 'teacherId';
  static const studentName = 'studentName';
  static const teacherName = 'teacherName';
  static const role = 'role';
  static const profession = 'profession';
  static const dob = 'dob';
  static const pob = 'pob';
  static const sex = 'sex';
  static const classSection = 'classSection';
  static const parentTeacher = 'parentTeacher';
  static const noTeacherInformationFound = 'noTeacherInformationFound';
  static const noStudentInformationFound = 'noStudentInformationFound';
  static const noParentInformationFound = 'noParentInformationFound';
  static const teacherProfile = 'teacherProfile';
  static const studentProfile = 'studentProfile';
  static const parentProfile = 'parentProfile';
  static const selectedChild = 'selectedChild';
  static const tapToSwitchChild = 'tapToSwitchChild';
  static const shift = 'shift';
  static const totalLeaveDays = 'totalLeaveDays';
  static const leaveFromDate = 'leaveFromDate';
  static const leaveToDate = 'leaveToDate';
  static const leaveReason = 'leaveReason';
  static const otherReasonHint = 'otherReasonHint';
  static const otherReasonLabel = 'otherReasonLabel';
  static const leaveRequestReviewNote = 'leaveRequestReviewNote';
  static const studentIdCopied = 'studentIdCopied';
  static const sick = 'sick';
  static const busy = 'busy';
  static const all = 'all';
  static const rejected = 'rejected';
  static const dashboardMenuTuitionFee = 'dashboardMenuTuitionFee';
  static const dashboardMenuAttendance = 'dashboardMenuAttendance';
  static const dashboardMenuRequestLeave = 'dashboardMenuRequestLeave';
  static const dashboardMenuSchedule = 'dashboardMenuSchedule';
  static const dashboardMenuStandings = 'dashboardMenuStandings';
  static const dashboardMenuAttendanceLog = 'dashboardMenuAttendanceLog';
  static const dashboardMenuAttendanceLogTeacher =
      'dashboardMenuAttendanceLogTeacher';
  static const dashboardMenuStudentReport = 'dashboardMenuStudentReport';
  static const dashboardMenuClassActivity = 'dashboardMenuClassActivity';
  static const dashboardMenuOnlineCourse = 'dashboardMenuOnlineCourse';
  static const dashboardMenuLeaves = 'dashboardMenuLeaves';
  static const dashboardMenuStudentAttendance =
      'dashboardMenuStudentAttendance';
  static const dashboardMenuExamination = 'dashboardMenuExamination';
  static const scoreEntryTitle = 'scoreEntryTitle';
  static const scoreEntrySubTitle = 'scoreEntrySubTitle';
  static const scoreEntryTeacherSubTitle = 'scoreEntryTeacherSubTitle';
  static const scoreEntryLevel = 'scoreEntryLevel';
  static const scoreEntryResultType = 'scoreEntryResultType';
  static const scoreEntryMonth = 'scoreEntryMonth';
  static const scoreEntryQuarter = 'scoreEntryQuarter';
  static const scoreEntrySelectResultTypeFirst =
      'scoreEntrySelectResultTypeFirst';
  static const scoreEntrySelectFiltersHint = 'scoreEntrySelectFiltersHint';
  static const scoreEntryNoStudentsFound = 'scoreEntryNoStudentsFound';
  static const scoreEntryNoSubjects = 'scoreEntryNoSubjects';
  static const scoreEntrySave = 'scoreEntrySave';
  static const assessmentManagementTitle = 'assessmentManagementTitle';
  static const assessmentManagementSubTitle = 'assessmentManagementSubTitle';
  static const assessmentManagementSemester = 'assessmentManagementSemester';
  static const assessmentManagementTeacherComment =
      'assessmentManagementTeacherComment';
  static const examinationProgramTitle = 'examinationProgramTitle';
  static const examinationProgramChineseEnglish =
      'examinationProgramChineseEnglish';
  static const examinationProgramChineseEnglishSubtitle =
      'examinationProgramChineseEnglishSubtitle';
  static const examinationProgramKhmer = 'examinationProgramKhmer';
  static const examinationProgramKhmerSubtitle =
      'examinationProgramKhmerSubtitle';
  static const examinationProgramScoreVerification =
      'examinationProgramScoreVerification';
  static const examinationProgramScoreVerificationSubtitle =
      'examinationProgramScoreVerificationSubtitle';
  static const scoreVerificationTitle = 'scoreVerificationTitle';
  static const scoreVerificationSubTitle = 'scoreVerificationSubTitle';
  static const scoreVerificationPendingExam = 'scoreVerificationPendingExam';
  static const scoreVerificationPendingExamDesc =
      'scoreVerificationPendingExamDesc';
  static const scoreVerificationPendingQuarter =
      'scoreVerificationPendingQuarter';
  static const scoreVerificationPendingQuarterDesc =
      'scoreVerificationPendingQuarterDesc';
  static const scoreVerificationPendingAssessment =
      'scoreVerificationPendingAssessment';
  static const scoreVerificationPendingAssessmentDesc =
      'scoreVerificationPendingAssessmentDesc';
  static const scoreVerificationNothingPending =
      'scoreVerificationNothingPending';
  static const scoreVerificationExam = 'scoreVerificationExam';
  static const scoreVerificationSession = 'scoreVerificationSession';
  static const scoreVerificationStudents = 'scoreVerificationStudents';
  static const scoreVerificationSubmitted = 'scoreVerificationSubmitted';
  static const scoreVerificationView = 'scoreVerificationView';
  static const scoreVerificationVerify = 'scoreVerificationVerify';
  static const scoreVerificationVerifyAll = 'scoreVerificationVerifyAll';
  static const examinationProgramWeightedResult =
      'examinationProgramWeightedResult';
  static const examinationProgramWeightedResultSubtitle =
      'examinationProgramWeightedResultSubtitle';
  static const weightedResultTitle = 'weightedResultTitle';
  static const weightedResultSubTitle = 'weightedResultSubTitle';
  static const weightedResultWeightsLabel = 'weightedResultWeightsLabel';
  static const weightedResultAdmissionNo = 'weightedResultAdmissionNo';
  static const weightedResultStudent = 'weightedResultStudent';
  static const weightedResultWeightedPercent =
      'weightedResultWeightedPercent';
  static const weightedResultGrade = 'weightedResultGrade';
  static const weightedResultGpa = 'weightedResultGpa';
  static const weightedResultResult = 'weightedResultResult';
  static const weightedResultNoStudentsFound =
      'weightedResultNoStudentsFound';
  static const weightedResultSelectFiltersHint =
      'weightedResultSelectFiltersHint';
  static const weightedResultCriterionHomework =
      'weightedResultCriterionHomework';
  static const weightedResultCriterionCommunication =
      'weightedResultCriterionCommunication';
  static const weightedResultCriterionClasswork =
      'weightedResultCriterionClasswork';
  static const weightedResultCriterionReflection =
      'weightedResultCriterionReflection';
  static const weightedResultCriterionBeRespectful =
      'weightedResultCriterionBeRespectful';
  static const weightedResultCriterionStudentsAttention =
      'weightedResultCriterionStudentsAttention';
  static const weightedResultCriterionTaskResponsibility =
      'weightedResultCriterionTaskResponsibility';
  static const weightedResultCriterionWorkIndependently =
      'weightedResultCriterionWorkIndependently';
  static const weightedResultCriterionStudentsPunctually =
      'weightedResultCriterionStudentsPunctually';
  static const weightedResultCriterionMorality =
      'weightedResultCriterionMorality';
  static const examinationProgramViewScore = 'examinationProgramViewScore';
  static const examinationProgramViewScoreSubtitle =
      'examinationProgramViewScoreSubtitle';
  static const viewScoreTitle = 'viewScoreTitle';
  static const viewScoreSubTitle = 'viewScoreSubTitle';
  static const viewScoreGender = 'viewScoreGender';
  static const viewScoreNoStudentsFound = 'viewScoreNoStudentsFound';
  static const viewScoreSelectFiltersHint = 'viewScoreSelectFiltersHint';
  static const recordAttendanceSearchHint = 'recordAttendanceSearchHint';
  static const recordAttendanceSelectAllPresent =
      'recordAttendanceSelectAllPresent';
  static const recordAttendanceNoStudentsFound =
      'recordAttendanceNoStudentsFound';
  static const recordAttendanceNoColumn = 'recordAttendanceNoColumn';
  static const recordAttendanceGender = 'recordAttendanceGender';
  static const recordAttendanceNote = 'recordAttendanceNote';
  static const recordAttendanceEnterNoteHint =
      'recordAttendanceEnterNoteHint';
  static const recordAttendanceSave = 'recordAttendanceSave';
  static const recordAttendanceSubmit = 'recordAttendanceSubmit';
  static const studentAttendanceNoRecordsFound =
      'studentAttendanceNoRecordsFound';
  static const welcomeParentPrefix = 'welcomeParentPrefix';
  static const welcomeTeacherPrefix = 'welcomeTeacherPrefix';
  static const welcomeParentSubtitle = 'welcomeParentSubtitle';
  static const welcomeTeacherSubtitle = 'welcomeTeacherSubtitle';
  static const activity = 'activity';
  static const activitySubTitle = 'activitySubTitle';

  static const payments = 'payments';
  static const scanner = 'scanner';
  static const delivery = 'delivery';
  static const deliveries = 'deliveries';
  static const more = 'more';
  static const totalPackage = 'totalPackage';
  static const deliveryTransfer = 'deliveryTransfer';
  static const chooseANewDelivery = 'chooseANewDelivery';
  static const language = 'language';
  static const logout = 'logout';
  static const settings = 'settings';
  static const changePassword = 'changePassword';
  static const photoLibrary = 'photoLibrary';
  static const camera = 'camera';
  static const currentPassword = 'currentPassword';
  static const reEnterPassword = 'reEnterPassword';
  static const fromDate = 'fromDate';
  static const toDate = 'toDate';
  static const applyDate = 'applyDate';
  static const approvedBy = 'approvedBy';
  static const filterDate = 'filterDate';
  static const termAndCondition = 'termAndCondition';
  static const contactUs = 'contactUs';
  static const address = 'address';
  static const openInGoogleMap = 'openInGoogleMap';
  static const openMap = 'openMap';
  static const callNow = 'callNow';
  static const contact = 'contact';
  static const noPackage = 'noPackage';
  static const totalAmount = 'totalAmount';
  static const deliveriesC = 'deliveriesC';
  static const transfers = 'transfers';
  static const thisTransactionSuccess = 'thisTransactionSuccess';
  static const transaction = 'transaction';
  static const deliveryName = 'deliveryName';
  static const amount = 'amount';
  static const date = 'date';
  static const checkedBy = 'checkedBy';
  static const packages = 'packages';
  static const extraAmountAndTaxi = 'extraAmountAndTaxi';
  static const numberOfDelivery = 'numberOfDelivery';
  static const commissionFee = 'commissionFee';
  static const location = 'location';
  static const phoneNumber = 'phoneNumber';
  static const changeStatus = 'changeStatus';
  static const dateComplete = 'dateComplete';
  static const transferTo = 'transferTo';
  static const version = 'version';
  static const noData = 'noData';
  static const noPaymentHistoryFound = 'noPaymentHistoryFound';
  static const deliveryScanHasBeenCompleted = 'deliveryScanHasBeenCompleted';
  static const driverGetProduct = 'driverGetProduct';
  static const product = 'product';
  static const error = 'error';
  static const invalidQRCodeOrBarCode = 'invalidQRCodeOrBarCode';
  static const paymentAdd = 'paymentAdd';
  static const deliveryFee = 'deliveryFee';
  static const booking = 'booking';
  static const createBooking = 'createBooking';
  static const zone = 'zone';
  static const destinationPhone = 'destinationPhone';
  static const enterDestinationPhone = 'enterDestinationPhone';
  static const destination = 'destination';
  static const bookingDate = 'bookingDate';
  static const bookingDetails = 'bookingDetails';
  static const typeOfService = 'typeOfService';
  static const typeOfCoc = 'typeOfCoc';
  static const anyExtra = 'anyExtra';
  static const extraAmount = 'extraAmount';
  static const anyExtraType = 'anyExtraType';
  static const serviceFee = 'serviceFee';
  static const confirmation = 'confirmation';
  static const areYouSureYouWantToDeleteThisBooking =
      'areYouSureYouWantToDeleteThisBooking';
  static const thanksYou = 'thanksYou';
  static const yourBookingHasBeenAdded = 'yourBookingHasBeenAdded';
  static const yourBookingHasBeenUpdated = 'yourBookingHasBeenUpdated';
  static const updateBooking = 'updateBooking';
  static const description = 'description';
  static const enterDescription = 'enterDescription';
  static const destinationZone = 'destinationZone';
  static const chooseDestinationZone = 'chooseDestinationZone';
  static const image = 'image';
  static const typeOfCO = 'typeOfCO';
  static const anyExtraServiceCharge = 'anyExtraServiceCharge';
  static const yes = 'yes';
  static const no = 'no';
  static const taxi = 'taxi';
  static const other = 'other';
  static const normal = 'normal';
  static const express = 'express';
  static const bookingStatus = 'bookingStatus';
  static const receiverPhoneNumber = 'receiverPhoneNumber';
  static const deliverySuccess = 'deliverySuccess';
  static const filterByStatus = 'filterByStatus';
  static const filterByDate = 'filterByDate';
  static const progress = 'progress';
  static const complete = 'complete';
  static const inStock = 'inStock';
  static const filter = 'filter';
  static const doNotHaveAnAccount = 'doNotHaveAnAccount';
  static const register = 'register';
  static const yourNameOrShopName = 'yourNameOrShopName';
  static const confirmPassword = 'confirmPassword';
  static const registerSuccessful = 'registerSuccessful';
  static const registerUnavailable = 'registerUnavailable';
  static const deliveryInprogress = 'deliveryInprogress';
  static const paymentReceipt = 'paymentReceipt';
  static const paymentReport = 'paymentReport';
  static const startDate = 'startDate';
  static const endDate = 'endDate';
  static const reason = 'reason';
  static const profile = 'profile';
  static const totalIncome = 'totalIncome';
  static const area = 'area';
  static const getDate = 'getDate';
  static const releaseDate = 'releaseDate';
  static const customer = 'customer';
  static const bonus = 'bonus';
  static const total = 'total';
  static const moneyAtStaff = 'moneyAtStaff';
  static const moneyAtCompany = 'moneyAtCompany';
  static const moneyAtSell = 'moneyAtSell';
  static const payment = 'payment';
  static const totalDelivery = 'totalDelivery';
  static const extraMoneyAndCarFee = 'extraMoneyAndCarFee';
  static const searchDelivery = 'searchDelivery';
  static const deliveryActivity = 'deliveryActivity';
  static const inprogress = 'inprogress';
  static const finish = 'finish';
  static const codFee = 'codFee';
  static const returned = 'returned';
  static const choose = 'choose';
  static const detailOfPayments = 'detailOfPayments';
  static const qrCode = 'qrCode';
  static const enterProductCode = 'enterProductCode';
  static const getProduct = 'getProduct';
  static const finishDelivery = 'finishDelivery';
  static const exchangeRateToday = 'exchangeRateToday';
  static const customerReject = 'customerReject';
  static const viewDetails = 'viewDetails';
  static const clear = 'clear';
  static const notification = 'notification';
  static const successulGetProduct = 'successulGetProduct';
  static const successfulFinishDelivery = 'successfulFinishDelivery';
  static const paymentMethods = 'paymentMethods';
  static const dateVerity = 'dateVerity';
  static const status = 'status';
  static const packagesBooking = 'packagesBooking';
  static const sampleBooking = 'sampleBooking';
  static const createdDate = 'createdDate';
  static const enterDestination = 'enterDestination';
  static const chooseDate = 'chooseDate';
  static const uploadImage = 'uploadImage';
  static const numberOfPackages = 'numberOfPackages';
  static const enterNumberOfPackages = 'enterNumberOfPackages';
  static const totalShipping = 'totalShipping';
  static const fee = 'fee';
  static const avialableCredit = 'avialableCredit';
  static const enterLocation = 'enterLocation';
  static const bank = 'bank';
  static const attendance = 'attendance';
  static const attendanceSubTitle = 'attendanceSubTitle';
  static const attendanceTeacherSubTitle = 'attendanceTeacherSubTitle';
  static const attendanceRecordTeacherSubTitle =
      'attendanceRecordTeacherSubTitle';
  static const scheduleTeacherSubTitle = 'scheduleTeacherSubTitle';
  static const requestLeaveTeacherSubTitle = 'requestLeaveTeacherSubTitle';
  static const allRequestedLeaveTeacherSubTitle =
      'allRequestedLeaveTeacherSubTitle';
  static const activityTeacherSubTitle = 'activityTeacherSubTitle';
  static const onlineCoursesTeacherSubTitle = 'onlineCoursesTeacherSubTitle';
  static const onlineClassTitle = 'onlineClassTitle';
  static const onlineClassParentSubtitle = 'onlineClassParentSubtitle';
  static const onlineClassTeacherSubtitle = 'onlineClassTeacherSubtitle';
  static const onlineClassTeacherWorkbench = 'onlineClassTeacherWorkbench';
  static const onlineClassTeacherWorkbenchSubtitle =
      'onlineClassTeacherWorkbenchSubtitle';
  static const onlineClassParentOverview = 'onlineClassParentOverview';
  static const onlineClassParentOverviewSubtitle =
      'onlineClassParentOverviewSubtitle';
  static const onlineClassSubmissions = 'onlineClassSubmissions';
  static const onlineClassTotalClass = 'onlineClassTotalClass';
  static const onlineClassStudents = 'onlineClassStudents';
  static const onlineClassDueToday = 'onlineClassDueToday';
  static const onlineClassActivities = 'onlineClassActivities';
  static const onlineClassTeachingTools = 'onlineClassTeachingTools';
  static const onlineClassQuickActions = 'onlineClassQuickActions';
  static const onlineClassSubmissionReview = 'onlineClassSubmissionReview';
  static const onlineClassLatestUpdates = 'onlineClassLatestUpdates';
  static const onlineClassStudentSubmissionReview =
      'onlineClassStudentSubmissionReview';
  static const onlineClassHomeworkFilesWaiting =
      'onlineClassHomeworkFilesWaiting';
  static const onlineClassHomeworkDeadlineSetting =
      'onlineClassHomeworkDeadlineSetting';
  static const onlineClassSetDueDate = 'onlineClassSetDueDate';
  static const onlineClassReceiveNotifications =
      'onlineClassReceiveNotifications';
  static const onlineClassNewAnnouncement = 'onlineClassNewAnnouncement';
  static const onlineClassUploadHomeworkSubmission =
      'onlineClassUploadHomeworkSubmission';
  static const onlineClassReadyToUpload = 'onlineClassReadyToUpload';
  static const onlineClassHomeworkStatus = 'onlineClassHomeworkStatus';
  static const onlineClassHomeworkDone = 'onlineClassHomeworkDone';
  static const onlineClassHomeworkNeedsSubmission =
      'onlineClassHomeworkNeedsSubmission';
  static const onlineClassActionClassActivity =
      'onlineClassActionClassActivity';
  static const onlineClassActionClassDetail = 'onlineClassActionClassDetail';
  static const onlineClassActionViewClassInfo =
      'onlineClassActionViewClassInfo';
  static const onlineClassActionPostUpdate = 'onlineClassActionPostUpdate';
  static const onlineClassActionAssignHomework =
      'onlineClassActionAssignHomework';
  static const onlineClassActionAllAssignHomework =
      'onlineClassActionAllAssignHomework';
  static const onlineClassActionCreateTask = 'onlineClassActionCreateTask';
  static const onlineClassActionNotifyClass = 'onlineClassActionNotifyClass';
  static const onlineClassActionSendMessage = 'onlineClassActionSendMessage';
  static const onlineClassActionAllSubmit = 'onlineClassActionAllSubmit';
  static const onlineClassActionReviewSubmissions =
      'onlineClassActionReviewSubmissions';
  static const onlineClassActionUploadFiles = 'onlineClassActionUploadFiles';
  static const onlineClassActionAddMaterials = 'onlineClassActionAddMaterials';
  static const onlineClassActionActivities = 'onlineClassActionActivities';
  static const onlineClassActionClassMoments = 'onlineClassActionClassMoments';
  static const onlineClassActionHomework = 'onlineClassActionHomework';
  static const onlineClassActionViewTasks = 'onlineClassActionViewTasks';
  static const onlineClassActionComplete = 'onlineClassActionComplete';
  static const onlineClassActionDoHomework = 'onlineClassActionDoHomework';
  static const onlineClassActionSubmit = 'onlineClassActionSubmit';
  static const onlineClassActionUploadWork = 'onlineClassActionUploadWork';
  static const onlineClassActionNotifications =
      'onlineClassActionNotifications';
  static const onlineClassActionMessages = 'onlineClassActionMessages';
  static const onlineClassSelectClass = 'onlineClassSelectClass';
  static const onlineClassLoadingClassList = 'onlineClassLoadingClassList';
  static const onlineClassNoClassAvailable = 'onlineClassNoClassAvailable';
  static const onlineClassNoClassAvailableYet =
      'onlineClassNoClassAvailableYet';
  static const onlineClassPleaseSelectClass = 'onlineClassPleaseSelectClass';
  static const onlineClassMissingClassId = 'onlineClassMissingClassId';
  static const onlineClassStudentList = 'onlineClassStudentList';
  static const onlineClassHomeworkTitle = 'onlineClassHomeworkTitle';
  static const onlineClassEnterHomeworkTitle = 'onlineClassEnterHomeworkTitle';
  static const onlineClassHomeworkDescription =
      'onlineClassHomeworkDescription';
  static const onlineClassEnterHomeworkDescription =
      'onlineClassEnterHomeworkDescription';
  static const onlineClassUploadFile = 'onlineClassUploadFile';
  static const onlineClassUploadPicture = 'onlineClassUploadPicture';
  static const onlineClassUploadPictureOrPdf = 'onlineClassUploadPictureOrPdf';
  static const onlineClassMessageToStudents = 'onlineClassMessageToStudents';
  static const onlineClassNotificationStudents =
      'onlineClassNotificationStudents';
  static const onlineClassAllStudentSubmissions =
      'onlineClassAllStudentSubmissions';
  static const onlineClassViewEachStudent = 'onlineClassViewEachStudent';
  static const onlineClassSubmitted = 'onlineClassSubmitted';
  static const onlineClassPending = 'onlineClassPending';
  static const onlineClassView = 'onlineClassView';
  static const onlineClassDeadline = 'onlineClassDeadline';
  static const onlineClassEdit = 'onlineClassEdit';
  static const onlineClassDelete = 'onlineClassDelete';
  static const onlineClassDeleteConfirm = 'onlineClassDeleteConfirm';
  static const onlineClassDeletedSuccessfully =
      'onlineClassDeletedSuccessfully';
  static const onlineClassUpdatedSuccessfully =
      'onlineClassUpdatedSuccessfully';
  static const onlineClassNoHomeworkHereYet = 'onlineClassNoHomeworkHereYet';
  static const onlineClassLoadingHomework = 'onlineClassLoadingHomework';
  static const onlineClassLoadingHomeworkSubtitle =
      'onlineClassLoadingHomeworkSubtitle';
  static const onlineClassSubmitting = 'onlineClassSubmitting';
  static const onlineClassAttachHomework = 'onlineClassAttachHomework';
  static const onlineClassSuccessTitle = 'onlineClassSuccessTitle';
  static const onlineClassHomeworkSubmittedSuccessfully =
      'onlineClassHomeworkSubmittedSuccessfully';
  static const onlineClassSubmitHomework = 'onlineClassSubmitHomework';
  static const onlineClassSubmitHomeworkSubtitle =
      'onlineClassSubmitHomeworkSubtitle';
  static const onlineClassYourAnswer = 'onlineClassYourAnswer';
  static const onlineClassWriteAnswerHint = 'onlineClassWriteAnswerHint';
  static const onlineClassAttachment = 'onlineClassAttachment';
  static const onlineClassAttachImage = 'onlineClassAttachImage';
  static const onlineClassImageReadyToUpload = 'onlineClassImageReadyToUpload';
  static const onlineClassOptionalChooseImage =
      'onlineClassOptionalChooseImage';
  static const onlineClassPreviewUnavailable = 'onlineClassPreviewUnavailable';
  static const onlineClassReadyToSubmit = 'onlineClassReadyToSubmit';
  static const onlineClassAddedAnswer = 'onlineClassAddedAnswer';
  static const onlineClassNoWrittenAnswer = 'onlineClassNoWrittenAnswer';
  static const onlineClassAndImage = 'onlineClassAndImage';
  static const onlineClassAddAnswerOrImage = 'onlineClassAddAnswerOrImage';
  static const studentDocumentTeacherSubTitle =
      'studentDocumentTeacherSubTitle';
  static const standingsTeacherSubTitle = 'standingsTeacherSubTitle';
  static const paymentCollectionTeacherSubTitle =
      'paymentCollectionTeacherSubTitle';
  static const monthJanuary = 'monthJanuary';
  static const monthFebruary = 'monthFebruary';
  static const monthMarch = 'monthMarch';
  static const monthApril = 'monthApril';
  static const monthMay = 'monthMay';
  static const monthJune = 'monthJune';
  static const monthJuly = 'monthJuly';
  static const monthAugust = 'monthAugust';
  static const monthSeptember = 'monthSeptember';
  static const monthOctober = 'monthOctober';
  static const monthNovember = 'monthNovember';
  static const monthDecember = 'monthDecember';

  static const accountName = 'accountName';
  static const accountNumber = 'accountNumber';
  static const productCategory = 'productCategory';
  static const chooseBank = 'chooseBank';
  static const successfullyRegister = 'successfullyRegister';
  static const permission = 'permission';
  static const noPermission = 'noPermission';
  static const congratulation = 'congratulation';
  static const youHaveSuccessfullyChangedThePassword =
      'youHaveSuccessfullyChangedThePassword';
  static const cannotNavigationToDetailsScreen =
      'cannotNavigationToDetailsScreen';
  static const invoiceNumber = 'invoiceNumber';
  static const invoiceDetails = 'invoiceDetails';
  static const noInvoiceDetailsFound = 'noInvoiceDetailsFound';
  static const studentPaymentInformation = 'studentPaymentInformation';
  static const paymentHistorySection = 'paymentHistorySection';
  static const noLabel = 'noLabel';
  static const typeLabel = 'typeLabel';
  static const invoiceLabel = 'invoiceLabel';
  static const pending = 'pending';
  static const problem = 'problem';
  static const companyPhoneNumber = 'companyPhoneNumber';
  static const paymentType = 'paymentType';
  static const yourBooking = 'yourBooking';
  static const tracking = 'tracking';
  static const invoiceId = 'invoiceId';
  static const search = 'search';
  static const searchNotFound = 'searchNotFound';
  static const deleteAccount = 'deleteAccount';
  static const deleteAccountMessage = 'deleteAccountMessage';
  static const youHaveSuccesfulyDeletedYourAccount =
      'youHaveSuccesfulyDeletedYourAccount';
  static const startBillcreate = 'startBillcreate';
  static const endBillCreate = 'endBillCreate';
  static const startBillFinish = 'startBillFinish';
  static const endBillFinish = 'endBillFinish';
  static const filterDelivery = 'filterDelivery';
  static const chooseDeliveyStatus = 'chooseDeliveyStatus';
  static const paymentDes = 'paymentDes';
  static const completeDate = 'completeDate';
  static const featureTemporarilyUnavailable = 'featureTemporarilyUnavailable';
  static const login = 'login';
  static const loginNow = 'loginNow';
  static const loginContinueMessage = 'loginContinueMessage';
  static const teacher = 'teacher';
  static const parent = 'parent';
  static const phoneOrEmail = 'phoneOrEmail';
  static const signingIn = 'signingIn';
  static const signUp = 'signUp';
  static const sendCode = 'sendCode';
  static const forgotPasswordDescription = 'forgotPasswordDescription';
  static const rememberYourPassword = 'rememberYourPassword';
  static const backToLogin = 'backToLogin';
  static const needHelp = 'needHelp';
  static const contactSupport = 'contactSupport';
  static const verificationCodeSent = 'verificationCodeSent';
  static const send = 'send';
  static const next = 'next';
  static const change = 'change';
  static const cancel = 'cancel';
  static const transfer = 'transfer';
  static const ok = 'ok';
  static const done = 'done';
  static const username = 'username';
  static const submit = 'submit';
  static const update = 'update';
  static const apply = 'apply';
  static const commend = 'commend';
  static const typeOfCod = 'typeOfCod';
  static const enterYourName = 'enterYourName';
  static const successfulGetProduct = 'successfulGetProduct';
  static const present = 'present';
  static const paid = 'paid';
  static const unpaid = 'unpaid';
  static const absent = 'absent';
  static const late = 'late';
  static const allDates = 'allDates';
  static const breakTime = 'breakTime';
  static const morning = 'morning';
  static const afternoon = 'afternoon';
  static const evening = 'evening';
  static const grade = 'grade';
  static const subject = 'subject';
  static const score = 'score';
  static const math = 'math';
  static const khmer = 'khmer';
  static const english = 'english';
  static const history = 'history';
  static const biology = 'biology';
  static const chemistry = 'chemistry';
  static const to = 'to';
  static const prending = 'prending';
  static const approved = 'approved';
  static const reject = 'reject';
  static const haveAnAccount = 'haveAnAccount';
  static const orConnectWith = 'orConnectWith';
  static const welcomeTo = 'welcomeTo';
  static const createAccountAndAccessCoolStuffs =
      'createAccountAndAccessCoolStuffs';
  static const leaveDuration = 'leaveDuration';
  static const view = 'view';
  static const noDataFound = 'noDataFound';
  static const detailedReason = 'detailedReason';
  static const attachments = 'attachments';
  static const document = 'document';
  static const section = 'section';
  static const leaveDay = 'leaveDay';
  static const leaveDaysUnit = 'leaveDaysUnit';
  static const selectDate = 'selectDate';
  static const teacherActivityFeed = 'teacherActivityFeed';
  static const studentActivityFeed = 'studentActivityFeed';
  static const noClassActivitiesFound = 'noClassActivitiesFound';
  static const createActivity = 'createActivity';
  static const tapToViewTheFullActivityDetails =
      'tapToViewTheFullActivityDetails';
  static const editActivity = 'editActivity';
  static const activityTitleEmpty = 'activityTitleEmpty';
  static const activityDescriptionEmpty = 'activityDescriptionEmpty';
  static const activityTitleLabel = 'activityTitleLabel';
  static const descriptionLabel = 'descriptionLabel';
  static const coverImageOptionalHint = 'coverImageOptionalHint';
  static const coverImageReplaceHint = 'coverImageReplaceHint';
  static const chooseImage = 'chooseImage';
  static const changeImage = 'changeImage';
  static const maxImagesReachedMessage = 'maxImagesReachedMessage';
  static const imageRemovalNotSupportedMessage =
      'imageRemovalNotSupportedMessage';
  static const activityContent = 'activityContent';
  static const activityContentSubtitle = 'activityContentSubtitle';
  static const activityTitleHint = 'activityTitleHint';
  static const noClassAvailable = 'noClassAvailable';
  static const selectClass = 'selectClass';
  static const classTarget = 'classTarget';
  static const classTargetSubtitle = 'classTargetSubtitle';
  static const createAndNotifyStudents = 'createAndNotifyStudents';
  static const submitting = 'submitting';
  static const updateActivity = 'updateActivity';
  static const success = 'success';
  static const activityUpdatedSuccess = 'activityUpdatedSuccess';
  static const activityCreatedSuccess = 'activityCreatedSuccess';
  static const pleaseSelectClass = 'pleaseSelectClass';
  static const descriptionHint = 'descriptionHint';
  static const imageSelectedReady = 'imageSelectedReady';
  static const coverImage = 'coverImage';
  static const coverImageSubtitle = 'coverImageSubtitle';
  static const deleting = 'deleting';
  static const deleteActivity = 'deleteActivity';
  static const confirmDeleteMessage = 'confirmDeleteMessage';
  static const activityDeletedSuccess = 'activityDeletedSuccess';
  static const delete = 'delete';
  static const noDescriptionProvided = 'noDescriptionProvided';
  static const activityDetails = 'activityDetails';
  static const activityDetailsSubtitle = 'activityDetailsSubtitle';
  static const classActivity = 'classActivity';
}

class Locales {
  static const EN_US = {
    'enterYourName': 'Enter your name',
    'unableToConnectToTheInternet': 'Unable to connect to the internet',
    'cancelled': 'Cancelled',
    'send': 'Send',
    'yourRequestHasBeenCancelled': 'Your request has been cancelled.',
    'connectionTimeout': 'Connection timeout',
    'yourConnectionIsTimeout': 'Your connection is timeout',
    'recieveTimeout': 'Recieve timeout',
    'yourRecievingDataIsTimeout': 'Your recieving data is timeout',
    'somethingWentWrong': 'Something went wrong',
    'notFound': 'Not found',
    'request': 'Request',
    'yourRequestedUrlWasNotFound': 'Your requested url was not found',
    'areYouSureYourWantToLogout': 'Are you sure you want to logout?',
    'areYouSureYourWantToDelete':
        'Are you sure you want to delete this booking?',
    'youHaveSuccessfullyCreated': 'You have successfully created',
    'unableToPickImagePleaseTryAgain':
        'Unable to pick image. Please try again.',
    'successfully': 'áž‡áŸ„áž€áž‡áŸáž™',
    'forgotPassword': 'Forgot password',
    'studentProfileInformation': 'Student profile information',
    'studentProfileInformationSub':
        'Please check your Child profile information.',
    'password': 'Password',
    'cannotBeEmpty': 'Can\'t be empty',
    'invalidPhoneNumber': 'Invalid phone number',
    'loginWithUsernameEmail': 'Login With Username / Email',
    'email': 'Email',
    'loginWithPhoneNumber': 'Login With Phone number',
    'invalidEmail': 'Invalid Email',
    'passwordDoNotMatch': 'Password do not match',
    'newPassword': 'New password',
    'loginFailed': 'Login Failed',
    'loginFailedMessage': 'Login failed. Please check your information.',
    'noResponseFromServer': 'No response from server',
    'invalidCredentials': 'Invalid credentials',
    'invalidServerResponse': 'Invalid server response',
    'tokenMissing': 'Token missing',
    'selectedRoleIs': 'Selected role is',
    'pleaseSwitchRoleAndTryAgain': 'Please switch role and try again.',
    'pleaseEnterValidPhoneNumber': 'Please enter a valid phone number',
    'somethingWentWrongTryAgain': 'Something went wrong. Please try again.',
    'dashboard': 'Dashboard',
    'attendanceRecordTitle': 'Attendance Record',
    'attendanceRecordSubTitle':
        'You can view your children\'s attendance while they are studying.',
    'leavesTitle': 'Leaves',
    'leavesSubTitle': 'You can view your student leaves here.',
    'leavesTeacherSubTitle': 'You can view your student leaves here.',
    'studentAttendanceTitle': 'Student Attendance',
    'studentAttendanceSubTitle': 'You can view your students attendance logs.',
    'studentAttendanceTeacherSubTitle':
        'You can view your students attendance logs.',
    'noAttendanceLogsFound': 'No attendance logs found.',
    'noStaffAttendanceLogsFound': 'No staff attendance logs found.',
    'morningIn': 'Morning In',
    'morningOut': 'Morning Out',
    'afternoonIn': 'Afternoon In',
    'afternoonOut': 'Afternoon Out',
    'scanQrCodeToLogAttendance': 'Scan QR code to log attendance',
    'scheduleTitle': 'Class Schedule',
    'scheduleSubTitle':
        'You can view your children\'s study activities while they are learning.',
    'scheduleStudentRequired': 'Student ID is required.',
    'invalidResponseData': 'Invalid response data.',
    'failedToLoadSchedule': 'Failed to load schedule.',
    'studentNameLabel': 'Name',
    'classLabel': 'Class',
    'dateLabel': 'Date',
    'noClass': 'No class',
    'sessionNumber': 'Session',
    'teacherLabel': 'Teacher',
    'roomLabel': 'Room',
    'mondayShort': 'Mon',
    'tuesdayShort': 'Tue',
    'wednesdayShort': 'Wed',
    'thursdayShort': 'Thu',
    'fridayShort': 'Fri',
    'saturdayShort': 'Sat',
    'sundayShort': 'Sun',
    'requestLeaveTitle': 'Request Leave',
    'requestLeaveSubTitle': 'You can submit a leave request.',
    'requestLeaveSelectStudent':
        'Select the student you want to request leave for',
    'requestLeaveFillInfo': 'Fill in your leave request information',
    'student': 'Student',
    'studentId': 'Student ID',
    'teacherId': 'Teacher ID',
    'studentName': 'Student Name',
    'teacherName': 'Teacher Name',
    'role': 'Role',
    'profession': 'Profession',
    'dob': 'DOB',
    'pob': 'POB',
    'sex': 'Sex',
    'classSection': 'Class/Section',
    'parentTeacher': 'Parent/Teacher',
    'noTeacherInformationFound': 'No teacher information found.',
    'noStudentInformationFound': 'No student information found.',
    'noParentInformationFound': 'No parent information found.',
    'teacherProfile': 'Teacher Profile',
    'studentProfile': 'Student Profile',
    'parentProfile': 'Parent Profile',
    'selectedChild': 'Selected',
    'tapToSwitchChild': 'Tap to switch',
    'shift': 'Shift',
    'totalLeaveDays': 'Leave days',
    'leaveFromDate': 'Leave from',
    'leaveToDate': 'To',
    'leaveReason': 'Reason',
    'otherReasonHint': 'Please provide more details...',
    'otherReasonLabel': 'Other reason (optional)',
    'leaveRequestReviewNote':
        'Your request will be reviewed by the school administrator.',
    'studentIdCopied': 'Student ID copied',
    'sick': 'Sick',
    'busy': 'Busy',
    'all': 'All',
    'rejected': 'Rejected',
    'dashboardMenuTuitionFee': 'Payment',
    'dashboardMenuAttendance': 'Attendance',
    'dashboardMenuRequestLeave': 'Request Leave',
    'dashboardMenuSchedule': 'Schedule',
    'dashboardMenuStandings': 'Standings',
    'dashboardMenuAttendanceLog': 'Attendance List',
    'dashboardMenuAttendanceLogTeacher': 'Attendance log',
    'dashboardMenuStudentReport': 'Student Report',
    'dashboardMenuClassActivity': 'Class Activity',
    'dashboardMenuOnlineCourse': 'Homework',
    'dashboardMenuLeaves': 'Leaves',
    'dashboardMenuStudentAttendance': 'Student Attendance',
    'dashboardMenuExamination': 'Examination',
    'scoreEntryTitle': 'Score Entry',
    'scoreEntrySubTitle': 'View student scores for the selected class.',
    'scoreEntryTeacherSubTitle': 'Enter and save student scores for your class.',
    'scoreEntryLevel': 'Level',
    'scoreEntryResultType': 'Result Type',
    'scoreEntryMonth': 'Month',
    'scoreEntryQuarter': 'Quarter',
    'scoreEntrySelectResultTypeFirst': 'Select a result type first',
    'scoreEntrySelectFiltersHint': 'Select filters and tap Filter',
    'scoreEntryNoStudentsFound': 'No students found',
    'scoreEntryNoSubjects': 'No subjects available to score',
    'scoreEntrySave': 'Save',
    'assessmentManagementTitle': 'Assessment Management',
    'assessmentManagementSubTitle':
        'Record continuous assessment scores for your class.',
    'assessmentManagementSemester': 'Semester',
    'assessmentManagementTeacherComment': 'Teacher Comment',
    'examinationProgramTitle': 'Program',
    'examinationProgramChineseEnglish': 'Chinese English',
    'examinationProgramChineseEnglishSubtitle':
        'Chinese & English language Program',
    'examinationProgramKhmer': 'Khmer',
    'examinationProgramKhmerSubtitle': 'Khmer language Program',
    'examinationProgramScoreVerification': 'Score Verification',
    'examinationProgramScoreVerificationSubtitle':
        'Review and verify submitted scores',
    'scoreVerificationTitle': 'Score Verification',
    'scoreVerificationSubTitle':
        "Review scores submitted by teachers before they're locked.",
    'scoreVerificationPendingExam': 'Pending Examination Scores',
    'scoreVerificationPendingExamDesc':
        'Scores submitted for an exam subject, waiting to be verified and locked.',
    'scoreVerificationPendingQuarter': 'Pending Quarter Scores',
    'scoreVerificationPendingQuarterDesc':
        'Scores submitted through Score Entry, waiting to be verified and locked.',
    'scoreVerificationPendingAssessment': 'Pending Assessment Scores',
    'scoreVerificationPendingAssessmentDesc':
        'Scores submitted through Assessment Management, waiting to be verified and locked.',
    'scoreVerificationNothingPending': 'Nothing pending verification.',
    'scoreVerificationExam': 'Exam',
    'scoreVerificationSession': 'Session',
    'scoreVerificationStudents': 'Students',
    'scoreVerificationSubmitted': 'Submitted',
    'scoreVerificationView': 'View',
    'scoreVerificationVerify': 'Verify',
    'scoreVerificationVerifyAll': 'Verify All',
    'examinationProgramWeightedResult': 'Weighted Result',
    'examinationProgramWeightedResultSubtitle':
        'View combined exam and assessment results',
    'weightedResultTitle': 'Weighted Result',
    'weightedResultSubTitle':
        'Combines Assessment Management scores and exam scores using the '
        'Evaluation Criteria weights from Academic Setup.',
    'weightedResultWeightsLabel': 'Weights:',
    'weightedResultAdmissionNo': 'Admission No',
    'weightedResultStudent': 'Student',
    'weightedResultWeightedPercent': 'Weighted %',
    'weightedResultGrade': 'Grade',
    'weightedResultGpa': 'GPA',
    'weightedResultResult': 'Result',
    'weightedResultNoStudentsFound': 'No students found.',
    'weightedResultSelectFiltersHint': 'Select filters and tap Filter',
    'weightedResultCriterionHomework': 'Homework',
    'weightedResultCriterionCommunication': 'Communication',
    'weightedResultCriterionClasswork': 'Classwork',
    'weightedResultCriterionReflection': 'Reflection',
    'weightedResultCriterionBeRespectful': 'Be respectful in the class',
    'weightedResultCriterionStudentsAttention': 'Students attention',
    'weightedResultCriterionTaskResponsibility': 'Task Responsibility',
    'weightedResultCriterionWorkIndependently': 'Work independently',
    'weightedResultCriterionStudentsPunctually': 'Students punctually',
    'weightedResultCriterionMorality': 'Morality',
    'examinationProgramViewScore': 'View Score',
    'examinationProgramViewScoreSubtitle':
        'View raw assessment scores for a class',
    'viewScoreTitle': 'View Score',
    'viewScoreSubTitle':
        'Select a teacher, then one of their assigned classes, to view '
        'scores for every subject that teacher teaches in that class.',
    'viewScoreGender': 'Gender',
    'viewScoreNoStudentsFound': 'No students found.',
    'viewScoreSelectFiltersHint': 'Select filters and tap Filter',
    'recordAttendanceSearchHint': 'Search Student...',
    'recordAttendanceSelectAllPresent': 'Select All Present',
    'recordAttendanceNoStudentsFound': 'No students found',
    'recordAttendanceNoColumn': 'No.',
    'recordAttendanceGender': 'Gender',
    'recordAttendanceNote': 'Note',
    'recordAttendanceEnterNoteHint': 'Enter note',
    'recordAttendanceSave': 'Save',
    'recordAttendanceSubmit': 'Submit Attendance',
    'studentAttendanceNoRecordsFound': 'No attendance records found',
    'welcomeParentPrefix': 'Welcome Parent, ',
    'welcomeTeacherPrefix': 'Welcome Teacher, ',
    'welcomeParentSubtitle': 'here is your parent dashboard.',
    'welcomeTeacherSubtitle': 'here is your teacher dashboard.',
    'payments': 'Payments',
    'scanner': 'Scanner',
    'delivery': 'Delivery',
    'deliveries': 'Deliveries',
    'more': 'More',
    'username': 'Username',
    'totalPackage': 'Total Package',
    'deliveryTransfer': 'Delivery Transfer',
    'chooseANewDelivery': 'Choose a new delivery',
    'language': 'Language',
    'logout': 'Logout',
    'settings': 'Settings',
    'changePassword': 'Change password',
    'photoLibrary': 'Photo library',
    'camera': 'Camera',
    'currentPassword': 'Current password',
    'reEnterPassword': 'Re-enter password',
    'fromDate': 'From date',
    'toDate': 'To date',
    'applyDate': 'Apply date',
    'approvedBy': 'Approved by',
    'filterDate': 'Filter date',
    'termAndCondition': 'Term and Conditions',
    'contactUs': 'Contact Us',
    'address': 'Address',
    'openInGoogleMap': 'Open in Google Map',
    'openMap': 'Open Map',
    'callNow': 'Call Now',
    'contact': 'Contact',
    'noPackage': 'No Package',
    'totalAmount': 'Total amount',
    'deliveriesC': 'DELIVERIES',
    'transfers': 'TRANSFERS',
    'thisTransactionSuccess': 'This transaction success',
    'transaction': 'Transaction',
    'deliveryName': 'Delivery name',
    'amount': 'Amount',
    'date': 'Date',
    'checkedBy': 'Checked by',
    'packages': 'packages',
    'extraAmountAndTaxi': ' Extra Amount, Taxi',
    'numberOfDelivery': 'Number of Delivery',
    'commissionFee': 'Commission Fee',
    'location': 'Location',
    'phoneNumber': 'Phone number',
    'changeStatus': 'Change status',
    'dateComplete': 'Date complete',
    'transferTo': 'Transfer to',
    'version': 'Version',
    'noData': 'No Data',
    'noPaymentHistoryFound': 'No payment history found.',
    'deliveryScanHasBeenCompleted': 'Delivery Scan Has Been completed.',
    'driverGetProduct': 'Driver get product.',
    'product': 'Product',
    'error': 'Error',
    'invalidQRCodeOrBarCode': 'Invalid QR code or Barcode.',
    'paymentAdd': 'Payment add',
    'deliveryFee': 'Delivery Fee',
    'booking': 'Booking',
    'createBooking': 'Create booking',
    'zone': 'Zone',
    'destinationPhone': 'Destination Phone',
    'enterDestinationPhone': 'Enter destination phone',
    'destination': 'Destination',
    'bookingDate': 'Booking date',
    'bookingDetails': 'Booking Details',
    'typeOfService': 'Type of service',
    'typeOfCoc': 'Type of COD',
    'anyExtra': 'Any extra',
    'extraAmount': 'Extra amount',
    'anyExtraType': 'Any extra type',
    'serviceFee': 'Service fee',
    'confirmation': 'Confirmation',
    'haveAnAccount': 'Have an account?',
    'areYouSureYouWantToDeleteThisBooking':
        'Are you sure you want to delete this booking?',
    'thanksYou': 'Thanks you',
    'yourBookingHasBeenAdded': 'Your booking has been added.',
    'yourBookingHasBeenUpdated': 'Your booking has been updated.',
    'updateBooking': 'Update booking',
    'description': 'Description',
    'enterDescription': 'Enter description',
    'destinationZone': 'Destination Zone',
    'chooseDestinationZone': 'Choose destination zone',
    'image': 'Image',
    'typeOfCO': 'Type of CO',
    'anyExtraServiceCharge': 'Any extra service charge?',
    'yes': 'Yes',
    'no': 'No',
    'taxi': 'Taxi',
    'other': 'Other',
    'normal': 'Normal',
    'express': 'Express',
    'bookingStatus': 'Booking status',
    'receiverPhoneNumber': 'Desc phonenumber',
    'deliverySuccess': 'Delivery Success',
    'filterByStatus': 'Filter status',
    'filterByDate': 'Filter date',
    'progress': 'Progress',
    'complete': 'Complete',
    'inStock': 'In Stock',
    'filter': 'Filter',
    'doNotHaveAnAccount': 'Don\'t have an account? ',
    'orConnectWith': 'Or connect with',
    'register': 'Register',
    'yourNameOrShopName': 'Your Name or Shop Name',
    'confirmPassword': 'Confirm Password',
    'registerSuccessful': 'Register successful.',
    'registerUnavailable':
        'Account creation is not available in the app. Please contact the school office to get your account.',
    'deliveryInprogress': 'Delivery Inprogress',
    'paymentReceipt': 'Payment Receipt',
    'paymentReport': 'Payment Report',
    'startDate': 'Start date',
    'endDate': 'End date',
    'reason': 'Reason',
    'profile': 'Profile',
    'totalIncome': 'Total income',
    'area': 'Area',
    'getDate': 'Get date',
    'releaseDate': 'Release date',
    'customer': 'Customer',
    'bonus': 'Bonus',
    'total': 'Total',
    'activity': 'Activity',
    'activitySubTitle': 'This is your activity dashboard.',
    'moneyAtStaff': 'Money at staff',
    'moneyAtCompany': 'Money at company',
    'moneyAtSell': 'Money at sell',
    'payment': 'Payment',
    'totalDelivery': 'Total Delivery',
    'extraMoneyAndCarFee': 'Extra money and car fee',
    'searchDelivery': 'Search delivery',
    'deliveryActivity': 'Delivery activity',
    'inprogress': 'Inprogress',
    'finish': 'Finish',
    'codFee': 'COD fee',
    'returned': 'Return',
    'choose': 'Choose',
    'detailOfPayments': 'Detail of payments',
    'qrCode': 'QR Code',
    'enterProductCode': 'Enter product\'s code',
    'getProduct': 'Get product',
    'finishDelivery': 'Finish delivery',
    'exchangeRateToday': 'Today exchange rate',
    'customerReject': 'Delivered to the location but the customer rejected',
    'viewDetails': 'View Detail',
    'clear': 'Clear',
    'notification': 'Notification',
    'successulGetProduct': 'Successful get products.',
    'successfulFinishDelivery': 'Successful finish delivery',
    'paymentMethods': 'Payment methoods',
    'dateVerity': 'Date verify',
    'status': 'Status',
    'packagesBooking': 'Package Booking',
    'sampleBooking': 'Sample Booking',
    'createdDate': 'Created date',
    'enterDestination': 'Enter destination',
    'chooseDate': 'Choose date',
    'uploadImage': 'Upload image',
    'numberOfPackages': 'Number of packages',
    'enterNumberOfPackages': 'Enter number of packages',
    'totalShipping': 'Total Shipments',
    'fee': 'Fee',
    'avialableCredit': 'Avialable Credit',
    'enterLocation': 'Enter locatioin',
    'bank': 'Bank',
    'accountName': 'Account name',
    'accountNumber': 'Account number',
    'productCategory': 'Product category',
    'chooseBank': 'Choose bank',
    'successfullyRegister': 'Successfully Register',
    'permission': 'Permission',
    'noPermission': 'No permission to access to this app.',
    'congratulation': 'Congratulation',
    'youHaveSuccessfullyChangedThePassword':
        'You have successfully changed the password.',
    'cannotNavigationToDetailsScreen': 'Cannot navigate to details screen.',
    'invoiceNumber': 'Invoice number',
    'invoiceDetails': 'Invoice Details',
    'noInvoiceDetailsFound': 'No invoice details found.',
    'studentPaymentInformation': '1. Student payment information',
    'paymentHistorySection': '2. Payment history',
    'noLabel': 'No',
    'typeLabel': 'Type',
    'invoiceLabel': 'Invoice',
    'pending': 'Pending',
    'problem': 'Problem',
    'companyPhoneNumber': 'Company phonenumber',
    'paymentType': 'Payment type',
    'yourBooking': 'Your booking',
    'tracking': 'Tracking',
    'invoiceId': 'Invoice ID',
    'search': 'Search',
    'searchNotFound': 'Search not found',
    'deleteAccount': 'Delete account',
    'deleteAccountMessage':
        'Are you sure you want to delete your account? Deleting your account is permanent and will remove all of your content and profile settings.',
    'youHaveSuccesfulyDeletedYourAccount':
        'Your have successfully deleted your account',
    'startBillcreate': 'Start bill create',
    'endBillCreate': 'End bill create',
    'startBillFinish': 'Start bill finish',
    'endBillFinish': 'End bill finish',
    'filterDelivery': 'Filter delivery',
    'chooseDeliveyStatus': 'Choose delivery status',
    'paymentDes':
        'Any friagile valnerable and illegal item are prohibited from shipment and are sender\'s responsibily',
    'completeDate': 'Complete date',
    'featureTemporarilyUnavailable':
        'This feature is temporarily unavailable. Please try again later.',
    'login': 'Log In',
    'loginNow': 'Log In Now',
    'loginContinueMessage': 'Please log in to continue using the app.',
    'teacher': 'Teacher',
    'parent': 'Parent',
    //attendance
    'attendance': 'Attendance',
    'attendanceSubTitle': 'Here is your attendance dashboard.',
    'attendanceTeacherSubTitle': 'Track teacher attendance and scan activity.',
    'attendanceRecordTeacherSubTitle':
        'View teacher attendance logs and scan records.',
    'scheduleTeacherSubTitle':
        'View your teaching schedule and class sessions.',
    'requestLeaveTeacherSubTitle': 'Submit and manage teacher leave requests.',
    'allRequestedLeaveTeacherSubTitle':
        'Review your submitted teacher leave requests.',
    'activityTeacherSubTitle': 'View class activities shared for teachers.',
    'onlineCoursesTeacherSubTitle':
        'Manage class activities, homework, notifications, and submissions.',
    'onlineClassTitle': 'Homework',
    'onlineClassParentSubtitle':
        'View activities, homework, and notifications.',
    'onlineClassTeacherSubtitle':
        'Manage class activities, homework, notifications, and submissions.',
    'onlineClassTeacherWorkbench': 'Teacher Workbench',
    'onlineClassTeacherWorkbenchSubtitle':
        'Create activities, assign homework, and review student work.',
    'onlineClassParentOverview': 'Parent Overview',
    'onlineClassParentOverviewSubtitle':
        'Track homework, notifications, and class activities.',
    'onlineClassSubmissions': 'Submissions',
    'onlineClassTotalClass': 'Total Class',
    'onlineClassStudents': 'Students',
    'onlineClassDueToday': 'Due Today',
    'onlineClassActivities': 'Activities',
    'onlineClassTeachingTools': 'Teaching Tools',
    'onlineClassQuickActions': 'Quick Actions',
    'onlineClassSubmissionReview': 'Submission Review',
    'onlineClassLatestUpdates': 'Latest Updates',
    'onlineClassStudentSubmissionReview': 'Student Submission Review',
    'onlineClassHomeworkFilesWaiting': '8 homework files waiting',
    'onlineClassHomeworkDeadlineSetting': 'Homework Deadline Setting',
    'onlineClassSetDueDate': 'Set due date for new assignment',
    'onlineClassReceiveNotifications': 'Receive Notifications',
    'onlineClassNewAnnouncement': 'New class announcement available',
    'onlineClassUploadHomeworkSubmission': 'Upload Homework Submission',
    'onlineClassReadyToUpload': 'Ready after homework is complete',
    'onlineClassHomeworkStatus': 'Homework Status',
    'onlineClassHomeworkDone': '2/3 done',
    'onlineClassHomeworkNeedsSubmission':
        'One homework assignment still needs submission.',
    'onlineClassActionClassActivity': 'Class Activity',
    'onlineClassActionClassDetail': 'Class Detail',
    'onlineClassActionViewClassInfo': 'View class info',
    'onlineClassActionPostUpdate': 'Post update',
    'onlineClassActionAssignHomework': 'Assign Homework',
    'onlineClassActionAllAssignHomework': 'All Assign Homework',
    'onlineClassActionCreateTask': 'Create task',
    'onlineClassActionNotifyClass': 'Notify Class',
    'onlineClassActionSendMessage': 'Send message',
    'onlineClassActionAllSubmit': 'All Submit',
    'onlineClassActionReviewSubmissions': 'Review submissions',
    'onlineClassActionUploadFiles': 'Upload Files',
    'onlineClassActionAddMaterials': 'Add materials',
    'onlineClassActionActivities': 'Activities',
    'onlineClassActionClassMoments': 'Class moments',
    'onlineClassActionHomework': 'Homework',
    'onlineClassActionViewTasks': 'View tasks',
    'onlineClassActionComplete': 'Complete',
    'onlineClassActionDoHomework': 'Do homework',
    'onlineClassActionSubmit': 'Submit',
    'onlineClassActionUploadWork': 'Upload work',
    'onlineClassActionNotifications': 'Notifications',
    'onlineClassActionMessages': 'Messages',
    'onlineClassSelectClass': 'Select class',
    'onlineClassLoadingClassList': 'Loading class list...',
    'onlineClassNoClassAvailable': 'No class available',
    'onlineClassNoClassAvailableYet': 'No class list available yet.',
    'onlineClassPleaseSelectClass': 'Please select a class.',
    'onlineClassMissingClassId': 'This class is missing its class ID.',
    'onlineClassStudentList': 'Student list',
    'onlineClassHomeworkTitle': 'Homework:',
    'onlineClassEnterHomeworkTitle': 'Enter homework title',
    'onlineClassHomeworkDescription': 'Homework instruction or description',
    'onlineClassEnterHomeworkDescription': 'Enter instruction or description',
    'onlineClassUploadFile': 'Upload file',
    'onlineClassUploadPicture': 'Upload picture',
    'onlineClassUploadPictureOrPdf': 'Upload picture or PDF',
    'onlineClassMessageToStudents': 'Message to students',
    'onlineClassNotificationStudents': 'Show students who will receive this',
    'onlineClassAllStudentSubmissions': 'All student submissions',
    'onlineClassViewEachStudent': 'View each student submission',
    'onlineClassSubmitted': 'Submitted',
    'onlineClassPending': 'Pending',
    'onlineClassView': 'View',
    'onlineClassDeadline': 'Deadline',
    'onlineClassEdit': 'Edit',
    'onlineClassDelete': 'Delete',
    'onlineClassDeleteConfirm':
        'Are you sure you want to delete this homework?',
    'onlineClassDeletedSuccessfully': 'Homework deleted successfully.',
    'onlineClassUpdatedSuccessfully': 'Homework updated successfully.',
    'onlineClassNoHomeworkHereYet': 'No homework here yet.',
    'onlineClassLoadingHomework': 'Loading homework...',
    'onlineClassLoadingHomeworkSubtitle':
        'Please wait while we load assigned homework.',
    'onlineClassSubmitting': 'Submitting...',
    'onlineClassAttachHomework': 'Open',
    'onlineClassSuccessTitle': 'Success',
    'onlineClassHomeworkSubmittedSuccessfully':
        'Homework submitted successfully.',
    'onlineClassSubmitHomework': 'Submit Homework',
    'onlineClassSubmitHomeworkSubtitle':
        'Answer the question and attach an image if needed.',
    'onlineClassYourAnswer': 'Your Answer',
    'onlineClassWriteAnswerHint': 'Write your answer here...',
    'onlineClassAttachment': 'Attachment',
    'onlineClassAttachImage': 'Attach an image',
    'onlineClassImageReadyToUpload': 'Image selected and ready to upload.',
    'onlineClassOptionalChooseImage':
        'Optional. Choose one image from the gallery.',
    'onlineClassPreviewUnavailable': 'Preview unavailable',
    'onlineClassReadyToSubmit': 'Ready to submit. You have added',
    'onlineClassAddedAnswer': 'an answer',
    'onlineClassNoWrittenAnswer': 'no written answer',
    'onlineClassAndImage': 'and an image.',
    'onlineClassAddAnswerOrImage':
        'Add a written answer or attach an image before submitting.',
    'studentDocumentTeacherSubTitle':
        'Review student profile and document information.',
    'standingsTeacherSubTitle': 'Review student standings and score results.',
    'paymentCollectionTeacherSubTitle':
        'Review student payment collection information.',
    'monthJanuary': 'January',
    'monthFebruary': 'February',
    'monthMarch': 'March',
    'monthApril': 'April',
    'monthMay': 'May',
    'monthJune': 'June',
    'monthJuly': 'July',
    'monthAugust': 'August',
    'monthSeptember': 'September',
    'monthOctober': 'October',
    'monthNovember': 'November',
    'monthDecember': 'December',
    'phoneOrEmail': 'Phone, or email',
    'signingIn': 'Signing in...',
    'signUp': 'Sign Up',
    'sendCode': 'Send Code',
    'forgotPasswordDescription':
        'Provide your account\'s phone number to reset your password.',
    'rememberYourPassword': 'Remember your password? ',
    'backToLogin': 'Back to Login',
    'needHelp': 'Need Help ? ',
    'contactSupport': 'Contact Support',
    'verificationCodeSent': 'Verification code sent.',
    'next': 'NEXT',
    'change': 'CHANGE',
    'cancel': 'Cancel',
    'transfer': 'Transfer',
    'ok': 'OK',
    'done': 'DONE',
    'submit': 'Submit',
    'update': 'Update',
    'apply': 'Apply',
    'commend': 'Commend',
    //————————————————————haysan——————————————————————//
    'present': 'Present',
    'paid': 'Paid',
    'unpaid': 'Unpaid',
    'absent': 'Absent',
    'late': 'Late',
    'allDates': 'All Dates',
    'breakTime': 'Break Time',
    'morning': 'Morning',
    'afternoon': 'Afternoon',
    'evening': 'Evening',
    'grade': 'Grade',
    'subject': 'Subject',
    'score': 'Score',
    'math': 'Math',
    'khmer': 'Khmer',
    'english': 'English',
    'history': 'History',
    'biology': 'Biology',
    'chemistry': 'Chemistry',
    'to': 'To',
    'prending': 'Pending',
    'approved': 'Approved',
    'reject': 'Reject',
    'welcomeTo': 'Welcome To',
    'createAccountAndAccessCoolStuffs':
        'Create an account and access\n thousand of cool stuffs.',
    'leaveDuration': 'Leave Duration',
    'view': 'View',
    'noDataFound': 'No data found',
    'detailedReason': 'Detailed Reason',
    'attachments': 'Attachments',
    'document': 'Document',
    'section': 'Section',
    'leaveDay': 'Day',
    'leaveDaysUnit': 'Days',
    'selectDate': 'Select date',
    'sectionLabel': 'Section',
    'subjectLabel': 'Subject',
    'teacherActivityFeed': 'Teacher Activity Feed',
    'studentActivityFeed': 'Student Activity Feed',
    'noClassActivitiesFound': 'No class activities found',
    'createActivity': 'Create Activity',
    'tapToViewTheFullActivityDetails': 'Tap to view the full activity details',
    'editActivity': 'Edit Activity',
    'activityTitleEmpty': 'Activity title cannot be empty',
    'activityDescriptionEmpty': 'Description cannot be empty',
    'activityTitleLabel': 'Activity Title',
    'descriptionLabel': 'Description',
    'coverImageOptionalHint':
        'Optional. Add up to 10 photos to make the activity card more engaging.',
    'coverImageReplaceHint':
        'Optional. Add new photos or remove existing ones below.',
    'chooseImage': 'Choose Photos',
    'changeImage': 'Add More Photos',
    'maxImagesReachedMessage': 'You can add up to 10 images.',
    'imageRemovalNotSupportedMessage':
        'This image could not be deleted from the server and will reappear after saving.',
    'activityContent': 'Activity Content',
    'activityContentSubtitle':
        'Write the title and short description students should read first.',
    'activityTitleHint': 'For example: Science lab, Reading circle',
    'noClassAvailable': 'No class available',
    'selectClass': 'Select class',
    'classTarget': 'Class Target',
    'classTargetSubtitle': 'Choose which class should receive this activity.',
    'createAndNotifyStudents': 'Create and Notify Students',
    'submitting': 'Submitting...',
    'updateActivity': 'Update Activity',
    'success': 'Success',
    'activityUpdatedSuccess': 'Activity updated successfully',
    'activityCreatedSuccess': 'Activity created successfully',
    'pleaseSelectClass': 'Please select a class',
    'descriptionHint': 'Write a short summary.',
    'imageSelectedReady': 'Image selected and ready to upload.',
    'coverImage': 'Photos',
    'coverImageSubtitle':
        'Add up to 10 photos to make the activity card more engaging.',
    'deleting': 'Deleting...',
    'deleteActivity': 'Delete Activity',
    'confirmDeleteMessage': 'Are you sure you want to delete this activity?',
    'activityDeletedSuccess': 'Activity deleted successfully',
    'delete': 'Delete',
    'noDescriptionProvided': 'No description was provided for this activity.',
    'activityDetails': 'Activity Details',
    'activityDetailsSubtitle':
        'Everything students should know before opening or responding to this class activity.',
    'classActivity': 'Class Activity',
    'timeLabel': 'Time',
    'noticesLabel': 'Notices',
    'taLabel': 'TA',
  };
  static const KM_KH = {
    'unableToConnectToTheInternet': 'មិនអាចភ្ជាប់ទៅអ៊ីនធឺណិតបាន',
    'cancelled': 'បានបោះបង់',
    'send': 'ផ្ញើ',
    'orConnectWith': 'ឬតភ្ជាប់ជាមួយ',
    'yourRequestHasBeenCancelled': 'សំណើរបស់អ្នកត្រូវបានបោះបង់',
    'connectionTimeout': 'ការតភ្ជាប់អស់ពេល',
    'yourConnectionIsTimeout': 'ការតភ្ជាប់របស់អ្នកអស់ពេល',
    'recieveTimeout': 'ការទទួលទិន្នន័យអស់ពេល',
    'yourRecievingDataIsTimeout': 'ការទទួលទិន្នន័យរបស់អ្នកអស់ពេល',
    'somethingWentWrong': 'មានបញ្ហាអ្វីមួយ សូមព្យាយាមម្ដងទៀត',
    'notFound': 'រកមិនឃើញ',
    'yourRequestedUrlWasNotFound': 'រកមិនឃើញ URL ដែលអ្នកបានស្នើសុំ',
    'areYouSureYourWantToLogout': 'តើអ្នកពិតជាចង់ចាកចេញមែនទេ?',
    'areYouSureYourWantToDelete': 'តើអ្នកពិតជាចង់លុបមែនទេ?',
    'youHaveSuccessfullyCreated': 'អ្នកបានបង្កើតដោយជោគជ័យ',
    'studentProfileInformation': 'ព័ត៌មានប្រវត្តិរូបសិស្ស',
    'successfully': 'ជោគជ័យ',
    'youHavesuccessfullyCreatedTheBooking': 'អ្នកបានបង្កើតការកក់ដោយជោគជ័យ',
    'forgotPassword': 'ភ្លេចពាក្យសម្ងាត់',
    'password': 'ពាក្យសម្ងាត់',
    'loginNow': 'ចូលឥឡូវ',
    'cannotBeEmpty': 'មិនអាចទទេ',
    'attendance': 'វត្តមាន',
    'welcomeTo': 'សូមស្វាគមន៍',
    'createAccountAndAccessCoolStuffs':
        'បង្កើតគណនី ហើយចូលប្រើ មុខងារល្អៗជាច្រើនមុខ',
    'invalidPhoneNumber': 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ',
    'login': 'ចូល',
    'loginWithUsernameEmail': 'ចូលដោយប្រើឈ្មោះអ្នកប្រើ ឬ អ៊ីមែល',
    'email': 'អ៊ីមែល',
    'loginWithPhoneNumber': 'ចូលដោយប្រើលេខទូរស័ព្ទ',
    'invalidEmail': 'អ៊ីមែលមិនត្រឹមត្រូវ',
    'passwordDoNotMatch': 'ពាក្យសម្ងាត់មិនត្រូវគ្នា',
    'newPassword': 'ពាក្យសម្ងាត់ថ្មី',
    'loginFailed': 'ចូលប្រើបរាជ័យ',
    'loginFailedMessage': 'ចូលប្រើបរាជ័យ។ សូមពិនិត្យព័ត៌មានរបស់អ្នក។',
    'noResponseFromServer': 'មិនមានការឆ្លើយតបពីម៉ាស៊ីនមេ',
    'invalidCredentials': 'ព័ត៌មានចូលប្រើមិនត្រឹមត្រូវ',
    'invalidServerResponse': 'ការឆ្លើយតបពីម៉ាស៊ីនមេមិនត្រឹមត្រូវ',
    'tokenMissing': 'បាត់ Token',
    'selectedRoleIs': 'តួនាទីដែលបានជ្រើសគឺ',
    'pleaseSwitchRoleAndTryAgain': 'សូមប្ដូរតួនាទី ហើយព្យាយាមម្ដងទៀត។',
    'pleaseEnterValidPhoneNumber': 'សូមបញ្ចូលលេខទូរស័ព្ទត្រឹមត្រូវ',
    'somethingWentWrongTryAgain': 'មានបញ្ហាកើតឡើង។ សូមព្យាយាមម្ដងទៀត។',
    'dashboard': 'ផ្ទាំងគ្រប់គ្រង',
    'attendanceRecordTitle': 'កំណត់ត្រាវត្តមាន',
    'attendanceRecordSubTitle':
        'លោកអ្នកអាចដឹងពីវត្តមាន កូនៗរបស់លោកអ្នកពេលកំពុងសិក្សា',
    'leavesTitle': 'ច្បាប់ឈប់សម្រាក',
    'leavesSubTitle': 'អ្នកអាចមើលការច្បាប់របស់សិស្សដែលនៅក្នុងអ្នកប្រើប្រាស់',
    'leavesTeacherSubTitle':
        'អ្នកអាចមើលការច្បាប់របស់សិស្សដែលនៅក្នុងអ្នកប្រើប្រាស់',
    'studentAttendanceTitle': 'វត្តមានសិស្សដែលនឹងទទួល',
    'studentAttendanceSubTitle': 'លោកអ្នកអាចដឹងពីវត្តមានការវត្តមានសិស្ស',
    'studentAttendanceTeacherSubTitle': 'លោកអ្នកអាចដឹងពីវត្តមានការវត្តមានសិស្ស',
    'noAttendanceLogsFound': 'មិនមានកំណត់ត្រាវត្តមាន',
    'noStaffAttendanceLogsFound': 'មិនមានកំណត់ត្រាវត្តមានបុគ្គលិក',
    'morningIn': 'ព្រឹក ចូល',
    'morningOut': 'ព្រឹក ចេញ',
    'afternoonIn': 'រសៀល ចូល',
    'afternoonOut': 'រសៀល ចេញ',
    'scanQrCodeToLogAttendance': 'ស្កេន QR កូដ ដើម្បីកត់ត្រាវត្តមាន',
    'scheduleTitle': 'កាលវិភាគសិក្សា',
    'scheduleSubTitle': 'លោកអ្នកអាចដឹងពីសកម្មភាពសិក្សារបស់កូនៗពេលកំពុងសិក្សា។',
    'scheduleStudentRequired': 'ត្រូវការអត្តលេខសិស្ស',
    'invalidResponseData': 'ទិន្នន័យឆ្លើយតបមិនត្រឹមត្រូវ',
    'failedToLoadSchedule': 'មិនអាចទាញយកកាលវិភាគបានទេ',
    'studentNameLabel': 'ឈ្មោះ',
    'classLabel': 'ថ្នាក់',
    'dateLabel': 'កាលបរិច្ឆេទ',
    'noClass': 'មិនមានថ្នាក់',
    'sessionNumber': 'ម៉ោងទី',
    'teacherLabel': 'លោកគ្រូ/អ្នកគ្រូ',
    'roomLabel': 'បន្ទប់',
    'mondayShort': 'ចន្ទ',
    'tuesdayShort': 'អង្គារ',
    'wednesdayShort': 'ពុធ',
    'thursdayShort': 'ព្រហស្បតិ៍',
    'fridayShort': 'សុក្រ',
    'saturdayShort': 'សៅរ៍',
    'sundayShort': 'អាទិត្យ',
    'requestLeaveTitle': 'ស្នើសុំច្បាប់',
    'requestLeaveSubTitle': 'អ្នកអាចបញ្ជូនសំណើសុំច្បាប់បាន។',
    'requestLeaveSelectStudent': 'ជ្រើសរើសសិស្សដែលអ្នកចង់ស្នើសុំច្បាប់',
    'requestLeaveFillInfo': 'បំពេញព័ត៌មានសំណើសុំច្បាប់',
    'student': 'សិស្ស',
    'studentId': 'អត្តលេខសិស្ស',
    'teacherId': 'អត្តលេខគ្រូបង្រៀន',
    'studentName': 'ឈ្មោះសិស្ស',
    'teacherName': 'ឈ្មោះគ្រូ',
    'role': 'តួនាទី',
    'profession': 'មុខរបរ',
    'dob': 'ថ្ងៃខែឆ្នាំកំណើត',
    'pob': 'ទីកន្លែងកំណើត',
    'sex': 'ភេទ',
    'classSection': 'ថ្នាក់/ផ្នែក',
    'parentTeacher': 'អាណាព្យាបាល/គ្រូ',
    'noTeacherInformationFound': 'មិនមានព័ត៌មានគ្រូ',
    'noStudentInformationFound': 'មិនមានព័ត៌មានសិស្ស',
    'noParentInformationFound': 'មិនមានព័ត៌មានអាណាព្យាបាល',
    'teacherProfile': 'ព័ត៌មានគ្រូ',
    'studentProfile': 'ព័ត៌មានសិស្ស',
    'parentProfile': 'ព័ត៌មានអាណាព្យាបាល',
    'selectedChild': 'បានជ្រើសរើស',
    'tapToSwitchChild': 'ចុចដើម្បីប្ដូរ',
    'shift': 'វេន',
    'totalLeaveDays': 'ចំនួនថ្ងៃឈប់',
    'leaveFromDate': 'ឈប់ពីថ្ងៃទី',
    'leaveToDate': 'ដល់ថ្ងៃទី',
    'leaveReason': 'មូលហេតុ',
    'otherReasonHint': 'សូមផ្តល់ព័ត៌មានលម្អិតបន្ថែម...',
    'otherReasonLabel': 'មូលហេតុផ្សេងៗ ',
    'leaveRequestReviewNote': 'សំណើរបស់អ្នកនឹងត្រូវបានពិនិត្យដោយអ្នកគ្រប់គ្រងសាលា។',
    'studentIdCopied': 'បានចម្លងលេខសម្គាល់សិស្ស',
    'sick': 'ឈឺ',
    'busy': 'រវល់',
    'all': 'ទាំងអស់',
    'rejected': 'បានបដិសេធ',
    'loginContinueMessage': 'សូមចូលដើម្បីបន្តប្រើកម្មវិធីរបស់អ្នក',
    'dashboardMenuTuitionFee': 'ថ្លៃសិក្សា',
    'dashboardMenuAttendance': 'វត្តមាន',
    'dashboardMenuRequestLeave': 'ស្នើសុំច្បាប់',
    'dashboardMenuSchedule': 'កាលវិភាគ',
    'dashboardMenuStandings': 'ចំណាត់ថ្នាក់',
    'dashboardMenuAttendanceLog': 'កំណត់ត្រាវត្តមាន',
    'dashboardMenuAttendanceLogTeacher': 'កំណត់ត្រាវត្តមានគ្រូ',
    'dashboardMenuStudentReport': 'របាយការណ៍សិស្ស',
    'dashboardMenuClassActivity': 'សកម្មភាពថ្នាក់',
    'dashboardMenuOnlineCourse': 'កិច្ចការផ្ទះ',
    'dashboardMenuLeaves': 'ច្បាប់ឈប់សម្រាក',
    'dashboardMenuStudentAttendance': 'វត្តមានសិស្ស',
    'dashboardMenuExamination': 'ការប្រឡង',
    'scoreEntryTitle': 'ការបញ្ចូលពិន្ទុ',
    'scoreEntrySubTitle': 'មើលពិន្ទុសិស្សសម្រាប់ថ្នាក់ដែលបានជ្រើសរើស។',
    'scoreEntryTeacherSubTitle': 'បញ្ចូល និងរក្សាទុកពិន្ទុសិស្សសម្រាប់ថ្នាក់របស់អ្នក។',
    'scoreEntryLevel': 'កម្រិត',
    'scoreEntryResultType': 'ប្រភេទលទ្ធផល',
    'scoreEntryMonth': 'ខែ',
    'scoreEntryQuarter': 'ត្រីមាស',
    'scoreEntrySelectResultTypeFirst': 'សូមជ្រើសរើសប្រភេទលទ្ធផលជាមុនសិន',
    'scoreEntrySelectFiltersHint': 'ជ្រើសរើស រួចចុច Filter',
    'scoreEntryNoStudentsFound': 'រកមិនឃើញសិស្សទេ',
    'scoreEntryNoSubjects': 'មិនមានមុខវិជ្ជាសម្រាប់ដាក់ពិន្ទុទេ',
    'scoreEntrySave': 'រក្សាទុក',
    'assessmentManagementTitle': 'ការគ្រប់គ្រងការវាយតម្លៃ',
    'assessmentManagementSubTitle':
        'កត់ត្រាពិន្ទុវាយតម្លៃជាប្រចាំសម្រាប់ថ្នាក់របស់អ្នក។',
    'assessmentManagementSemester': 'ឆមាស',
    'assessmentManagementTeacherComment': 'មតិយោបល់គ្រូ',
    'examinationProgramTitle': 'កម្មវិធី',
    'examinationProgramChineseEnglish': 'ចិន និងអង់គ្លេស',
    'examinationProgramChineseEnglishSubtitle':
        'កម្មវិធីភាសាចិន និងអង់គ្លេស',
    'examinationProgramKhmer': 'ខ្មែរ',
    'examinationProgramKhmerSubtitle': 'កម្មវិធីភាសាខ្មែរ',
    'examinationProgramScoreVerification': 'ការផ្ទៀងផ្ទាត់ពិន្ទុ',
    'examinationProgramScoreVerificationSubtitle':
        'ពិនិត្យ និងផ្ទៀងផ្ទាត់ពិន្ទុដែលបានដាក់ស្នើ',
    'scoreVerificationTitle': 'ការផ្ទៀងផ្ទាត់ពិន្ទុ',
    'scoreVerificationSubTitle':
        'ពិនិត្យពិន្ទុដែលបានដាក់ស្នើដោយគ្រូបង្រៀន មុននឹងចាក់សោ។',
    'scoreVerificationPendingExam': 'ពិន្ទុប្រឡងកំពុងរង់ចាំផ្ទៀងផ្ទាត់',
    'scoreVerificationPendingExamDesc':
        'ពិន្ទុដែលបានដាក់ស្នើសម្រាប់មុខវិជ្ជាប្រឡង កំពុងរង់ចាំផ្ទៀងផ្ទាត់ និងចាក់សោ។',
    'scoreVerificationPendingQuarter': 'ពិន្ទុត្រីមាសកំពុងរង់ចាំផ្ទៀងផ្ទាត់',
    'scoreVerificationPendingQuarterDesc':
        'ពិន្ទុដែលបានដាក់ស្នើតាមរយៈការបញ្ចូលពិន្ទុ កំពុងរង់ចាំផ្ទៀងផ្ទាត់ និងចាក់សោ។',
    'scoreVerificationPendingAssessment':
        'ពិន្ទុវាយតម្លៃកំពុងរង់ចាំផ្ទៀងផ្ទាត់',
    'scoreVerificationPendingAssessmentDesc':
        'ពិន្ទុដែលបានដាក់ស្នើតាមរយៈការគ្រប់គ្រងការវាយតម្លៃ កំពុងរង់ចាំផ្ទៀងផ្ទាត់ និងចាក់សោ។',
    'scoreVerificationNothingPending': 'មិនមានអ្វីរង់ចាំផ្ទៀងផ្ទាត់ទេ។',
    'scoreVerificationExam': 'ប្រឡង',
    'scoreVerificationSession': 'សម័យ',
    'scoreVerificationStudents': 'សិស្ស',
    'scoreVerificationSubmitted': 'បានដាក់ស្នើ',
    'scoreVerificationView': 'មើល',
    'scoreVerificationVerify': 'ផ្ទៀងផ្ទាត់',
    'scoreVerificationVerifyAll': 'ផ្ទៀងផ្ទាត់ទាំងអស់',
    'examinationProgramWeightedResult': 'លទ្ធផល',
    'examinationProgramWeightedResultSubtitle':
        'មើលលទ្ធផលរួមនៃការប្រឡង និងការវាយតម្លៃ',
    'weightedResultTitle': 'លទ្ធផល',
    'weightedResultSubTitle':
        'រួមបញ្ចូលពិន្ទុគ្រប់គ្រងការវាយតម្លៃ និងពិន្ទុប្រឡង '
        'ដោយប្រើភាគរយលក្ខណៈវិនិច្ឆ័យវាយតម្លៃពីការកំណត់សិក្សា។',
    'weightedResultWeightsLabel': 'ភាគរយ៖',
    'weightedResultAdmissionNo': 'លេខចូលរៀន',
    'weightedResultStudent': 'សិស្ស',
    'weightedResultWeightedPercent': 'ភាគរយ',
    'weightedResultGrade': 'និទ្ទេស',
    'weightedResultGpa': 'ពិន្ទុមធ្យម',
    'weightedResultResult': 'លទ្ធផល',
    'weightedResultNoStudentsFound': 'រកមិនឃើញសិស្សទេ។',
    'weightedResultSelectFiltersHint': 'ជ្រើសរើសតម្រង រួចចុច Filter',
    'weightedResultCriterionHomework': 'កិច្ចការផ្ទះ',
    'weightedResultCriterionCommunication': 'ការទំនាក់ទំនង',
    'weightedResultCriterionClasswork': 'កិច្ចការក្នុងថ្នាក់',
    'weightedResultCriterionReflection': 'ការឆ្លុះបញ្ចាំង',
    'weightedResultCriterionBeRespectful': 'គោរពក្នុងថ្នាក់រៀន',
    'weightedResultCriterionStudentsAttention': 'ការយកចិត្តទុកដាក់របស់សិស្ស',
    'weightedResultCriterionTaskResponsibility': 'ទំនួលខុសត្រូវការងារ',
    'weightedResultCriterionWorkIndependently': 'ធ្វើការដោយឯករាជ្យ',
    'weightedResultCriterionStudentsPunctually': 'ការមកទាន់ពេលរបស់សិស្ស',
    'weightedResultCriterionMorality': 'សីលធម៌',
    'examinationProgramViewScore': 'មើលពិន្ទុ',
    'examinationProgramViewScoreSubtitle': 'មើលពិន្ទុវាយតម្លៃដើមសម្រាប់ថ្នាក់មួយ',
    'viewScoreTitle': 'មើលពិន្ទុ',
    'viewScoreSubTitle':
        'ជ្រើសរើសគ្រូបង្រៀនម្នាក់ រួចជ្រើសរើសថ្នាក់មួយក្នុងចំណោមថ្នាក់ដែលបានចាត់តាំង '
        'ដើម្បីមើលពិន្ទុគ្រប់មុខវិជ្ជាដែលគ្រូនោះបង្រៀនក្នុងថ្នាក់នោះ។',
    'viewScoreGender': 'ភេទ',
    'viewScoreNoStudentsFound': 'រកមិនឃើញសិស្សទេ។',
    'viewScoreSelectFiltersHint': 'ជ្រើសរើសតម្រង រួចចុច Filter',
    'recordAttendanceSearchHint': 'ស្វែងរកសិស្ស...',
    'recordAttendanceSelectAllPresent': 'ជ្រើសរើសវត្តមានទាំងអស់',
    'recordAttendanceNoStudentsFound': 'រកមិនឃើញសិស្សទេ',
    'recordAttendanceNoColumn': 'ល.រ',
    'recordAttendanceGender': 'ភេទ',
    'recordAttendanceNote': 'កំណត់ចំណាំ',
    'recordAttendanceEnterNoteHint': 'បញ្ចូលកំណត់ចំណាំ',
    'recordAttendanceSave': 'រក្សាទុក',
    'recordAttendanceSubmit': 'ដាក់ស្នើវត្តមាន',
    'studentAttendanceNoRecordsFound': 'រកមិនឃើញកំណត់ត្រាវត្តមានទេ',
    'welcomeParentPrefix': 'សូមស្វាគមន៍ អាណាព្យាបាល, ',
    'welcomeTeacherPrefix': 'សូមស្វាគមន៍ លោកគ្រូ/អ្នកគ្រូ, ',
    'welcomeParentSubtitle': 'នេះគឺជាផ្ទាំងគ្រប់គ្រងសម្រាប់អាណាព្យាបាល',
    'welcomeTeacherSubtitle': 'នេះគឺជាផ្ទាំងគ្រប់គ្រងសម្រាប់គ្រូបង្រៀន',
    'payments': 'ការទូទាត់',
    'scanner': 'ស្កេន',
    'delivery': 'ការដឹកជញ្ជូន',
    'deliveries': 'ការដឹកជញ្ជូន',
    'more': 'បន្ថែម',
    'language': 'ភាសា',
    'logout': 'ចាកចេញ',
    'cancel': 'បោះបង់',
    'settings': 'ការកំណត់',
    'haveAnAccount': 'មានគណនីរួចហើយ? ',
    'changePassword': 'ប្ដូរពាក្យសម្ងាត់',
    'photoLibrary': 'បណ្ណាល័យរូបថត',
    'camera': 'កាមេរ៉ា',
    'currentPassword': 'ពាក្យសម្ងាត់បច្ចុប្បន្ន',
    'reEnterPassword': 'បញ្ចូលពាក្យសម្ងាត់ម្ដងទៀត',
    'fromDate': 'ចាប់ពីកាលបរិច្ឆេទ',
    'toDate': 'ដល់កាលបរិច្ឆេទ',
    'applyDate': 'កាលបរិច្ឆេទបានអនុវត្ត',
    'approvedBy': 'ដោយអនុវត្តបានទទួល',
    'filterDate': 'ច្រោះតាមកាលបរិច្ឆេទ',
    'termAndCondition': 'លក្ខខណ្ឌប្រើប្រាស់',
    'contact': 'ទំនាក់ទំនង',
    'contactUs': 'ទាក់ទងមកយើង',
    'address': 'អាសយដ្ឋាន',
    'openInGoogleMap': 'បើកក្នុង Google Map',
    'openMap': 'បើកផែនទី',
    'callNow': 'ហៅឥឡូវ',
    'noPackage': 'គ្មានកញ្ចប់',
    'totalAmount': 'ចំនួនសរុប',
    'transfers': 'ការផ្ទេរ',
    'thisTransactionSuccess': 'ប្រតិបត្តិការនេះជោគជ័យ',
    'transaction': 'ប្រតិបត្តិការ',
    'deliveryName': 'ឈ្មោះការដឹកជញ្ជូន',
    'studentProfileInformationSub': 'ព័ត៌មានលម្អិតអំពីប្រវត្តិរូបសិស្ស',
    'amount': 'ចំនួនទឹកប្រាក់',
    'date': 'កាលបរិច្ឆេទ',
    'checkedBy': 'បានពិនិត្យដោយ',
    'packages': 'កញ្ចប់',
    'extraAmountAndTaxi': 'ថ្លៃបន្ថែម និង តាក់ស៊ី',
    'numberOfDelivery': 'ចំនួនការដឹកជញ្ជូន',
    'commissionFee': 'ថ្លៃកម្រៃជើងសារ',
    'location': 'ទីតាំង',
    'phoneNumber': 'លេខទូរស័ព្ទ',
    'changeStatus': 'ប្ដូរស្ថានភាព',
    'dateComplete': 'កាលបរិច្ឆេទបញ្ចប់',
    'transferTo': 'ផ្ទេរទៅ',
    'version': 'កំណែ',
    'ok': 'យល់ព្រម',
    'activitySubTitle': 'សកម្មភាពថ្មីៗរបស់អ្នក',
    'noData': 'គ្មានទិន្នន័យ',
    'noPaymentHistoryFound': 'មិនមានប្រវត្តិការទូទាត់',
    'deliveryScanHasBeenCompleted': 'ការស្កេនការដឹកជញ្ជូនបានបញ្ចប់',
    'driverGetProduct': 'អ្នកបើកបរបានទទួលផលិតផល',
    'product': 'ផលិតផល',
    'error': 'បញ្ហា',
    'invalidQRCodeOrBarCode': 'QR Code ឬ Barcode មិនត្រឹមត្រូវ',
    'paymentAdd': 'បន្ថែមការទូទាត់',
    'deliveryFee': 'ថ្លៃដឹកជញ្ជូន',
    'booking': 'ការកក់',
    'createBooking': 'បង្កើតការកក់',
    'zone': 'តំបន់',
    'destinationPhone': 'លេខទូរស័ព្ទអ្នកទទួល',
    'enterDestinationPhone': 'បញ្ចូលលេខទូរស័ព្ទអ្នកទទួល',
    'bookingDate': 'កាលបរិច្ឆេទកក់',
    'bookingDetails': 'ព័ត៌មានលម្អិតការកក់',
    'typeOfService': 'ប្រភេទសេវាកម្ម',
    'typeOfCod': 'ប្រភេទ CODE',
    'anyExtra': 'មានបន្ថែមទេ',
    'extraAmount': 'ចំនួនទឹកប្រាក់បន្ថែម',
    'anyExtraType': 'ប្រភេទបន្ថែម',
    'serviceFee': 'ថ្លៃសេវា',
    'confirmation': 'ការបញ្ជាក់',
    'enterYourName': 'បញ្ចូលឈ្មោះរបស់អ្នក',
    'areYouSureYouWantToDeleteThisBooking': 'តើអ្នកពិតជាចង់លុបការកក់នេះមែនទេ?',
    'thanksYou': 'សូមអរគុណ',
    'yourBookingHasBeenAdded': 'ការកក់របស់អ្នកត្រូវបានបន្ថែម',
    'yourBookingHasBeenUpdated': 'ការកក់របស់អ្នកត្រូវបានធ្វើបច្ចុប្បន្នភាព',
    'updateBooking': 'ធ្វើបច្ចុប្បន្នភាពការកក់',
    'description': 'ការពិពណ៌នា',
    'enterDescription': 'បញ្ចូលការពិពណ៌នា',
    'destinationZone': 'តំបន់គោលដៅ',
    'image': 'រូបភាព',
    'chooseDestinationZone': 'ជ្រើសរើសតំបន់គោលដៅ',
    'anyExtraServiceCharge': 'មានថ្លៃសេវាបន្ថែមទេ?',
    'typeOfCO': 'ប្រភេទ CO',
    'yes': 'បាទ/ចាស',
    'activity': 'សកម្មភាព',
    'no': 'ទេ',
    'taxi': 'តាក់ស៊ី',
    'other': 'ផ្សេងៗ',
    'normal': 'ធម្មតា',
    'express': 'រហ័ស',
    'destination': 'គោលដៅ',
    'bookingStatus': 'ស្ថានភាពការកក់',
    'receiverPhoneNumber': 'លេខទូរស័ព្ទអ្នកទទួល',
    'deliverySuccess': 'ដឹកជញ្ជូនជោគជ័យ',
    'filterByStatus': 'ច្រោះតាមស្ថានភាព',
    'filterByDate': 'ច្រោះតាមកាលបរិច្ឆេទ',
    'progress': 'កំពុងដំណើរការ',
    'complete': 'បានបញ្ចប់',
    'inStock': 'មានក្នុងស្តុក',
    'filter': 'ច្រោះ',
    'doNotHaveAnAccount': 'មិនមានគណនី? ',
    'register': 'ចុះឈ្មោះ',
    'confirmPassword': 'បញ្ជាក់ពាក្យសម្ងាត់',
    'registerSuccessful': 'ចុះឈ្មោះដោយជោគជ័យ',
    'registerUnavailable':
        'ការបង្កើតគណនីមិនអាចធ្វើបានក្នុងកម្មវិធីទេ។ សូមទាក់ទងការិយាល័យសាលា ដើម្បីទទួលបានគណនីរបស់អ្នក។',
    'typeOfCoc': 'ប្រភេទ COD',
    'deliveryInprogress': 'ការដឹកជញ្ជូនកំពុងដំណើរការ',
    'paymentReceipt': 'វិក្កយបត្រទូទាត់',
    'paymentReport': 'របាយការណ៍ទូទាត់',
    'startDate': 'កាលបរិច្ឆេទចាប់ផ្តើម',
    'endDate': 'កាលបរិច្ឆេទបញ្ចប់',
    'reason': 'មូលហេតុ',
    'profile': 'ប្រវត្តិរូប',
    'totalIncome': 'ចំណូលសរុប',
    'area': 'តំបន់',
    'getDate': 'កាលបរិច្ឆេទទទួល',
    'releaseDate': 'កាលបរិច្ឆេទចេញផ្សាយ',
    'bonus': 'ប្រាក់រង្វាន់',
    'finish': 'បញ្ចប់',
    'attendanceSubTitle': 'តាមដានវត្តមានសិស្ស និងព័ត៌មានចូលចេញ',
    'attendanceTeacherSubTitle': 'តាមដានវត្តមានគ្រូ និងសកម្មភាពស្កេន',
    'attendanceRecordTeacherSubTitle':
        'មើលកំណត់ត្រាវត្តមានគ្រូ និងកំណត់ត្រាស្កេន',
    'scheduleTeacherSubTitle': 'មើលកាលវិភាគបង្រៀន និងម៉ោងសិក្សារបស់អ្នក',
    'requestLeaveTeacherSubTitle': 'ដាក់ស្នើ និងគ្រប់គ្រងសំណើសុំច្បាប់របស់គ្រូ',
    'allRequestedLeaveTeacherSubTitle':
        'ពិនិត្យសំណើសុំច្បាប់គ្រូដែលបានដាក់ស្នើ',
    'activityTeacherSubTitle': 'មើលសកម្មភាពថ្នាក់ដែលបានចែករំលែកសម្រាប់គ្រូ',
    'onlineCoursesTeacherSubTitle': 'មើលវគ្គសិក្សាអនឡាញ និងធនធានបង្រៀន',
    'onlineClassTitle': 'កិច្ចការផ្ទះ',
    'onlineClassParentSubtitle': 'មើលសកម្មភាព កិច្ចការផ្ទះ និងការជូនដំណឹង',
    'onlineClassTeacherSubtitle':
        'គ្រប់គ្រងសកម្មភាពថ្នាក់ កិច្ចការផ្ទះ ការជូនដំណឹង និងការបញ្ជូនការងារ',
    'onlineClassTeacherWorkbench': 'ផ្ទាំងការងារគ្រូ',
    'onlineClassTeacherWorkbenchSubtitle':
        'បង្កើតសកម្មភាព ផ្តល់កិច្ចការផ្ទះ និងពិនិត្យការងារសិស្ស',
    'onlineClassParentOverview': 'ទិដ្ឋភាពមាតាបិតា',
    'onlineClassParentOverviewSubtitle':
        'តាមដានកិច្ចការផ្ទះ ការជូនដំណឹង និងសកម្មភាពថ្នាក់',
    'onlineClassSubmissions': 'ការបញ្ជូន',
    'onlineClassTotalClass': 'ថ្នាក់សរុប',
    'onlineClassStudents': 'សិស្ស',
    'onlineClassDueToday': 'ដល់ថ្ងៃនេះ',
    'onlineClassActivities': 'សកម្មភាព',
    'onlineClassTeachingTools': 'ឧបករណ៍បង្រៀន',
    'onlineClassQuickActions': 'សកម្មភាពរហ័ស',
    'onlineClassSubmissionReview': 'ពិនិត្យការបញ្ជូន',
    'onlineClassLatestUpdates': 'បច្ចុប្បន្នភាពថ្មីៗ',
    'onlineClassStudentSubmissionReview': 'ពិនិត្យការបញ្ជូនរបស់សិស្ស',
    'onlineClassHomeworkFilesWaiting': 'មានឯកសារកិច្ចការផ្ទះ ៨ កំពុងរង់ចាំ',
    'onlineClassHomeworkDeadlineSetting': 'កំណត់ថ្ងៃផុតកំណត់កិច្ចការផ្ទះ',
    'onlineClassSetDueDate': 'កំណត់ថ្ងៃផុតកំណត់សម្រាប់កិច្ចការថ្មី',
    'onlineClassReceiveNotifications': 'ទទួលការជូនដំណឹង',
    'onlineClassNewAnnouncement': 'មានសេចក្តីជូនដំណឹងថ្នាក់ថ្មី',
    'onlineClassUploadHomeworkSubmission': 'បញ្ចូលការបញ្ជូនកិច្ចការផ្ទះ',
    'onlineClassReadyToUpload': 'រួចរាល់បញ្ចូលបន្ទាប់ពីធ្វើកិច្ចការរួច',
    'onlineClassHomeworkStatus': 'ស្ថានភាពកិច្ចការផ្ទះ',
    'onlineClassHomeworkDone': 'រួច ២/៣',
    'onlineClassHomeworkNeedsSubmission': 'នៅមានកិច្ចការផ្ទះមួយត្រូវបញ្ជូន',
    'onlineClassActionClassActivity': 'សកម្មភាពថ្នាក់',
    'onlineClassActionClassDetail': 'ព័ត៌មានថ្នាក់',
    'onlineClassActionViewClassInfo': 'មើលព័ត៌មានថ្នាក់',
    'onlineClassActionPostUpdate': 'បង្ហោះបច្ចុប្បន្នភាព',
    'onlineClassActionAssignHomework': 'ផ្តល់កិច្ចការផ្ទះ',
    'onlineClassActionAllAssignHomework': 'កិច្ចការផ្ទះដែលបានដាក់',
    'onlineClassActionCreateTask': 'បង្កើតកិច្ចការ',
    'onlineClassActionNotifyClass': 'ជូនដំណឹងថ្នាក់',
    'onlineClassActionSendMessage': 'ផ្ញើសារ',
    'onlineClassActionAllSubmit': 'ការបញ្ជូនទាំងអស់',
    'onlineClassActionReviewSubmissions': 'ពិនិត្យការបញ្ជូន',
    'onlineClassActionUploadFiles': 'បញ្ចូលឯកសារ',
    'onlineClassActionAddMaterials': 'បន្ថែមសម្ភារៈ',
    'onlineClassActionActivities': 'សកម្មភាព',
    'onlineClassActionClassMoments': 'រូបភាពថ្នាក់',
    'onlineClassActionHomework': 'កិច្ចការផ្ទះ',
    'onlineClassActionViewTasks': 'មើលកិច្ចការ',
    'onlineClassActionComplete': 'បំពេញ',
    'onlineClassActionDoHomework': 'ធ្វើកិច្ចការផ្ទះ',
    'onlineClassActionSubmit': 'បញ្ជូន',
    'onlineClassActionUploadWork': 'បញ្ចូលការងារ',
    'onlineClassActionNotifications': 'ការជូនដំណឹង',
    'onlineClassActionMessages': 'សារ',
    'onlineClassSelectClass': 'ជ្រើសរើសថ្នាក់',
    'onlineClassLoadingClassList': 'កំពុងផ្ទុកបញ្ជីថ្នាក់...',
    'onlineClassNoClassAvailable': 'មិនមានថ្នាក់',
    'onlineClassNoClassAvailableYet': 'មិនទាន់មានបញ្ជីថ្នាក់ទេ។',
    'onlineClassPleaseSelectClass': 'សូមជ្រើសរើសថ្នាក់។',
    'onlineClassMissingClassId': 'ថ្នាក់នេះមិនមានលេខសម្គាល់ថ្នាក់ទេ។',
    'onlineClassStudentList': 'បញ្ជីសិស្ស',
    'onlineClassHomeworkTitle': 'កិច្ចការផ្ទះ:',
    'onlineClassEnterHomeworkTitle': 'បញ្ចូលចំណងជើងកិច្ចការផ្ទះ',
    'onlineClassHomeworkDescription': 'សេចក្តីណែនាំ ឬការពិពណ៌នាកិច្ចការផ្ទះ',
    'onlineClassEnterHomeworkDescription': 'បញ្ចូលសេចក្តីណែនាំ ឬការពិពណ៌នា',
    'onlineClassUploadFile': 'បញ្ចូលឯកសារ',
    'onlineClassUploadPicture': 'បញ្ចូលរូបភាព',
    'onlineClassUploadPictureOrPdf': 'បញ្ចូលរូបភាព ឬ PDF',
    'onlineClassMessageToStudents': 'សារទៅកាន់សិស្ស',
    'onlineClassNotificationStudents': 'បង្ហាញសិស្សដែលនឹងទទួលបានសារ',
    'onlineClassAllStudentSubmissions': 'ការបញ្ជូនរបស់សិស្សទាំងអស់',
    'onlineClassViewEachStudent': 'មើលការបញ្ជូនរបស់សិស្សម្នាក់ៗ',
    'onlineClassSubmitted': 'បានបញ្ជូន',
    'onlineClassPending': 'កំពុងរង់ចាំ',
    'onlineClassView': 'មើល',
    'onlineClassDeadline': 'ថ្ងៃផុតកំណត់',
    'onlineClassEdit': 'កែប្រែ',
    'onlineClassDelete': 'លុប',
    'onlineClassDeleteConfirm': 'តើអ្នកប្រាកដថាចង់លុបកិច្ចការផ្ទះនេះមែនទេ?',
    'onlineClassDeletedSuccessfully': 'បានលុបកិច្ចការផ្ទះដោយជោគជ័យ។',
    'onlineClassUpdatedSuccessfully': 'បានកែប្រែកិច្ចការផ្ទះដោយជោគជ័យ។',
    'onlineClassNoHomeworkHereYet': 'មិនទាន់មានកិច្ចការផ្ទះនៅទីនេះទេ។',
    'onlineClassLoadingHomework': 'កំពុងផ្ទុកកិច្ចការផ្ទះ...',
    'onlineClassLoadingHomeworkSubtitle':
        'សូមរង់ចាំខណៈដែលយើងកំពុងផ្ទុកកិច្ចការផ្ទះដែលបានផ្តល់។',
    'onlineClassSubmitting': 'កំពុងបញ្ជូន...',
    'onlineClassAttachHomework': 'បើក',
    'onlineClassSuccessTitle': 'ជោគជ័យ',
    'onlineClassHomeworkSubmittedSuccessfully':
        'បានបញ្ជូនកិច្ចការផ្ទះដោយជោគជ័យ។',
    'onlineClassSubmitHomework': 'បញ្ជូនកិច្ចការផ្ទះ',
    'onlineClassSubmitHomeworkSubtitle':
        'ឆ្លើយសំណួរ ហើយភ្ជាប់រូបភាពប្រសិនបើចាំបាច់។',
    'onlineClassYourAnswer': 'ចម្លើយរបស់អ្នក',
    'onlineClassWriteAnswerHint': 'សរសេរចម្លើយរបស់អ្នកនៅទីនេះ...',
    'onlineClassAttachment': 'ឯកសារភ្ជាប់',
    'onlineClassAttachImage': 'ភ្ជាប់រូបភាព',
    'onlineClassImageReadyToUpload': 'បានជ្រើសរូបភាពរួចរាល់សម្រាប់បញ្ជូន។',
    'onlineClassOptionalChooseImage': 'ជាជម្រើស។ ជ្រើសរូបភាពមួយពីវិចិត្រសាល។',
    'onlineClassPreviewUnavailable': 'មិនអាចមើលជាមុនបានទេ',
    'onlineClassReadyToSubmit': 'រួចរាល់សម្រាប់បញ្ជូន។ អ្នកបានបន្ថែម',
    'onlineClassAddedAnswer': 'ចម្លើយមួយ',
    'onlineClassNoWrittenAnswer': 'មិនមានចម្លើយជាលាយលក្ខណ៍អក្សរ',
    'onlineClassAndImage': 'និងរូបភាពមួយ។',
    'onlineClassAddAnswerOrImage':
        'សូមបន្ថែមចម្លើយជាលាយលក្ខណ៍អក្សរ ឬភ្ជាប់រូបភាព មុនពេលបញ្ជូន។',
    'studentDocumentTeacherSubTitle': 'ពិនិត្យព័ត៌មានប្រវត្តិរូប និងឯកសារសិស្ស',
    'standingsTeacherSubTitle': 'ពិនិត្យចំណាត់ថ្នាក់សិស្ស និងលទ្ធផលពិន្ទុ',
    'paymentCollectionTeacherSubTitle':
        'ពិនិត្យព័ត៌មានប្រមូលការទូទាត់របស់សិស្ស',
    'monthJanuary': 'មករា',
    'monthFebruary': 'កុម្ភៈ',
    'monthMarch': 'មីនា',
    'monthApril': 'មេសា',
    'monthMay': 'ឧសភា',
    'monthJune': 'មិថុនា',
    'monthJuly': 'កក្កដា',
    'monthAugust': 'សីហា',
    'monthSeptember': 'កញ្ញា',
    'monthOctober': 'តុលា',
    'monthNovember': 'វិច្ឆិកា',
    'monthDecember': 'ធ្នូ',
    'returned': 'បានត្រឡប់',
    'choose': 'ជ្រើសរើស',
    'detailOfPayments': 'ព័ត៌មានលម្អិតការទូទាត់',
    'qrCode': 'QR Code',
    'viewDetails': 'មើលលម្អិត',
    'clear': 'សម្អាត',
    'notification': 'ការជូនដំណឹង',
    'successfulGetProduct': 'ទទួលផលិតផលដោយជោគជ័យ',
    'successfulFinishDelivery': 'បញ្ចប់ការដឹកជញ្ជូនដោយជោគជ័យ',
    'paymentMethods': 'វិធីសាស្ត្រទូទាត់',
    'status': 'ស្ថានភាព',
    'chooseDate': 'ជ្រើសរើសកាលបរិច្ឆេទ',
    'uploadImage': 'បង្ហោះរូបភាព',
    'successfullyRegister': 'ចុះឈ្មោះដោយជោគជ័យ',
    'permission': 'ការអនុញ្ញាត',
    'noPermission': 'អ្នកមិនមានការអនុញ្ញាត',
    'congratulation': 'សូមអបអរសាទរ',
    'youHaveSuccessfullyChangedThePassword':
        'អ្នកបានប្ដូរពាក្យសម្ងាត់ដោយជោគជ័យ',
    'cannotNavigationToDetailsScreen': 'មិនអាចទៅកាន់អេក្រង់លម្អិតបាន',
    'pending': 'កំពុងរង់ចាំ',
    'problem': 'បញ្ហា',
    'companyPhoneNumber': 'លេខទូរស័ព្ទក្រុមហ៊ុន',
    'paymentType': 'ប្រភេទការទូទាត់',
    'yourBooking': 'ការកក់របស់អ្នក',
    'tracking': 'ការតាមដាន',
    'invoiceId': 'លេខវិក្កយបត្រ',
    'invoiceDetails': 'ព័ត៌មានលម្អិតវិក្កយបត្រ',
    'noInvoiceDetailsFound': 'មិនមានព័ត៌មានលម្អិតវិក្កយបត្រ',
    'studentPaymentInformation': '១. ព័ត៌មានការទូទាត់របស់សិស្ស',
    'paymentHistorySection': '២. ប្រវត្តិការទូទាត់',
    'noLabel': 'ល.រ',
    'typeLabel': 'ប្រភេទ',
    'invoiceLabel': 'វិក្កយបត្រ',
    'search': 'ស្វែងរក',
    'searchNotFound': 'រកមិនឃើញ',
    'deleteAccount': 'លុបគណនី',
    'deleteAccountMessage':
        'តើអ្នកពិតជាចង់លុបគណនីរបស់អ្នកមែនទេ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។',
    'youHaveSuccesfulyDeletedYourAccount': 'អ្នកបានលុបគណនីដោយជោគជ័យ',
    'startBillcreate': 'ចាប់ផ្តើមបង្កើតវិក្កយបត្រ',
    'endBillCreate': 'បញ្ចប់បង្កើតវិក្កយបត្រ',
    'startBillFinish': 'ចាប់ផ្តើមបញ្ចប់វិក្កយបត្រ',
    'endBillFinish': 'បញ្ចប់វិក្កយបត្រ',
    'filterDelivery': 'ច្រោះការដឹកជញ្ជូន',
    'chooseDeliveyStatus': 'ជ្រើសរើសស្ថានភាពដឹកជញ្ជូន',
    'completeDate': 'កាលបរិច្ឆេទបញ្ចប់',
    'featureTemporarilyUnavailable':
        'មុខងារនេះមិនអាចប្រើបានបណ្តោះអាសន្នទេ។ សូមព្យាយាមម្តងទៀតនៅពេលក្រោយ។',
    'teacher': 'គ្រូបង្រៀន',
    'parent': 'អាណាព្យាបាល',
    'phoneOrEmail': 'លេខទូរស័ព្ទ ឬ អ៊ីមែល',
    'signingIn': 'កំពុងចូល...',
    'signUp': 'ចុះឈ្មោះ',
    'sendCode': 'ផ្ញើកូដ',
    'forgotPasswordDescription':
        'សូមបញ្ចូលលេខទូរស័ព្ទគណនីរបស់អ្នក ដើម្បីកំណត់ពាក្យសម្ងាត់ឡើងវិញ។',
    'rememberYourPassword': 'ចាំពាក្យសម្ងាត់បានហើយ? ',
    'backToLogin': 'ត្រឡប់ទៅចូល',
    'needHelp': 'ត្រូវការជំនួយ ? ',
    'contactSupport': 'ទាក់ទងផ្នែកជំនួយ',
    'verificationCodeSent': 'កូដផ្ទៀងផ្ទាត់ត្រូវបានផ្ញើ។',
    'next': 'បន្ទាប់',
    'change': 'ប្ដូរ',
    'transfer': 'ផ្ទេរ',
    'done': 'រួចរាល់',
    'submit': 'បញ្ជូន',
    'update': 'ធ្វើបច្ចុប្បន្នភាព',
    'apply': 'អនុវត្ត',
    'commend': 'មតិយោបល់',
    //————————————————————haysan——————————————————————//
    'present': 'វត្តមាន',
    'paid': 'បានបង់',
    'unpaid': 'មិនទាន់បង់',
    'absent': 'អវត្តមាន',
    'late': 'យឺត',
    'allDates': 'កាលបរិច្ឆេទទាំងអស់',
    'breakTime': 'ពេលសម្រាក',
    'morning': 'ព្រឹក',
    'afternoon': 'រសៀល',
    'evening': 'ល្ងាច',
    'grade': 'ចំណាត់ថ្នាក់',
    'subject': 'មុខវិជ្ជា',
    'score': 'ពិន្ទុ',
    'math': 'គណិតវិទ្យា',
    'khmer': 'ភាសាខ្មែរ',
    'english': 'ភាសាអង់គ្លេស',
    'history': 'ប្រវត្តិវិទ្យា',
    'biology': 'ជីវវិទ្យា',
    'chemistry': 'គីមីវិទ្យា',
    'to': 'ទៅកាន់',
    'prending': 'កំពុងរង់ចាំ',
    'approved': 'បានអនុម័ត',
    'reject': 'បដិសេធ',
    'leaveDuration': 'រយៈពេលប្រវត្តិ',
    'view': 'មើល',
    'noDataFound': 'គ្មានទិន្នន័យទេ',
    'detailedReason': 'លម្អិតពណ៌នាទេ',
    'attachments': 'ឯកសារភ្ជាប់',
    'document': 'ឯកសារ',
    'section': 'វេន',
    'leaveDay': 'ថ្ងៃស្នើសុំច្បាប់',
    'leaveDaysUnit': 'ចំនួនថ្ងៃស្នើសុំច្បាប់',
    'selectDate': 'ជ្រើសរើសកាលបរិច្ឆេទ',
    'sectionLabel': 'វេន',
    'classSectionLabel': 'ថ្នាក់/វេន',
    'subjectLabel': 'មុខវិជ្ជា',
    'teacherActivityFeed': 'កំណត់ត្រាវត្តមានគ្រូបង្រៀន',
    'studentActivityFeed': 'កំណត់ត្រាវត្តមានសិស្ស',
    'noClassActivitiesFound': 'មិនមានសកម្មភាពថ្នាក់ទីនេះទេ',
    'createActivity': 'បង្កើតសកម្មភាព',
    'tapToViewTheFullActivityDetails': 'ចុចដើម្បីមើលព័ត៌មានលម្អិតទាំងអស់',
    'editActivity': 'កែសម្រួលសកម្មភាព',
    'activityTitleEmpty': 'ចំណងជើងសកម្មភាពមិនអាចទទេបានទេ',
    'activityDescriptionEmpty': 'ការពិពណ៌នាមិនអាចទទេបានទេ',
    'activityTitleLabel': 'ចំណងជើងសកម្មភាព',
    'descriptionLabel': 'ការពិពណ៌នា',
    'coverImageOptionalHint':
        'បន្ថែមរូបភាពបានរហូតដល់ ១០សន្លឹក ដើម្បីធ្វើឲ្យកាតសកម្មភាពទាក់ទាញជាងមុន។',
    'coverImageReplaceHint':
        'បន្ថែមរូបភាពថ្មី ឬលុបរូបភាពដែលមានស្រាប់នៅខាងក្រោម។',
    'chooseImage': 'ជ្រើសរើសរូបភាព',
    'changeImage': 'បន្ថែមរូបភាព',
    'maxImagesReachedMessage': 'អ្នកអាចបន្ថែមរូបភាពបានរហូតដល់ ១០សន្លឹក។',
    'imageRemovalNotSupportedMessage':
        'រូបភាពនេះមិនអាចលុបចេញពីម៉ាស៊ីនមេបានទេ ហើយនឹងបង្ហាញឡើងវិញបន្ទាប់ពីរក្សាទុក។',
    'activityContent': 'មាតិកាសកម្មភាព',
    'activityContentSubtitle':
        'សរសេរចំណងជើង និងការពិពណ៌នាសង្ខេបដែលសិស្សគួរអានមុនគេ។',
    'activityTitleHint': 'ចំណងជើង',
    'noClassAvailable': 'មិនមានថ្នាក់ទេ',
    'selectClass': 'ជ្រើសរើសថ្នាក់',
    'classTarget': 'ថ្នាក់គោលដៅ',
    'classTargetSubtitle': 'ជ្រើសរើសថ្នាក់ណាមួយដែលនឹងទទួលសកម្មភាពនេះ។',
    'createAndNotifyStudents': 'បង្កើត និងជូនដំណឹងដល់សិស្ស',
    'submitting': 'កំពុងដាក់ស្នើ...',
    'updateActivity': 'ធ្វើបច្ចុប្បន្នភាពសកម្មភាព',
    'success': 'ជោគជ័យ',
    'activityUpdatedSuccess': 'សកម្មភាពត្រូវបានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ',
    'activityCreatedSuccess': 'សកម្មភាពត្រូវបានបង្កើតដោយជោគជ័យ',
    'pleaseSelectClass': 'សូមជ្រើសរើសថ្នាក់',
    'descriptionHint': 'សរសេរសេចក្តីសង្ខេបខ្លីមួយ។',
    'imageSelectedReady': 'បានជ្រើសរើសរូបភាព និងត្រៀមខ្លួនសម្រាប់ផ្ទុកឡើង។',
    'coverImage': 'រូបភាព',
    'coverImageSubtitle':
        'បន្ថែមរូបភាពរហូតដល់ ១០សន្លឹក ដើម្បីធ្វើឲ្យកាតសកម្មភាពទាក់ទាញជាងមុន។',
    'deleting': 'កំពុងលុប...',
    'deleteActivity': 'លុបសកម្មភាព',
    'confirmDeleteMessage': 'តើអ្នកប្រាកដថាចង់លុបសកម្មភាពនេះមែនទេ?',
    'activityDeletedSuccess': 'សកម្មភាពត្រូវបានលុបដោយជោគជ័យ',
    'delete': 'លុប',
    'noDescriptionProvided': 'មិនមានការពិពណ៌នាសម្រាប់សកម្មភាពនេះទេ។',
    'activityDetails': 'ព័ត៌មានលម្អិតសកម្មភាព',
    'activityDetailsSubtitle':
        'អ្វីៗទាំងអស់ដែលសិស្សគួរដឹងមុននឹងបើក ឬឆ្លើយតបទៅនឹងសកម្មភាពថ្នាក់នេះ។',
    'classActivity': 'សកម្មភាពថ្នាក់',
    'timeLabel': 'ពេលវេលា',
    'noticesLabel': 'កំណត់ត្រាលដោយ',
    'taLabel': 'ត្រូវបានអនុវត្ត',
  };
}
