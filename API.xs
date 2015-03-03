#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"
#include "API.h"
#include <groonga.h>

#include "dispatcher.inc"

MODULE = Groonga::API  PACKAGE = Groonga::API  PREFIX = grn_

BOOT:
  av_push(get_av("Groonga::API::array::ISA", TRUE), newSVpv("Groonga::API::obj", 0));
  av_push(get_av("Groonga::API::hash::ISA", TRUE), newSVpv("Groonga::API::obj", 0));
  av_push(get_av("Groonga::API::pat::ISA", TRUE), newSVpv("Groonga::API::obj", 0));
  av_push(get_av("Groonga::API::dat::ISA", TRUE), newSVpv("Groonga::API::obj", 0));

PROTOTYPES: DISABLE

INCLUDE: api.inc

void
EXPR_CREATE_FOR_QUERY(grn_ctx *ctx, grn_obj *table, OUT grn_obj *expr, OUT grn_obj *var)
  CODE:
    GRN_EXPR_CREATE_FOR_QUERY(ctx, table, expr, var);

unsigned char
CHAR_IS_BLANK(unsigned char c)
  CODE:
    RETVAL = GRN_CHAR_IS_BLANK(c);
  OUTPUT:
    RETVAL

unsigned char
CHAR_TYPE(unsigned char c)
  CODE:
    RETVAL = GRN_CHAR_TYPE(c);
  OUTPUT:
    RETVAL

unsigned int
TEXT_LEN(grn_obj *bulk)
  CODE:
    RETVAL = GRN_TEXT_LEN(bulk);
  OUTPUT:
    RETVAL

INCLUDE: bulk.inc

MODULE = Groonga::API  PACKAGE = Groonga::API::Constants  PREFIX = grn_

PROTOTYPES: DISABLE

INCLUDE: constants.inc

MODULE = Groonga::API  PACKAGE = Groonga::API::ctx

PROTOTYPES: DISABLE

INCLUDE: attr_ctx.inc

grn_user_data *
user_data(grn_ctx *ctx)
  CODE:
    RETVAL = &(ctx->user_data);
  OUTPUT:
    RETVAL

MODULE = Groonga::API  PACKAGE = Groonga::API::obj

PROTOTYPES: DISABLE

HV*
header(grn_obj * obj, SV *value = NULL)
  CODE:
    if (value && SvROK(value)) {
      HV * const tmp_hv = (HV *)SvRV(value);
      if (hv_exists(tmp_hv, "type", 4)) {
        SV **sv;
        if ((sv = hv_fetch(tmp_hv, "type", 4, 0)) != NULL) {
          obj->header.type = SvIV(*sv);
        }
      }
      if (hv_exists(tmp_hv, "impl_flags", 10)) {
        SV **sv;
        if ((sv = hv_fetch(tmp_hv, "impl_flags", 10, 0)) != NULL) {
          obj->header.impl_flags = SvIV(*sv);
        }
      }
      if (hv_exists(tmp_hv, "flags", 5)) {
        SV **sv;
        if ((sv = hv_fetch(tmp_hv, "flags", 5, 0)) != NULL) {
          obj->header.flags = SvIV(*sv);
        }
      }
      if (hv_exists(tmp_hv, "domain", 6)) {
        SV **sv;
        if ((sv = hv_fetch(tmp_hv, "domain", 6, 0)) != NULL) {
          obj->header.domain = SvIV(*sv);
        }
      }
    }
    HV* hv = newHV();
    if (obj) {
      hv_stores(hv, "type", newSViv(obj->header.type));
      hv_stores(hv, "impl_flags", newSViv(obj->header.impl_flags));
      hv_stores(hv, "flags", newSViv(obj->header.flags));
      hv_stores(hv, "domain", newSViv(obj->header.domain));
    }
    sv_2mortal((SV*)hv);
    RETVAL = hv;

  OUTPUT:
    RETVAL

HV*
ub(grn_obj * obj)
  CODE:
    HV* hv = newHV();
    if (obj) {
      hv_stores(hv, "head", newSVpv(GRN_BULK_HEAD(obj), 0));
      hv_stores(hv, "curr", newSVpv(GRN_BULK_CURR(obj), 0));
      hv_stores(hv, "tail", newSVpv(GRN_BULK_TAIL(obj), 0));
    }
    sv_2mortal((SV*)hv);
    RETVAL = hv;

  OUTPUT:
    RETVAL

MODULE = Groonga::API  PACKAGE = Groonga::API::posting

PROTOTYPES: DISABLE

INCLUDE: attr_posting.inc

MODULE = Groonga::API  PACKAGE = Groonga::API::ctx_info

PROTOTYPES: DISABLE

INCLUDE: attr_ctx_info.inc
