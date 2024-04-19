import 'dart:convert';
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/common/common_single_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_history_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_price_first_last_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_summary_performance_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_list_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_performance_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class WatchlistAPI {
  Future<List<WatchlistListModel>> getWatchlist(String type) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/$type'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get list of watchlist
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<WatchlistListModel> listWatchlist = [];
    for (var data in commonModel.data) {
      WatchlistListModel watchlist = WatchlistListModel.fromJson(data['attributes']);
      listWatchlist.add(watchlist);
    }
    return listWatchlist;
  }

  Future<WatchlistListModel> findSpecific(String type, int id) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/find/$type/id/$id'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get detailed watchlist information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    WatchlistListModel watchlist = WatchlistListModel.fromJson(commonModel.data['attributes']);
    return watchlist;
  }

  Future<WatchlistListModel> add(String type, int companyId) async {
    // post the watchlist data using netutils
    final String body = await NetUtils.post(
      url: Globals.apiWatchlists,
      body: {'watchlist_company_id': companyId, 'watchlist_company_type': type}
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get watchlist information that we just added
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    WatchlistListModel watchlist = WatchlistListModel.fromJson(commonModel.data['attributes']);
    return watchlist;
  }

  Future<bool> delete(int watchlistId) async {
    // delete the watchlist data using netutils
    await NetUtils.delete(
      url: '${Globals.apiWatchlists}/$watchlistId',
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // if delete success, then return true
    return true;
  }

  Future<List<WatchlistDetailListModel>> addDetail(int id, DateTime date, double shares, double price) async {
    // post the watchlist details data using netutils
    final String body = await NetUtils.post(
      url: Globals.apiWatchlistDetails,
      body: {
        'watchlist_detail_share': shares,
        'watchlist_detail_price': price,
        'watchlist_detail_date': date.toUtc().toIso8601String(),
        'watchlist_detail_watchlist_id': id
      }
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get watchlist detail information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<WatchlistDetailListModel> watchlistDetail = [];
    for (var data in commonModel.data) {
      WatchlistDetailListModel detail = WatchlistDetailListModel.fromJson(data['attributes']);
      watchlistDetail.add(detail);
    }
    return watchlistDetail;
  }

  Future<bool> deleteDetail(int id) async {
    // delete the watchlist details data using netutils
    await NetUtils.delete(
      url: '${Globals.apiWatchlistDetails}/$id',
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // if delete success, then return true
    return true;
  }

  Future<bool> updateDetail(int id, DateTime date, double shares, double price) async {
    // patch the watchlist details data using netutils
    await NetUtils.put(
      url: '${Globals.apiWatchlistDetails}/$id',
      body: {
        'watchlist_detail_share': shares,
        'watchlist_detail_price': price,
        'watchlist_detail_date': date.toUtc().toIso8601String()
      },
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // return true if update success
    return true;
  }

  Future<List<WatchlistDetailListModel>> findDetail(int companyId) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/detail/$companyId'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the detail for specific watchlist
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<WatchlistDetailListModel> watchlistDetail = [];
    for (var data in commonModel.data) {
      WatchlistDetailListModel detail = WatchlistDetailListModel.fromJson(data['attributes']);
      watchlistDetail.add(detail);
    }
    return watchlistDetail;
  }

  Future<List<WatchlistPerformanceModel>> getWatchlistPerformance(String type, int id) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/performance/$type/$id'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the watchlist performance list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<WatchlistPerformanceModel> listWatchlistPerformance = [];
    for (var data in commonModel.data) {
      WatchlistPerformanceModel watchlist = WatchlistPerformanceModel.fromJson(data['attributes']);
      listWatchlistPerformance.add(watchlist);
    }
    return listWatchlistPerformance;
  }

  Future<List<WatchlistPerformanceModel>> getWatchlistPerformanceMonthYear(String type, int id, int month, int year) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/performance/$type/$id/month/$month/year/$year'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the watchlist performance list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<WatchlistPerformanceModel> listWatchlistPerformance = [];
    for (var data in commonModel.data) {
      WatchlistPerformanceModel watchlist = WatchlistPerformanceModel.fromJson(data['attributes']);
      listWatchlistPerformance.add(watchlist);
    }
    return listWatchlistPerformance;
  }

  Future<List<WatchlistPerformanceModel>> getWatchlistPerformanceYear(String type, int id, int year) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/performance/$type/$id/year/$year'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the watchlist performance list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<WatchlistPerformanceModel> listWatchlistPerformance = [];
    for (var data in commonModel.data) {
      WatchlistPerformanceModel watchlist = WatchlistPerformanceModel.fromJson(data['attributes']);
      listWatchlistPerformance.add(watchlist);
    }
    return listWatchlistPerformance;
  }

  Future<List<SummaryPerformanceModel>> getWatchlistPerformanceSummary(String type) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/performance/summary/$type'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the watchlist performance summary list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SummaryPerformanceModel> listWatchlistPerformance = [];
    for (var data in commonModel.data) {
      SummaryPerformanceModel watchlist = SummaryPerformanceModel.fromJson(data['attributes']);
      listWatchlistPerformance.add(watchlist);
    }
    return listWatchlistPerformance;
  }

  Future<List<SummaryPerformanceModel>> getWatchlistPerformanceSummaryMonthYear(String type, int month, int year) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/performance/summary/$type/month/$month/year/$year'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the watchlist performance summary list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SummaryPerformanceModel> listWatchlistPerformance = [];
    for (var data in commonModel.data) {
      SummaryPerformanceModel watchlist = SummaryPerformanceModel.fromJson(data['attributes']);
      listWatchlistPerformance.add(watchlist);
    }
    return listWatchlistPerformance;
  }

  Future<List<SummaryPerformanceModel>> getWatchlistPerformanceSummaryYear(String type, int year) async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/performance/summary/$type/year/$year'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the watchlist performance list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SummaryPerformanceModel> listWatchlistPerformance = [];
    for (var data in commonModel.data) {
      SummaryPerformanceModel watchlist = SummaryPerformanceModel.fromJson(data['attributes']);
      listWatchlistPerformance.add(watchlist);
    }
    return listWatchlistPerformance;
  }

  Future<List<WatchlistHistoryModel>> getWatchlistHistory() async {
    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiWatchlists}/history'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the watchlist history list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<WatchlistHistoryModel> listWatchlistHistory = [];
    for (var data in commonModel.data) {
      WatchlistHistoryModel watchlist = WatchlistHistoryModel.fromJson(data['attributes']);
      listWatchlistHistory.add(watchlist);
    }
    return listWatchlistHistory;
  }

  Future<WatchlistPriceFirstAndLastDateModel> findFirstLastDate(String type, int? id) async {
    // create the base url
      String url = '${Globals.apiWatchlists}/firstlast/$type';
      
      // in case this is not all, then add the id on the back
      if (type.toLowerCase() != 'all') {
        url += '/$id';
      }

    // get the watchlist data using netutils
    final String body = await NetUtils.get(
      url: url
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the watchlist response data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    WatchlistPriceFirstAndLastDateModel watchlist = WatchlistPriceFirstAndLastDateModel.fromJson(commonModel.data['attributes']);
    return watchlist;
  }
}