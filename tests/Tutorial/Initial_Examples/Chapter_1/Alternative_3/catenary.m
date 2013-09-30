function y = catenary(f, fp, p, mode)

switch mode
    case 'dLdf'
        y = sqrt(1+fp.^2);
    case 'dLdfp'
        y = f.*fp./sqrt(1+fp.^2);
    case 'd2Ldfdf'
        y = zeros(size(f));
    case 'd2Ldfpdf'
        y = fp./sqrt(1+fp.^2);
    case 'd2Ldfpdfp'
        y = f./(1+fp.^2).^(3/2);
end

end