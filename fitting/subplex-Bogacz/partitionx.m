function [num_subspaces, subsp_dims] = partitionx(nx, order, dx,subs_min,...
    subs_max)
num_subspaces = 0;
nused = 0;
nleft = nx;
asleft = sum (dx);
while (nused < nx)
    num_subspaces = num_subspaces + 1;
    as1 = sum(dx(order((nused+1):(nused+subs_min-1))));
    gapmax = -1;
    for ns1 = subs_min:(min(subs_max,nleft))
        as1 = as1 + dx(order(nused+ns1));
        ns2 = nleft - ns1;
        if (ns2 > 0)
            if ((ns2) >= (fix((ns2-1)/subs_max+1)*subs_min))
                as2=asleft-as1;
                gap=as1/ns1-as2/ns2;
                if (gap > gapmax)
                    gapmax=gap;
                    subsp_dims(num_subspaces) =ns1;
                    as1max = as1;
                end
            end
        else
            if ((as1/ns1) > (gapmax))
                subsp_dims(num_subspaces) = ns1;
                return
            end
        end
    end
    nused = nused + subsp_dims(num_subspaces);
    nleft = nx - nused;
    asleft = asleft - as1max;
end
return
%end
