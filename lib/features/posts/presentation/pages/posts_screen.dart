import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_card.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PostsBloc>().add(const PostsLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostsBloc>().add(const PostsLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.8);
  }

  Future<void> _onRefresh() async {
    context.read<PostsBloc>().add(const PostsRefreshRequested());
    await context.read<PostsBloc>().stream.firstWhere(
          (state) => state is! PostsLoading,
        );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social App'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton(
                  icon: CircleAvatar(
                    backgroundImage: state.user.image != null
                        ? NetworkImage(state.user.image!)
                        : null,
                    child: state.user.image == null
                        ? Text(state.user.firstName[0])
                        : null,
                  ),
                  itemBuilder: (context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            state.user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          Duration.zero,
                          () => _handleLogout(),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, authState) {
          return BlocBuilder<PostsBloc, PostsState>(
            builder: (context, state) {
              if (state is PostsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PostsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<PostsBloc>().add(
                                const PostsLoadRequested(),
                              );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is PostsLoaded) {
                if (state.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.post_add,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No posts yet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      if (index >= state.posts.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return PostCard(post: state.posts[index]);
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}

