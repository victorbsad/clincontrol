import '../database/db_helper.dart';
import '../models/service.dart';

class ServiceRepository {
  final DbHelper _db = DbHelper();

  Future<int> save(Service atendimento) => _db.insertService(atendimento);
  Future<double> getMonthlyTotal(int month, int year) => _db.fetchMonthlyTotal(month, year);
  Future<int> getMonthlyCount(int month, int year) => _db.fetchMonthlyCount(month, year);
}