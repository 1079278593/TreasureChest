struct gaicb
{
  const char *ar_name;        /* Name to look up.  */
  const char *ar_service;    /* Service name.  */
  const struct addrinfo *ar_request; /* Additional request specification.  */
  struct addrinfo *ar_result;    /* Pointer to result.  */
  /* The following are internal elements.  */
  int __return;
  int __glibc_reserved[5];
};

/* Lookup mode.  */
#  define GAI_WAIT    0
#  define GAI_NOWAIT    1

/* Get the error status of the request REQ.  */
extern int gai_error (struct gaicb *__req) __THROW;

/* Cancel the requests associated with GAICBP.  */
extern int gai_cancel (struct gaicb *__gaicbp) __THROW;

extern int getaddrinfo_a (int __mode, struct gaicb *__list[__restrict_arr],
              int __ent, struct sigevent *__restrict __sig);
