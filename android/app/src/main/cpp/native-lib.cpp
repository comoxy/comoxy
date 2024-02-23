#include <jni.h>
#include <string>


extern "C"
JNIEXPORT jstring JNICALL
Java_com_rating_buzzle_MainActivity_EncryptionKey(JNIEnv *env, jclass clazz) {
    std::string hello = "abc";
    return env->NewStringUTF(hello.c_str());
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_rating_buzzle_MainActivity_SecretKey(JNIEnv *env, jclass clazz) {
    std::string hello = "12345abcdefghtuv";
    return env->NewStringUTF(hello.c_str());
}