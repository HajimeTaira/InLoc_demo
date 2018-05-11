% Author: Relja Arandjelovic (relja@relja.info)

function Y= relja_l1normalize_col( X )
    Y= bsxfun(@rdivide, X, sum(abs(X),1) + 1e-12 );
end
