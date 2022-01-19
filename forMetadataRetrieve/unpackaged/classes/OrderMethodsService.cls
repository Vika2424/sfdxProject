/**
 * Created by vpelykh on 18.01.2022.
 */

public with sharing class OrderMethodsService {

    public static List<Order> getDraftOrdersOfCurrentUser() {

        Id userId = UserInfo.getUserId();
        List<Order> ordersWithOrderProducts = new List<Order>();
        for (Order order : OrderMethodsSelector.selectDraftOrdersOfCurrentUser(userId)) {
            if (order.OrderItems.size() > 0) {
                ordersWithOrderProducts.add(order);
            }
        }
        return ordersWithOrderProducts;
    }
}