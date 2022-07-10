import 'package:bloc/bloc.dart';
import 'package:ecom/repositories/cart_repository.dart';

import '../../../common/classes/pagination_manager.dart';
import '../../../models/response/product_entity.dart';
import '../../../repositories/products_repository.dart';


part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductsRepository _productsRepository;
  final CartRepository _cartRepository;
  ProductCubit(this._productsRepository, this._cartRepository) : super(ProductInitial()){
    loadsProducts();
  }

  final paginationManager = PaginationManager<ProductEntity>();

  Future<void> loadsProducts() async {
    paginationManager.startFetching(fetcher: (page) async {
      final response = await _productsRepository.getProducts(page);
      if (response.status == 200) {
        return PaginationResponse.success(list: response.data!, lastPage: response.totalPage!);
      } else {
        return PaginationResponse.error();
      }
    }, postCallback: (isSuccess, list){
      if(isSuccess) {
        emit(ProductLoaded(list));
      } else {
        emit(ProductLoadError(list));
      }
    });
  }

  void addToCart(ProductEntity entity){
    _cartRepository.addToCart(entity);
  }
}
