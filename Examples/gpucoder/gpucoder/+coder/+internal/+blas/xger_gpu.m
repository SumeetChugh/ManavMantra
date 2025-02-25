function A = xger_gpu(m,n,alpha1,x,ix0,incx,y,iy0,incy,A,ia0,lda)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(m,n,ix0,incx,iy0,incy,ia0,lda);

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isa(A,'single')
    fun = 'gpublassger';
    ftype = 'float';
else
    fun = 'gpublasdger';
    ftype = 'double';
end

% Call the BLAS function.
if coder.internal.blas.isNullEmpty(x) && ...
        coder.internal.blas.isNullEmpty(y)
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, m, n, cref(alpha1), ...
                    cref(A(ix0), 'r', 'like', flt_type), incx, ...
                    cref(A(iy0), 'r', 'like', flt_type), incy, ...
                    cref(A(ia0), 'like', flt_type), lda);
    else
        A = coder.internal.refblas.xger( ...
            cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
            cast(alpha1,'like',real(A)), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass), ...
            A, ia0, cast(lda,coder.internal.indexIntClass));
    end
elseif coder.internal.blas.isNullEmpty(x)
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, m, n, cref(alpha1), ...
                    cref(A(ix0), 'r', 'like', flt_type), incx, ...
                    cref(y(iy0), 'r', 'like', flt_type), incy, ...
                    cref(A(ia0), 'like', flt_type), lda);
    else
        A = coder.internal.refblas.xger( ...
            cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
            cast(alpha1,'like',real(A)), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass), ...
            A, ia0, cast(lda,coder.internal.indexIntClass));
    end
elseif coder.internal.blas.isNullEmpty(y)
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, m, n, cref(alpha1), ...
                    cref(x(ix0), 'r', 'like', flt_type), incx, ...
                    cref(A(iy0), 'r', 'like', flt_type), incy, ...
                    cref(A(ia0), 'like', flt_type), lda);
    else
        A = coder.internal.refblas.xger( ...
            cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
            cast(alpha1,'like',real(A)), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass), ...
            A, ia0, cast(lda,coder.internal.indexIntClass));
    end
else
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, m, n, cref(alpha1), ...
                    cref(x(ix0), 'r', 'like', flt_type), incx, ...
                    cref(y(iy0), 'r', 'like', flt_type), incy, ...
                    cref(A(ia0), 'like', flt_type), lda);
    else
        A = coder.internal.refblas.xger( ...
            cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
            cast(alpha1,'like',real(A)), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass), ...
            A, ia0, cast(lda,coder.internal.indexIntClass));
    end
end

%--------------------------------------------------------------------------
