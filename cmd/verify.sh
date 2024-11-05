#!/bin/bash

# error.h 中常见错误代码
error_codes=(
    "-EINVAL" "-ENOMEM" "-EIO" "-EBUSY" "-ENOSPC" "-EFAULT" "-EEXIST" "-ENXIO"
    "-EACCES" "-EAGAIN" "-ENODEV" "-ENFILE" "-ENOSYS" "-EPERM" "-ESRCH" "-E2BIG"
    "-ENOENT" "-ENFILE" "-ENOTDIR" "-EISDIR" "-EBADF" "-EPIPE" "-ENOTEMPTY"
    "-EDEADLK" "-ENAMETOOLONG" "-ERANGE" "-EINTR" "-EFBIG" "-EMFILE" "-ENOTTY"
    "-ETXTBSY" "-EFBIG" "-ENOSPC" "-ESPIPE" "-EROFS" "-EMLINK" "-EPIPE" "-EDOM"
    "-ERANGE" "-ENOMSG" "-EIDRM" "-ECHRNG" "-EL2NSYNC" "-EL3HLT" "-EL3RST" "-ELNRNG"
    "-EUNATCH" "-ENOCSI" "-EL2HLT" "-EBADE" "-EBADR" "-EXFULL" "-ENOANO" "-EBADRQC"
    "-EBADSLT" "-EBFONT" "-ENOSTR" "-ENODATA" "-ETIME" "-ENOSR" "-ENONET" "-ENOPKG"
    "-EREMOTE" "-ENOLINK" "-EADV" "-ESRMNT" "-ECOMM" "-EPROTO" "-EMULTIHOP" "-EDOTDOT"
    "-EBADMSG" "-EOVERFLOW" "-ENOTUNIQ" "-EBADFD" "-EREMCHG" "-ELIBACC" "-ELIBBAD"
    "-ELIBSCN" "-ELIBMAX" "-ELIBEXEC" "-EILSEQ" "-ERESTART" "-ESTRPIPE" "-EUSERS"
    "-ENOTSOCK" "-EDESTADDRREQ" "-EMSGSIZE" "-EPROTOTYPE" "-ENOPROTOOPT" "-EPROTONOSUPPORT"
    "-ESOCKTNOSUPPORT" "-EOPNOTSUPP" "-EPFNOSUPPORT" "-EAFNOSUPPORT" "-EADDRINUSE"
    "-EADDRNOTAVAIL" "-ENETDOWN" "-ENETUNREACH" "-ENETRESET" "-ECONNABORTED"
    "-ECONNRESET" "-ENOBUFS" "-EISCONN" "-ENOTCONN" "-ESHUTDOWN" "-ETOOMANYREFS"
    "-ETIMEDOUT" "-ECONNREFUSED" "-EHOSTDOWN" "-EHOSTUNREACH" "-EALREADY" "-EINPROGRESS"
    "-ESTALE" "-EUCLEAN" "-ENOTNAM" "-ENAVAIL" "-EISNAM" "-EREMOTEIO" "-EDQUOT"
    "-ENOMEDIUM" "-EMEDIUMTYPE" "-ECANCELED" "-ENOKEY" "-EKEYEXPIRED" "-EKEYREVOKED"
    "-EKEYREJECTED" "-EOWNERDEAD" "-ENOTRECOVERABLE" "-ERFKILL" "-EHWPOISON"
    "-EWOULDBLOCK" "-ENOTBLK" "-ECHRNG" "-EL2NSYNC" "-EL3HLT" "-EL3RST" "-ELNRNG"
    "-EUNATCH" "-ENOCSI" "-EL2HLT" "-EBADR" "-ENOTSUP" "-ENOMSG" "-ETIME" "-EBADRQC"
    "-EBADSLT" "-EDEADLOCK" "-ENOSTR" "-ENODATA" "-ETIME" "-ENOSR" "-ENONET" "-ENOPKG"
    "-EREMOTE" "-ENOLINK" "-EADV" "-ESRMNT" "-ECOMM" "-EPROTO" "-EMULTIHOP" "-EDOTDOT"
    "-EBADMSG" "-EOVERFLOW" "-ENOTUNIQ" "-EBADFD" "-EREMCHG" "-ELIBACC" "-ELIBBAD"
    "-ELIBSCN" "-ELIBMAX" "-ELIBEXEC" "-EILSEQ" "-ERESTART" "-ESTRPIPE" "-EUSERS"
    "-ENOTSOCK" "-EDESTADDRREQ" "-EMSGSIZE" "-EPROTOTYPE" "-ENOPROTOOPT" "-EPROTONOSUPPORT"
    "-ESOCKTNOSUPPORT" "-EOPNOTSUPP" "-EPFNOSUPPORT" "-EAFNOSUPPORT" "-EADDRINUSE"
    "-EADDRNOTAVAIL" "-ENETDOWN" "-ENETUNREACH" "-ENETRESET" "-ECONNABORTED"
    "-ECONNRESET" "-ENOBUFS" "-EISCONN" "-ENOTCONN" "-ESHUTDOWN" "-ETOOMANYREFS"
    "-ETIMEDOUT" "-ECONNREFUSED" "-EHOSTDOWN" "-EHOSTUNREACH" "-EALREADY" "-EINPROGRESS"
    "-ESTALE" "-EUCLEAN" "-ENOTNAM" "-ENAVAIL" "-EISNAM" "-EREMOTEIO" "-EDQUOT"
    "-ENOMEDIUM" "-EMEDIUMTYPE" "-ECANCELED" "-ENOKEY" "-EKEYEXPIRED" "-EKEYREVOKED"
    "-EKEYREJECTED" "-EOWNERDEAD" "-ENOTRECOVERABLE" "-ERFKILL" "-EHWPOISON"
    "-EREMOTE" "-ENOANO" "-ENOCSI" "-EDOTDOT" "-ENOSYS" "-ENOLCK" "-ENOTEMPTY" "-ELOOP"
    "-ENOMSG" "-EIDRM" "-ECHRNG" "-EL2NSYNC" "-EL3HLT" "-EL3RST" "-ELNRNG"
    "-EUNATCH" "-ENOCSI" "-EL2HLT" "-EBADR" "-EXFULL" "-ENOANO" "-EBADRQC"
    "-EBADSLT" "-EBFONT" "-ENOSTR" "-ENODATA" "-ETIME" "-ENOSR" "-ENONET" "-ENOPKG"
    "-EREMOTE" "-ENOLINK" "-EADV" "-ESRMNT" "-ECOMM" "-EPROTO" "-EMULTIHOP" "-EDOTDOT"
    "-EBADMSG" "-EOVERFLOW" "-ENOTUNIQ" "-EBADFD" "-EREMCHG" "-ELIBACC" "-ELIBBAD"
    "-ELIBSCN" "-ELIBMAX" "-ELIBEXEC" "-EILSEQ" "-ERESTART" "-ESTRPIPE" "-EUSERS"
    "-ENOTSOCK" "-EDESTADDRREQ" "-EMSGSIZE" "-EPROTOTYPE" "-ENOPROTOOPT" "-EPROTONOSUPPORT"
    "-ESOCKTNOSUPPORT" "-EOPNOTSUPP" "-EPFNOSUPPORT" "-EAFNOSUPPORT" "-EADDRINUSE"
    "-EADDRNOTAVAIL" "-ENETDOWN" "-ENETUNREACH" "-ENETRESET" "-ECONNABORTED"
    "-ECONNRESET" "-ENOBUFS" "-EISCONN" "-ENOTCONN" "-ESHUTDOWN" "-ETOOMANYREFS"
    "-ETIMEDOUT" "-ECONNREFUSED" "-EHOSTDOWN" "-EHOSTUNREACH" "-EALREADY" "-EINPROGRESS"
    "-ESTALE" "-EUCLEAN" "-ENOTNAM" "-ENAVAIL" "-EISNAM" "-EREMOTEIO" "-EDQUOT"
    "-ENOMEDIUM" "-EMEDIUMTYPE" "-ECANCELED" "-ENOKEY" "-EKEYEXPIRED" "-EKEYREVOKED"
    "-EKEYREJECTED" "-EOWNERDEAD" "-ENOTRECOVERABLE" "-ERFKILL" "-EHWPOISON" "0" "1" "true" "false"
)


