.PHONY: help dev-run dev-build-apk dev-build-ios prod-run prod-build-apk prod-build-ios prod-build-appbundle clean generate install-deps

# Default target
help:
	@echo "Flutter Build Commands"
	@echo "======================"
	@echo ""
	@echo "Development:"
	@echo "  make dev-run              - Run app in development mode"
	@echo "  make dev-build-apk        - Build development APK"
	@echo "  make dev-build-ios        - Build development iOS app"
	@echo ""
	@echo "Production:"
	@echo "  make prod-run             - Run app in production mode (for testing)"
	@echo "  make prod-build-apk       - Build production APK"
	@echo "  make prod-build-ios       - Build production iOS app"
	@echo "  make prod-build-appbundle - Build production App Bundle for Play Store"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean                - Clean build artifacts"
	@echo "  make generate             - Run code generation"
	@echo "  make install-deps         - Install dependencies"
	@echo ""

# ============ Development Commands ============

dev-run:
	@echo "🚀 Running app in DEVELOPMENT mode..."
	@if [ -f .env.dev ]; then \
		echo "📄 Loading environment from .env.dev"; \
		export $$(cat .env.dev | grep -v '^#' | xargs) && \
		flutter run \
			-t lib/main_dev.dart \
			--flavor dev \
			--dart-define=ENV=$$ENV \
			--dart-define=API_BASE_URL=$$API_BASE_URL \
			--dart-define=FIREBASE_API_KEY=$$FIREBASE_API_KEY \
			--dart-define=FIREBASE_APP_ID=$$FIREBASE_APP_ID \
			--dart-define=FIREBASE_MESSAGING_SENDER_ID=$$FIREBASE_MESSAGING_SENDER_ID \
			--dart-define=FIREBASE_PROJECT_ID=$$FIREBASE_PROJECT_ID \
			--dart-define=ENCRYPTION_KEY=$$ENCRYPTION_KEY \
			--dart-define=APP_NAME="$$APP_NAME" \
			--dart-define=APPLICATION_ID=$$APPLICATION_ID; \
	else \
		echo "❌ ERROR: .env.dev file is required for development builds"; \
		echo "Create it from .env.example: cp .env.example .env.dev"; \
		exit 1; \
	fi

dev-build-apk:
	@echo "📦 Building development APK..."
	@if [ -f .env.dev ]; then \
		echo "📄 Loading environment from .env.dev"; \
		export $$(cat .env.dev | grep -v '^#' | xargs) && \
		flutter build apk \
			-t lib/main_dev.dart \
			--flavor dev \
			--debug \
			--dart-define=ENV=$$ENV \
			--dart-define=API_BASE_URL=$$API_BASE_URL \
			--dart-define=FIREBASE_API_KEY=$$FIREBASE_API_KEY \
			--dart-define=FIREBASE_APP_ID=$$FIREBASE_APP_ID \
			--dart-define=FIREBASE_MESSAGING_SENDER_ID=$$FIREBASE_MESSAGING_SENDER_ID \
			--dart-define=FIREBASE_PROJECT_ID=$$FIREBASE_PROJECT_ID \
			--dart-define=ENCRYPTION_KEY=$$ENCRYPTION_KEY \
			--dart-define=APP_NAME="$$APP_NAME" \
			--dart-define=APPLICATION_ID=$$APPLICATION_ID; \
	else \
		echo "❌ ERROR: .env.dev file is required for development builds"; \
		echo "Create it from .env.example: cp .env.example .env.dev"; \
		exit 1; \
	fi

dev-build-ios:
	@echo "📱 Building development iOS app..."
	@if [ -f .env.dev ]; then \
		echo "📄 Loading environment from .env.dev"; \
		export $$(cat .env.dev | grep -v '^#' | xargs) && \
		flutter build ios \
			-t lib/main_dev.dart \
			--debug \
			--dart-define=ENV=$$ENV \
			--dart-define=API_BASE_URL=$$API_BASE_URL \
			--dart-define=FIREBASE_API_KEY=$$FIREBASE_API_KEY \
			--dart-define=FIREBASE_APP_ID=$$FIREBASE_APP_ID \
			--dart-define=FIREBASE_MESSAGING_SENDER_ID=$$FIREBASE_MESSAGING_SENDER_ID \
			--dart-define=FIREBASE_PROJECT_ID=$$FIREBASE_PROJECT_ID \
			--dart-define=ENCRYPTION_KEY=$$ENCRYPTION_KEY \
			--dart-define=APP_NAME="$$APP_NAME" \
			--dart-define=APPLICATION_ID=$$APPLICATION_ID; \
	else \
		echo "❌ ERROR: .env.dev file is required for development builds"; \
		echo "Create it from .env.example: cp .env.example .env.dev"; \
		exit 1; \
	fi

# ============ Production Commands ============

