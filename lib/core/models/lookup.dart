// lib/core/models/lookup_domain.dart

class LookupDomain {
  final int lookupDomainId;
  final String domainNameArabic;
  final String domainNameEnglish;
  final DateTime? syncDateTime;
  final DateTime? modifyDateTime;
  final List<LookupDomainDetail> domainDetails;

  LookupDomain({
    required this.lookupDomainId,
    required this.domainNameArabic,
    required this.domainNameEnglish,
    this.syncDateTime,
    this.modifyDateTime,
    required this.domainDetails,
  });

  factory LookupDomain.fromJson(Map<String, dynamic> json) {
    final detailsJson = (json['domainDetails'] as List?) ?? const [];
    final details = detailsJson
        .map((e) => LookupDomainDetail.fromJson(e as Map<String, dynamic>))
        .toList();

    return LookupDomain(
      lookupDomainId: json['lookupDomainId'],
      domainNameArabic: json['domainNameArabic'],
      domainNameEnglish: json['domainNameEnglish'],
      syncDateTime: json['syncDateTime'] != null
          ? DateTime.parse(json['syncDateTime'])
          : null,
      modifyDateTime: json['modifyDateTime'] != null
          ? DateTime.parse(json['modifyDateTime'])
          : null,
      domainDetails: details,
    );
  }
}

// lib/core/models/lookup_domain_detail.dart
class LookupDomainDetail {
  final int lookupDomainDetailId;
  final String detailNameArabic;
  final String detailNameEnglish;
  final int lookupDomainId;
  final DateTime? syncDateTime;
  final DateTime? modifyDateTime;

  LookupDomainDetail({
    required this.lookupDomainDetailId,
    required this.detailNameArabic,
    required this.detailNameEnglish,
    required this.lookupDomainId,
    this.syncDateTime,
    this.modifyDateTime,
  });

  factory LookupDomainDetail.fromJson(Map<String, dynamic> json) =>
      LookupDomainDetail(
        lookupDomainDetailId: json['lookupDomainDetailId'],
        detailNameArabic: json['detailNameArabic'],
        detailNameEnglish: json['detailNameEnglish'],
        lookupDomainId: json['lookupDomainId'],
        syncDateTime: json['syncDateTime'] != null
            ? DateTime.parse(json['syncDateTime'])
            : null,
        modifyDateTime: json['modifyDateTime'] != null
            ? DateTime.parse(json['modifyDateTime'])
            : null,
      );
}