# 输入文件和输出文件
input_file="../logs/selectedFunc.log"
output_file="../logs/verifiedFunc.log"

# 清空输出文件
> "$output_file"

# 逐行读取输入文件
while IFS= read -r line; do
    # 跳过包含 "NULL" 错误的行
    if echo "$line" | grep -q "NULL"; then
        continue
    fi

    # 提取行中的字段
    IFS=',' read -r -a fields <<< "$line"
    
    # 获取函数名
    function_name="${fields[1]}"

    # 检查函数名是否存在于 /proc/kallsyms
    if ! grep -qw "$function_name" /proc/kallsyms; then
        echo "Function $function_name not found in /proc/kallsyms, skipping."
        continue
    fi

    # 检查偶数列中的所有错误代码是否都在 error_codes 中
    valid_line=true
    for ((i=2; i<${#fields[@]}; i+=2)); do
        error="${fields[$i]}"
        if [[ ! " ${error_codes[@]} " =~ " $error " ]]; then
            valid_line=false
            echo "$function_name -> $error not supported"
            break
        fi
    done

    # 如果所有偶数列中的错误代码都有效且函数存在，则将该行写入输出文件
    if [ "$valid_line" = true ]; then
        echo "$line" >> "$output_file"
    fi
done < "$input_file"

echo "过滤完成，结果已保存到 $output_file"
