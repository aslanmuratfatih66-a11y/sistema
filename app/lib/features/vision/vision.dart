// Публичное API раздела «Фото-анализ» (SPEC §9.4): точки входа для экранов питания, тела, финансов.
export 'body_analysis.dart'
    show analyzeBodyPhoto, analyzeSkinPhoto, showPhotoAnalysis, BodyAnalysisView, SkinAnalysisView, VisionOutcome;
export 'food_photo_flow.dart' show showFoodPhotoFlow, FoodPhotoFlowScreen;
export 'receipt_flow.dart' show showReceiptFlow;
export 'vision_api.dart';
export 'vision_common.dart' show VisionRead, EstimateBadge, visionLang, visionErrorText;
export 'vision_repository.dart';