prod-run:
	@echo "🚀 Running app in PRODUCTION mode..."
	@echo "⚠️  Note: This is for testing only. Production builds should be deployed, not run directly."
	@if [ -f .env.prod ]; then \
		echo "📄 Loading environment from .env.prod"; \
		export $$(cat .env.prod | grep -v '^#' | xargs) && \
		flutter run \
			-t lib/main_prod.dart \
			--flavor prod \
			--release \
			--dart-define=ENV=prod \
			--dart-define=API_BASE_URL=$$API_BASE_URL \
			--dart-define=FIREBASE_API_KEY=$$FIREBASE_API_KEY \
			--dart-define=FIREBASE_APP_ID=$$FIREBASE_APP_ID \
			--dart-define=FIREBASE_MESSAGING_SENDER_ID=$$FIREBASE_MESSAGING_SENDER_ID \
			--dart-define=FIREBASE_PROJECT_ID=$$FIREBASE_PROJECT_ID \
			--dart-define=ENCRYPTION_KEY=$$ENCRYPTION_KEY; \
	else \
		echo "❌ ERROR: .env.prod file is required for production builds"; \
		exit 1; \
	fi

prod-build-apk:
	@echo "📦 Building production APK..."
	@if [ -f .env.prod ]; then \
		echo "📄 Loading environment from .env.prod"; \
		export $$(cat .env.prod | grep -v '^#' | xargs) && \
		flutter build apk \
			-t lib/main_prod.dart \
			--flavor prod \
			--release \
			--obfuscate \
			--split-debug-info=build/symbols \
			--dart-define=ENV=prod \
			--dart-define=API_BASE_URL=$$API_BASE_URL \
			--dart-define=FIREBASE_API_KEY=$$FIREBASE_API_KEY \
			--dart-define=FIREBASE_APP_ID=$$FIREBASE_APP_ID \
			--dart-define=FIREBASE_MESSAGING_SENDER_ID=$$FIREBASE_MESSAGING_SENDER_ID \
			--dart-define=FIREBASE_PROJECT_ID=$$FIREBASE_PROJECT_ID \
			--dart-define=ENCRYPTION_KEY=$$ENCRYPTION_KEY; \
	else \
		echo "❌ ERROR: .env.prod file is required for production builds"; \
		exit 1; \
	fi

prod-build-ios:
	@echo "📱 Building production iOS app..."
	@if [ -f .env.prod ]; then \
		echo "📄 Loading environment from .env.prod"; \
		export $$(cat .env.prod | grep -v '^#' | xargs) && \
		flutter build ios \
			-t lib/main_prod.dart \
			--release \
			--obfuscate \
			--split-debug-info=build/symbols \
			--dart-define=ENV=prod \
			--dart-define=API_BASE_URL=$$API_BASE_URL \
			--dart-define=FIREBASE_API_KEY=$$FIREBASE_API_KEY \
			--dart-define=FIREBASE_APP_ID=$$FIREBASE_APP_ID \
			--dart-define=FIREBASE_MESSAGING_SENDER_ID=$$FIREBASE_MESSAGING_SENDER_ID \
			--dart-define=FIREBASE_PROJECT_ID=$$FIREBASE_PROJECT_ID \
			--dart-define=ENCRYPTION_KEY=$$ENCRYPTION_KEY; \
	else \
		echo "❌ ERROR: .env.prod file is required for production builds"; \
		exit 1; \
	fi

prod-build-appbundle:
	@echo "📦 Building production App Bundle for Play Store..."
	@if [ -f .env.prod ]; then \
		echo "📄 Loading environment from .env.prod"; \
		export $$(cat .env.prod | grep -v '^#' | xargs) && \
		flutter build appbundle \
			-t lib/main_prod.dart \
			--flavor prod \
			--release \
			--obfuscate \
			--split-debug-info=build/symbols \
			--dart-define=ENV=prod \
			--dart-define=API_BASE_URL=$$API_BASE_URL \
			--dart-define=FIREBASE_API_KEY=$$FIREBASE_API_KEY \
			--dart-define=FIREBASE_APP_ID=$$FIREBASE_APP_ID \
			--dart-define=FIREBASE_MESSAGING_SENDER_ID=$$FIREBASE_MESSAGING_SENDER_ID \
			--dart-define=FIREBASE_PROJECT_ID=$$FIREBASE_PROJECT_ID \
			--dart-define=ENCRYPTION_KEY=$$ENCRYPTION_KEY; \
	else \
		echo "❌ ERROR: .env.prod file is required for production builds"; \
		exit 1; \
	fi

# ============ Utility Commands ============

clean:
	@echo "🧹 Cleaning project..."
	flutter clean
	@echo "✅ Clean complete"

generate:
	@echo "⚙️  Running code generation..."
	flutter pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Code generation complete"

install-deps:
	@echo "📥 Installing dependencies..."
	flutter pub get
	@echo "✅ Dependencies installed"

# Combined commands for convenience
rebuild: clean install-deps generate
	@echo "✅ Project rebuilt successfully"

dev-fresh: clean install-deps generate dev-run
	@echo "✅ Fresh development build started"

prod-fresh: clean install-deps generate prod-build-appbundle
	@echo "✅ Fresh production build complete"

