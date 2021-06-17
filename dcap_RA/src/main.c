#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include "quote_generation.h"
#include "quote_verification.h"
#include "secret_prov.h"


int main() {
    struct ra_tls_ctx ctx = {0};
    int sgx_fd;
    if ((sgx_fd = open("/dev/sgx", O_RDONLY)) < 0) {
        printf("failed to open /dev/sgx\n");
        return -1;
    }

    uint32_t quote_size = get_quote_size(sgx_fd);

    uint8_t *quote_buffer = (uint8_t *)malloc(quote_size);
    if (NULL == quote_buffer) {
        printf("Couldn't allocate quote_buffer\n");
        close(sgx_fd);
        return -1;
    }
    memset(quote_buffer, 0, quote_size);

    sgx_report_data_t report_data = { 0 };
    char *data = "ioctl DCAP report data example";
    memcpy(report_data.d, data, strlen(data));

    sgxioc_gen_dcap_quote_arg_t gen_quote_arg = {
        .report_data = &report_data,
        .quote_len = &quote_size,
        .quote_buf = quote_buffer
    };

    if (generate_quote(sgx_fd, &gen_quote_arg) != 0) {
        printf("failed to generate quote\n");
        close(sgx_fd);
        return -1;
    }
    
    printf("Succeed to generate the quote!\n");
    int ret = 0;
//	ret = secret_provision_start("172.18.0.1:4433",
//	ret = secret_provision_start("attestation.service.com:4433",
    ret = secret_provision_start("172.18.0.1:4433",
          "certs/test-ca-sha256.crt", &ctx, quote_buffer,quote_size);

    if (ret < 0) {
       printf("[error] secret_provision_start() returned %d\n", ret);
    }

    uint8_t* secret1   = NULL;
    size_t secret1_size = 0;
    ret = secret_provision_get(&secret1, &secret1_size);
    printf("recived key is : %s \n", secret1);

    return 0;
}
