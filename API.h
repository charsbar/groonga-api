#ifndef GROONGA_API_H

#include <groonga.h>

void _logger_log_dispatcher(grn_ctx *ctx, grn_log_level level,
              const char *timestamp, const char *title, const char *message,
              const char *location, void *user_data);
void _logger_reopen_dispatcher(grn_ctx *ctx, void *user_data);
void _logger_fin_dispatcher(grn_ctx *ctx, void *user_data);

#define GROONGA_API_H 1

#endif /* #ifndef GROONGA_API_H */
