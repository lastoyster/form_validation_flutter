import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:form_validation_flutter/core/network/network_info.dart';
import 'package:form_validation_flutter/data/data_source/province.dart';
import 'package:form_validation_flutter/repository/province.dart';
import 'package:form_validation_flutter/view_model/bloc/province_bloc.dart';

final sl = GetIt.instance;

void init() {
  //BLOC
  sl.registerFactory(
    () => ProvinceBloc(provinceRepositoryImpl: sl()),
  );

  //Repository
  sl.registerLazySingleton<ProvinceRepository>(
      () => ProvinceRepositoryImpl(dataSourceImpl: sl(), info: sl()));
  sl.registerLazySingleton<ProvinceRemoteDataSource>(
      () => ProvinceRemoteDataSourceImpl());

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker());
}
