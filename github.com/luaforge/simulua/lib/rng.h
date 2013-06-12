/*
 * Random number generator (RNG) library for Lua [header file]
 * Check license at the bottom of this file
 * $Id: rng.h,v 1.1 2008-08-19 23:36:38 carvalho Exp $
*/

#ifndef rng_h
#define rng_h

#include <lua.h>

#define LUARNG_VERSION "LuaRNG 0.2"
#define LUARNG_COPYRIGHT "Copyright (C) 2005-2006 Luis Carvalho"
#define LUARNG_AUTHORS "Luis Carvalho"

/* Tags */
#define LUARNG_INTERN   static
#define LUARNG_API  extern

/* Constants */
#define LUARNG_LIBNAME  "rng"
#define LUARNG_MT "_rng"
#define LUARNG_MAXSTATES (624)  /* _N_ in mt19937ar.c */
#define LUARNG_SEED (5489UL)  /* default initial seed in mt199937ar.c */

/* Struct to hold state vector and current position */
typedef struct {
  unsigned long v[LUARNG_MAXSTATES];  /* the array for the state vector */
  int i;  /* i==N+1 means v[N] is not initialized */
} lua_RNG;

/* Uniform deviates are generated by Mersenne Twister method,
 * algorithm mt19937 by Makoto Matsumoto and Takuji Nishimura.
 * Check mt.c for details. */
void init_genrand(lua_RNG *o, unsigned long s);
void init_by_array(lua_RNG *o, unsigned long init_key[], int key_length);
unsigned long genrand_int32(lua_RNG *o);
long genrand_int31(lua_RNG *o);
double genrand_real1(lua_RNG *o);
double genrand_real2(lua_RNG *o);
double genrand_real3(lua_RNG *o);
double genrand_res53(lua_RNG *o); 

#define ranf(o) genrand_real3(o)
#define ignlgi(o) genrand_int31(o)
/* All other deviates are computed from an adapted ranlib.c from Netlib */
double genbet(lua_RNG *o,double aa,double bb);
double genchi(lua_RNG *o,double df);
double genexp(lua_RNG *o,double av);
double genf(lua_RNG *o,double dfn,double dfd);
double gengam(lua_RNG *o,double a,double r);
void genmul(lua_RNG *o,long n,double *p,long ncat,long *ix);
double gennch(lua_RNG *o,double df,double xnonc);
double gennf(lua_RNG *o,double dfn,double dfd,double xnonc);
double gennor(lua_RNG *o,double av,double sd);
void genprm(lua_RNG *o,long *iarray,int larray);
double genunf(lua_RNG *o,double low,double high);
long ignbin(lua_RNG *o,long n,double pp);
long ignnbn(lua_RNG *o,long n,double p);
long ignpoi(lua_RNG *o,double mu);
long ignuin(lua_RNG *o,long low,long high);

LUARNG_API lua_RNG *rng_check (lua_State *L, int pos);
LUARNG_API int luaopen_rng (lua_State *L);

/* {=================================================================
*
* Copyright (c) 2008 Luis Carvalho
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation files
* (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify,
* merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished
* to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
* BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
* ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* ==================================================================} */

#endif
