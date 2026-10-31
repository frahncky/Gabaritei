# O shared_preferences_android 2.5 chama o Kotlin via JNI, procurando métodos
# pela assinatura original. Sem isto o R8 renomeia estes tipos no release, o
# plugin falha com NoSuchMethodError e o app não sai do splash.
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.Unit { *; }
-keep class kotlin.enums.EnumEntries { *; }
-keep class kotlin.jvm.internal.DefaultConstructorMarker { *; }
