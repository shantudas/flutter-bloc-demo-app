class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String currentUser = '/auth/me';

  // Posts endpoints
  static const String posts = '/posts';
  static String postById(int id) => '/posts/$id';
  static const String addPost = '/posts/add';
  static String updatePost(int id) => '/posts/$id';
  static String deletePost(int id) => '/posts/$id';
  static const String searchPosts = '/posts/search';

  // Comments endpoints
  static const String comments = '/comments';
  static String commentsByPost(int postId) => '/comments/post/$postId';
  static const String addComment = '/comments/add';

  // Users endpoints
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
}

