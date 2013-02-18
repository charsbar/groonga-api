#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"
#include "API.h"

#include <groonga/groonga.h>

MODULE = Groonga::API  PACKAGE = Groonga::API  PREFIX = grn_

PROTOTYPES: DISABLE

INCLUDE: api.inc

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
    RETVAL = hv;

  OUTPUT:
    RETVAL
