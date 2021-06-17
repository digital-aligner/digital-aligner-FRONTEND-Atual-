class OnboardingModel {
  int id;
  String onboarding;

  OnboardingModel({this.id = 0, this.onboarding = ''});

  factory OnboardingModel.fromJson(Map<String, dynamic> data) {
    if (data.isEmpty) {
      data = {
        'id': -1,
        'onboarding': '',
      };
    }
    return OnboardingModel(
      id: data['id'] ?? 0,
      onboarding: data['onboarding'] ?? '',
    );
  }
  //Just returning id for db update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
