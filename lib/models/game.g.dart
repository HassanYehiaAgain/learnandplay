// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
      id: json['id'] as String,
      ownerUid: json['ownerUid'] as String,
      template: _templateFromJson(json['template'] as String),
      title: json['title'] as String,
      gradeYears: (json['gradeYears'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      subject: json['subject'] as String,
      isTutorial: json['isTutorial'] as bool? ?? false,
      createdAt: _tsFromJson(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
      'id': instance.id,
      'ownerUid': instance.ownerUid,
      'template': _templateToJson(instance.template),
      'title': instance.title,
      'gradeYears': instance.gradeYears,
      'subject': instance.subject,
      'isTutorial': instance.isTutorial,
      'createdAt': _tsToJson(instance.createdAt),
    };
