import 'package:Dukkank/src/repository/settings_repository.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';

import '../../src/helpers/ui_icons.dart';

class CartBottomDetailsWidget extends StatelessWidget {
  const CartBottomDetailsWidget({
    Key key,
    @required CartController con,
  })  : _con = con,
        super(key: key);

  final CartController _con;

  @override
  Widget build(BuildContext context) {
    if (_con.carts.isEmpty) {
      return SizedBox(height: 0);
    } else {
      return Container(
        height: 130,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).focusColor.withOpacity(0.15),
                  offset: Offset(0, -2),
                  blurRadius: 5.0)
            ]),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.text,
                onSubmitted: (String value) {
                  _con.doApplyCoupon(value);
                },
                cursorColor: Theme.of(context).accentColor,
                controller: TextEditingController()..text = coupon?.code ?? '',
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintStyle: Theme.of(context).textTheme.bodyText1,
                  suffixText: coupon?.valid == null
                      ? ''
                      : (coupon.valid
                          ? S.of(context).validCouponCode
                          : S.of(context).invalidCouponCode),
                  suffixStyle: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(color: _con.getCouponIconColor())),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                      UiIcons.money,
                      color: _con.getCouponIconColor(),
                      size: 28,
                    ),
                  ),
                  hintText: S.of(context).haveCouponCode,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                ),
              ),
              Stack(
                fit: StackFit.loose,
                alignment: AlignmentDirectional.centerEnd,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: FlatButton(
                      onPressed: () {
                        _con.goCheckout(context);
                      },
                      disabledColor:
                          Theme.of(context).focusColor.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      color: Theme.of(context).accentColor,
                      shape: StadiumBorder(),
                      child: Text(
                        S.of(context).checkout,
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Helper.getPrice(
                      _con.total,
                      context,
                      style: Theme.of(context).textTheme.display1.merge(
                          TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
