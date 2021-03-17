class OnboardingModel {
  int id;
  String onboarding;

  OnboardingModel({this.id, this.onboarding});

  factory OnboardingModel.fromJson(Map<String, dynamic> data) {
    return OnboardingModel(
      id: data['id'],
      onboarding: data['onboarding'],
    );
  }
  //Just returning id for db update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
