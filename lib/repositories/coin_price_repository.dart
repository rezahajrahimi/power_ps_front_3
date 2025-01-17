// import 'package:dio/dio.dart';

// Future getLastCoinPriceByKraken({required String symbol}) async {
//   try {
//     Response response =
//         await KrakenApi.dio.get("/0/public/Ticker?pair=${symbol}USD",
//             // data: {"pair": "USDt"},
//             options: Options(headers: {
//               'Accept': 'application/json',
//               'Connection': 'keep-alive',
//               "Charset": "utf-8",
//               'Access-Control-Allow-Origin': '*'
//             }));
//     if (response.statusCode == 200) {
//       var data = response.data["result"];
//       List myList = [];
//       List priceList = [];
//       if (data != null) {
//         data.forEach((k, v) => myList.add((v)));
//         var data2 = myList[0];
//         Map apiResponse = data2;
//         apiResponse.forEach((key, value) {
//           priceList.add(value);
//         });
//         var price = priceList[2][0];
//         return price;
//       } else {
//         return;
//       }
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getLastCoinPriceByKucoin({required String symbol}) async {
//   try {
//     Response response = await KuCoinApi.dio
//         .get("/api/v1/market/orderbook/level1?symbol=$symbol-USDT",
//             options: Options(headers: {
//               'Accept': 'application/json',
//               'Connection': 'keep-alive',
//               "Charset": "utf-8",
//               'Access-Control-Allow-Origin': '*'
//             }));
//     if (response.statusCode == 200) {
//       Map apiResponse = response.data["data"];
//       List priceList = [];

//       apiResponse.forEach((key, value) {
//         priceList.add(value);
//       });
//       var price = priceList[2];

//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getLastCoinPriceByNobitex({required String symbol}) async {
//   try {
//     Response response = await NobitexApi.dio.get("/v2/trades/${symbol}USDT",
//         options: Options(headers: {
//           'Accept': 'application/json',
//           'Connection': 'keep-alive',
//           "Charset": "utf-8",
//           'Access-Control-Allow-Origin': '*'
//         }));
//     if (response.statusCode == 200) {
//       Map data = response.data;
//       List myList = data.values.toList();
//       List data2 = myList[1];
//       var price = data2[0];
//       price = price["price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getUSDTPriceByNobitex() async {
//   try {
//     Response response = await NobitexApi.dio.get("/v2/trades/USDTIRT",
//         options: Options(headers: {
//           'Accept': 'application/json',
//           'Connection': 'keep-alive',
//           "Charset": "utf-8",
//           'Access-Control-Allow-Origin': '*'
//         }));
//     if (response.statusCode == 200) {
//       Map data = response.data;
//       List myList = data.values.toList();
//       List data2 = myList[1];
//       var price = data2[0];
//       price = price["price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByNobitex(
//     {required String symbol, required String pair}) async {
//   try {
//     Response response = await NobitexApi.dio.get("/v2/trades/$symbol$pair",
//         options: Options(headers: {
//           'Accept': 'application/json',
//           'Connection': 'keep-alive',
//           "Charset": "utf-8",
//           'Access-Control-Allow-Origin': '*'
//         }));
//     if (response.statusCode == 200) {
//       Map data = response.data;
//       List myList = data.values.toList();
//       List data2 = myList[1];
//       var price = data2[0];
//       price = price["price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByTabdeal(
//     {required String symbol, required String pair}) async {
//   try {
//     Response response =
//         await TabdealApi.dio.get("/api/v1/trades?symbol=$symbol$pair&limit=1",
//             options: Options(headers: {
//               'Accept': 'application/json',
//               'Connection': 'keep-alive',
//               "Charset": "utf-8",
//               'Access-Control-Allow-Origin': '*'
//             }));
//     if (response.statusCode == 200) {
//       var price = response.data[0]["price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByRaastin(
//     {required String symbol, required String pair}) async {
//   try {
//     Response response = await RaastinApi.dio
//         .get("/api/v1/market/trades/?limit=1&symbol=$symbol$pair",
//             options: Options(headers: {
//               'Accept': 'application/json',
//               'Connection': 'keep-alive',
//               "Charset": "utf-8",
//               'Access-Control-Allow-Origin': '*'
//             }));
//     if (response.statusCode == 200) {
//       var price = response.data["results"][0]["price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByWallex(
//     {required String symbol, required String pair}) async {
//   try {
//     Response response =
//         await WallexApi.dio.get("/v1/trades?symbol=$symbol$pair",
//             options: Options(headers: {
//               'Accept': 'application/json',
//               'Connection': 'keep-alive',
//               "Charset": "utf-8",
//               'Access-Control-Allow-Origin': '*'
//             }));

//     if (response.statusCode == 200) {
//       var price = response.data["result"]["latestTrades"][0]["price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByOkex(
//     {required String symbol, required String pair}) async {
//   try {
//     Response response =
//         await OkexApi.dio.get("/oapi/v1/market/ticker?symbol=$symbol-$pair",
//             options: Options(headers: {
//               'Accept': 'application/json',
//               'Connection': 'keep-alive',
//               "Charset": "utf-8",
//               'Access-Control-Allow-Origin': '*'
//             }));
//     if (response.statusCode == 200) {
//       var price = response.data["ticker"]["last"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByBitpin({required BigInt cryptoID}) async {
//   try {
//     Response response = await BitpinApi.dio.get("/v1/mth/matches/$cryptoID/",
//         options: Options(headers: {
//           'Accept': 'application/json',
//           'Connection': 'keep-alive',
//           "Charset": "utf-8",
//           'Access-Control-Allow-Origin': '*'
//         }));

//     if (response.statusCode == 200) {
//       var price = response.data[0]["price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByOmpfinex({required BigInt cryptoID}) async {
//   try {
//     Response response = await OmpfinexApi.dio.get("/v1/market/$cryptoID",
//         options: Options(headers: {
//           'Accept': 'application/json',
//           'Connection': 'keep-alive',
//           "Charset": "utf-8",
//           'Access-Control-Allow-Origin': '*'
//         }));
//     if (response.statusCode == 200) {
//       var price = response.data["data"]["last_price"];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }

// Future getPairPriceByRamzinex({required BigInt cryptoID}) async {
//   try {
//     Response response = await RamzinexApi.dio
//         .get("/exchange/api/v1.0/exchange/orderbooks/$cryptoID/trades",
//             options: Options(headers: {
//               'Accept': 'application/json',
//               'Connection': 'keep-alive',
//               "Charset": "utf-8",
//               'Access-Control-Allow-Origin': '*'
//             }));
//     if (response.statusCode == 200) {
//       var price = response.data["data"][0][0];
//       return price;
//     } else {
//       return;
//     }
//   } catch (e) {
//     return;
//   }
// }
