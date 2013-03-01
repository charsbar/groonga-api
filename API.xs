#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"
#include "API.h"

#include <groonga/groonga.h>

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

MODULE = Groonga::API  PACKAGE = Groonga::API::Constants  PREFIX = grn_

PROTOTYPES: DISABLE

INCLUDE: constants.inc

MODULE = Groonga::API  PACKAGE = Groonga::API::obj

PROTOTYPES: DISABLE

HV*
header(grn_obj * obj)
  CODE:
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

grn_id
rid(grn_posting *p)
  CODE:
    RETVAL = p->rid;
  OUTPUT:
    RETVAL

grn_id
sid(grn_posting *p)
  CODE:
    RETVAL = p->sid;
  OUTPUT:
    RETVAL
