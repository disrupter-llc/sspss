// SSP spike: embed QuickJS + precompiled Crux bytecode, time the three
// operations a Crux SSP module needs: startup load, edit (parse+interp),
// reseed (interp of cached AST). No quickjs-libc: bare engine only, as a
// plugin would use it. Usage: crux_host [--dump]
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "quickjs.h"
#include "examples.h"
extern const uint8_t crux_bc[]; extern const uint32_t crux_bc_size;

static double now_ms(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1e3 + t.tv_nsec / 1e6; }

static int call(JSContext *ctx, const char *fn, JSValue *args, int argc, char *out, size_t outsz) {
    JSValue g = JS_GetGlobalObject(ctx), f = JS_GetPropertyStr(ctx, g, fn);
    JSValue r = JS_Call(ctx, f, JS_UNDEFINED, argc, args);
    int ok = !JS_IsException(r);
    if (!ok) r = JS_GetException(ctx);
    const char *s = JS_ToCString(ctx, r);
    if (out) { snprintf(out, outsz, "%s", s ? s : "?"); }
    JS_FreeCString(ctx, s); JS_FreeValue(ctx, r); JS_FreeValue(ctx, f); JS_FreeValue(ctx, g);
    return ok;
}

int main(int argc, char **argv) {
    int dump = argc > 1 && !strcmp(argv[1], "--dump");
    static char buf[1 << 16];
    double t0 = now_ms();
    JSRuntime *rt = JS_NewRuntime();
    JS_SetMemoryLimit(rt, 64 << 20);
    JSContext *ctx = JS_NewContext(rt);
    JSValue obj = JS_ReadObject(ctx, crux_bc, crux_bc_size, JS_READ_OBJ_BYTECODE);
    JSValue r = JS_EvalFunction(ctx, obj);
    if (JS_IsException(r)) { JSValue e = JS_GetException(ctx); const char *s = JS_ToCString(ctx, e); fprintf(stderr, "load failed: %s\n", s); return 1; }
    JS_FreeValue(ctx, r);
    double tload = now_ms() - t0;
    if (!dump) printf("startup (runtime + bytecode load + grammar): %.1f ms\n", tload);

    double worst_edit = 0, worst_reseed = 0;
    for (int i = 0; i < EX_COUNT; i++) {
        const int NE = 10, NR = 50;
        double te = now_ms();
        for (int k = 0; k < NE; k++) {
            JSValue a[2] = { JS_NewString(ctx, EX_SRC[i]), JS_NewInt32(ctx, 1234) };
            if (!call(ctx, "cruxEdit", a, 2, buf, sizeof buf)) { fprintf(stderr, "%s: %s\n", EX_NAMES[i], buf); return 1; }
            JS_FreeValue(ctx, a[0]);
        }
        te = (now_ms() - te) / NE;
        if (dump) { printf("%s\t%s\n", EX_NAMES[i], buf); continue; }
        double tr = now_ms();
        for (int k = 0; k < NR; k++) { JSValue a[1] = { JS_NewInt32(ctx, 1000 + k) }; call(ctx, "cruxReseed", a, 1, NULL, 0); }
        tr = (now_ms() - tr) / NR;
        if (te > worst_edit) worst_edit = te; if (tr > worst_reseed) worst_reseed = tr;
        printf("%-34s edit=%7.2f ms  reseed=%6.3f ms\n", EX_NAMES[i], te, tr);
    }
    if (!dump) {
        JSMemoryUsage m; JS_ComputeMemoryUsage(rt, &m);
        printf("worst edit=%.2f ms  worst reseed=%.3f ms  js heap=%.1f MB\n", worst_edit, worst_reseed, m.memory_used_size / 1048576.0);
    }
    JS_FreeContext(ctx); JS_FreeRuntime(rt);
    return 0;
}
