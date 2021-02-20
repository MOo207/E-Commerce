import 'package:Dukkank/src/repository/settings_repository.dart';
import 'package:Dukkank/src/widgets/CartBottomDetailsWidget.dart';

import '../../src/helpers/ui_icons.dart';
import '../../src/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../widgets/CartItemWidget.dart';
import '../widgets/EmptyCartWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class CartWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  CartWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {
  CartController _con;

  _CartWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(
                UiIcons.return_icon,
                color: Theme.of(context).hintColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).cart,
            style: Theme.of(context).textTheme.title.merge(TextStyle(letterSpacing: 1.3)),
          ),
          actions: <Widget>[
            Container(
              width: 30,
              height: 30,
              margin: EdgeInsetsDirectional.only(top: 12.5, bottom: 12.5, end: 20),
              //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(300),
                onTap: () {
                  currentUser.value.apiToken != null
                      ? Navigator.of(context).pushNamed('/Pages',arguments: 1)
                      : Navigator.of(context).pushNamed('/Login');
                },
                child: currentUser.value.apiToken != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(currentUser.value.image.thumb),
                )
                    :Icon(
                  Icons.person,
                  size: 26,
                  color: Theme.of(context).accentColor.withOpacity(1),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CartBottomDetailsWidget(con: _con),
        body: RefreshIndicator(
          onRefresh: _con.refreshCarts,
          child: _con.carts.isEmpty
              ? EmptyCartWidget()
              : SingleChildScrollView(
                child: Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                                padding: const EdgeInsets.only(left: 20, right: 10),
                                //padding: const EdgeInsetsDirectional.only(start: 20, end: 10),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    UiIcons.shopping_cart,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).shopping_cart,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                  subtitle: Text(
                                    S.of(context).verify_your_quantity_and_click_checkout,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ),
                              ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).subtotal,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                              ),
                              Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subhead)
                            ],
                          ),
                          SizedBox(height: 2),
                          ListView.separated(
                                padding: EdgeInsets.symmetric(vertical: 0),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                primary: false,
                                itemCount: _con.carts.length,
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 2);
                                },
                                itemBuilder: (context, index) {
                                  return CartItemWidget(
                                    cart: _con.carts.elementAt(index),
                                    heroTag: 'cart',
                                    taxAmount: _con.taxAmount,
                                    increment: () {
                                      _con.incrementQuantity(
                                          _con.carts.elementAt(index));
                                    },
                                    decrement: () {
                                      _con.decrementQuantity(
                                          _con.carts.elementAt(index));
                                    },
                                    onDismissed: () {
                                      _con.removeFromCart(
                                          _con.carts.elementAt(index));
                                    },
                                  );
                                },
                              ),
                        ],
                      ),
                      ],
                  ),
              ),
        ),
      ),
    );
  }
}
