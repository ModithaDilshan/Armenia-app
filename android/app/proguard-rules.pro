# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Firebase Auth
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Firestore
-keep class com.google.firebase.firestore.** { *; }

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# Keep all model classes
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName *;
}

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Prevent stripping of methods/fields with these annotations
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
