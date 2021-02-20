import 'package:Dukkank/src/helpers/helper.dart';
import 'package:Dukkank/src/models/coupon.dart';
import 'package:Dukkank/src/repository/coupon_repository.dart';
import 'package:Dukkank/src/repository/settings_repository.dart';
import 'package:Dukkank/src/repository/user_repository.dart';

import '../../src/models/product.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../repository/cart_repository.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }


  void listenForCarts({String message}) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          coupon = _cart.product.applyCoupon(coupon);
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    listenForCarts(message: S.current.carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      listenForCarts();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_product_was_removed_from_your_cart),
      ));
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    total=0;
    taxAmount=0;
    carts.forEach((cart) {
      subTotal += cart.quantity * cart.product.price; //if(cart.product.store.)
      if (Helper.canDelivery(carts: carts)) {
        deliveryFee = cart.product.store.deliveryFee;
      }
      //deliveryFee += cart.product.store.deliveryFee;
      taxAmount = (subTotal + deliveryFee) * cart.product.store.defaultTax / 100;
    });
    //deliveryFee = carts[0].product.store.deliveryFee;
    //taxAmount = (subTotal + deliveryFee) * carts[0].product.store.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
    setState(() {});
  }

  void doApplyCoupon(String code, {String message}) async {
    coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen((Coupon _coupon) async {
      coupon = _coupon;
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
    });
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <double.parse(cart.product.itemsAvailable)){
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout(BuildContext context) {
    if (!currentUser.value.profileCompleted()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(context).settings,
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
        Navigator.of(context).pushNamed('/DeliveryPickup');
      }
  }

  Color getCouponIconColor() {
    if (coupon?.valid == true) {
      return Colors.green;
    } else if (coupon?.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(context).focusColor.withOpacity(0.7);
  }
}
