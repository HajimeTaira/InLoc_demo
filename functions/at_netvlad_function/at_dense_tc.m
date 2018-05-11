function match = at_dense_tc(desc1,desc2)

[idx12, dis12] = yael_nn(desc2, desc1, 1);
[idx21, dis21] = yael_nn(desc1, desc2, 1);

Ndesc = length(idx12);
match = NaN(3,Ndesc);
for ii=1:Ndesc
  if ~isnan(idx12(1,ii))
    if idx21(1,idx12(1,ii)) == ii
      match(:,ii) = [ii; single(idx12(1,ii)); dis12(1,ii)];
    end
  end
end
match = match(:,~isnan(match(1,:)));