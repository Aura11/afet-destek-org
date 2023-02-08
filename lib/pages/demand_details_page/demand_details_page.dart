import 'package:deprem_destek/data/models/demand.dart';
import 'package:deprem_destek/data/repository/auth_repository.dart';
import 'package:deprem_destek/gen/assets.gen.dart';
import 'package:deprem_destek/pages/demand_details_page/widgets/call_button.dart';
import 'package:deprem_destek/pages/demand_details_page/widgets/whatsapp_button.dart';
import 'package:deprem_destek/pages/demands_page/widgets/demand_card.dart';
import 'package:deprem_destek/shared/state/app_cubit.dart';
import 'package:deprem_destek/shared/widgets/infobox.dart';
import 'package:deprem_destek/shared/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class DemandDetailsPage extends StatelessWidget {
  const DemandDetailsPage._({required this.demand});
  final Demand demand;

  static Future<void> show(
    BuildContext context, {
    required Demand demand,
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return DemandDetailsPage._(demand: demand);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = context.read<AppCubit>().state.whenOrNull(
          loaded: (currentLocation, demandCategories) => currentLocation,
        );

    if (currentLocation == null) {
      return const Scaffold(body: Loader());
    }

    return StreamBuilder<User?>(
      stream: context.read<AuthRepository>().userStream,
      builder: (context, snapshot) {
        final authorized = snapshot.data != null;
        return _DemandDetailsPageView(
          isAuthorized: authorized,
          demand: demand,
        );
      },
    );
  }
}

class _DemandDetailsPageView extends StatelessWidget {
  const _DemandDetailsPageView({
    required this.isAuthorized,
    required this.demand,
  });
  final Demand demand;
  final bool isAuthorized;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SvgPicture.asset(Assets.logoSvg),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Yardım Talebi',
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Color(0xff101828),
                ),
              ),
              DemandCard(demand: demand, isDetailed: true),
              const SizedBox(height: 8),
              const Infobox(
                info: '''
                      Bu kişinin kimliği tarafımızca doğrulanmamıştır.
                      Lütfen dikkatli olunuz.''',
              ),
              const SizedBox(height: 8),
              WhatsappButton(phoneNumber: demand.phoneNumber),
              const SizedBox(height: 8),
              CallButton(phoneNumber: demand.phoneNumber),
              const SizedBox(height: 32),
              const Text(
                'GSM operatörlerindeki yoğunluk sebebiyle '
                'arama yerine SMS kullanmayı tercih ediniz.',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
