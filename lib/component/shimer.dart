import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Shimer {
  static Widget buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.onSecondary.withOpacity(1),
            highlightColor: Color(0xFF73FA92).withOpacity(0.5),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget buildShimmerLoadingforPie() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Shimmer.fromColors(
        baseColor: Colors.black.withOpacity(0.5),
        highlightColor: Colors.white.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  static Widget buildShimmerLoadingforClients(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 6,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  static Widget buildShimmerLoadingforCharts(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 3,
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
