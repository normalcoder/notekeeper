#include <stdio.h>

#if __LP64__
typedef double CGFloat;
#else
typedef float CGFloat;
#endif

struct CGFloat { CGFloat a[1]; };
struct CGFloat2 { CGFloat a[2]; };
struct CGFloat4 { CGFloat a[4]; };
struct CGFloat6 { CGFloat a[6]; };
struct CGFloat16 { CGFloat a[16]; };
struct Float { float a[1]; };
struct Float2 { float a[2]; };
struct Double { double a[1]; };
struct Double2 { double a[2]; };
// struct Long { long a[1]; };
// struct Bool { char a[1]; };

int sizeOfCGFloat() { return sizeof(CGFloat); }

#if __arm64__
void objc_msgSend();
static void *fRet = (void *)objc_msgSend;
static void *f = (void *)objc_msgSend;
#else
void objc_msgSend();
void objc_msgSend_stret();
static void *fRet = (void *)objc_msgSend_stret;
static void *f = (void *)objc_msgSend;
#endif

void * floatToPtr(float f) {
 union {
  void * p;
  float f;
 } v;
 v.p = 0;
 v.f = f;
 return v.p;
}

// void * doubleToPtr(double d) {
//  union {
//   void * p;
//   float f;
//  } v;
//  v.p = 0;
//  v.f = f;
//  return v.p;
// }


void * objc_msgSend_stapply_CGFloat(void * obj, void * sel, struct CGFloat * a1) { return ((void * (*)(void *, void *, struct CGFloat))f)(obj, sel, *a1); }
void * objc_msgSend_stapply_CGFloat2(void * obj, void * sel, struct CGFloat2 * a1) { return ((void * (*)(void *, void *, struct CGFloat2))f)(obj, sel, *a1); }
void * objc_msgSend_stapply_CGFloat4(void * obj, void * sel, struct CGFloat4 * a1) { return ((void * (*)(void *, void *, struct CGFloat4))f)(obj, sel, *a1); }
void * objc_msgSend_stapply_CGFloat6(void * obj, void * sel, struct CGFloat6 * a1) { return ((void * (*)(void *, void *, struct CGFloat6))f)(obj, sel, *a1); }
void * objc_msgSend_stapply_CGFloat16(void * obj, void * sel, struct CGFloat16 * a1) { return ((void * (*)(void *, void *, struct CGFloat16))f)(obj, sel, *a1); }
// void * objc_msgSend_stapply_Float(void * obj, void * sel, struct Float * a1) { return ((void * (*)(void *, void *, struct Float))f)(obj, sel, *a1); }

void *objc_msgSend_apply_CGFloat_x4(void * obj, void * sel, CGFloat a1, CGFloat a2, CGFloat a3, CGFloat a4) { return ((void * (*)(void *, void *, CGFloat, CGFloat, CGFloat, CGFloat))f)(obj, sel, a1, a2, a3, a4); }


void * objc_msgSend_stapply_Float2(void * obj, void * sel, struct Float2 * a1) { return ((void * (*)(void *, void *, struct Float2))f)(obj, sel, *a1); }
void * objc_msgSend_stapply_Double(void * obj, void * sel, struct Double * a1) {
 struct Double a2;
 a2.a[0] = a1->a[0];
 return ((void * (*)(void *, void *, struct Double))f)(obj, sel, a2);
}
void * objc_msgSend_stapply_Float(void * obj, void * sel, struct Float * a1) {
 struct Float a2;
 a2.a[0] = a1->a[0];
 return ((void * (*)(void *, void *, struct Float))f)(obj, sel, a2);
}
void * objc_msgSend_stapply_Double2(void * obj, void * sel, struct Double2 * a1) { return ((void * (*)(void *, void *, struct Double2))f)(obj, sel, *a1); }
// void * objc_msgSend_stapply_Long(void * obj, void * sel, struct Long * a1) { return ((void * (*)(void *, void *, struct Long))f)(obj, sel, *a1); }
// void * objc_msgSend_stapply_Bool(void * obj, void * sel, struct Bool * a1) { return ((void * (*)(void *, void *, struct Bool))f)(obj, sel, *a1); }

// void objc_msgSend_stret_CGFloat(void * obj, void * sel, struct CGFloat * r, void * a1) { *r = ((struct CGFloat (*)(void *, void *, void *))fRet)(obj, sel, a1); }
void objc_msgSend_stret_CGFloat2(void * obj, void * sel, struct CGFloat2 * r) { *r = ((struct CGFloat2 (*)(void *, void *))f)(obj, sel); }
void objc_msgSend_stret_CGFloat2_apply_ptr(void * obj, void * sel, struct CGFloat2 * r, void * a1) { *r = ((struct CGFloat2 (*)(void *, void *, void *))f)(obj, sel, a1); }
void objc_msgSend_stret_CGFloat4(void * obj, void * sel, struct CGFloat4 * r, void * a1) { *r = ((struct CGFloat4 (*)(void *, void *, void *))fRet)(obj, sel, a1); }
void objc_msgSend_stret_CGFloat6(void * obj, void * sel, struct CGFloat6 * r, void * a1) { *r = ((struct CGFloat6 (*)(void *, void *, void *))fRet)(obj, sel, a1); }
void objc_msgSend_stret_CGFloat16(void * obj, void * sel, struct CGFloat16 * r, void * a1) { *r = ((struct CGFloat16 (*)(void *, void *, void *))fRet)(obj, sel, a1); }
// void objc_msgSend_stret_Float(void * obj, void * sel, struct Float * r, void * a1) { *r = ((struct Float (*)(void *, void *, void *))fRet)(obj, sel, a1); }
void objc_msgSend_stret_Float2(void * obj, void * sel, struct Float2 * r, void * a1) { *r = ((struct Float2 (*)(void *, void *, void *))fRet)(obj, sel, a1); }
// void objc_msgSend_stret_Double(void * obj, void * sel, struct Double * r, void * a1) { *r = ((struct Double (*)(void *, void *, void *))fRet)(obj, sel, a1); }
void objc_msgSend_stret_Double2(void * obj, void * sel, struct Double2 * r, void * a1) { *r = ((struct Double2 (*)(void *, void *, void *))fRet)(obj, sel, a1); }
// void objc_msgSend_stret_Long(void * obj, void * sel, struct Long * r, void * a1) { *r = ((struct Long (*)(void *, void *, void *))fRet)(obj, sel, a1); }
// void objc_msgSend_stret_Bool(void * obj, void * sel, struct Bool * r, void * a1) { *r = ((struct Bool (*)(void *, void *, void *))fRet)(obj, sel, a1); }

void objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr(void * obj, void * sel, struct CGFloat2 * r, struct CGFloat2 * a1, void * a2) { *r = ((struct CGFloat2 (*)(void *, void *, struct CGFloat2, void *))f)(obj, sel, *a1, a2); }

void objc_msgSend_stret_CGFloat4_apply_CGFloat2_apply_ptr_apply_ptr_apply_ptr(void * obj, void * sel, struct CGFloat4 * r, struct CGFloat2 * a1, void * a2, void * a3, void * a4) { *r = ((struct CGFloat4 (*)(void *, void *, struct CGFloat2, void *, void *, void *))fRet)(obj, sel, *a1, a2, a3, a4); }

void * objc_msgSend_apply_ptr_apply_block(void * obj, void * sel, void * a1, void (*blockFunPtr)(void *)) {
 ((void * (*)(void *, void *, void *, void (^)()))f)(obj, sel, a1, ^(void *blockA1){ (*blockFunPtr)(blockA1); });
}
