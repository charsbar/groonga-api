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
