
function val = unifpdf_2d(xrange, yrange, z)
    minX = xrange(1);
    maxX = xrange(2);
    minY = yrange(1);
    maxY = yrange(2);
    evalX = z(1);
    evalY = z(2);
    if(evalX < minX)
        val = 0;
        return;
    elseif(evalX > maxX)
        val = 0;
        return
    elseif (evalY < minY)
        val = 0;
        return;
    elseif(evalY > maxY)
        val = 0;
        return;
    else
        val = 1 / ((maxX - minX) * (maxY - minY));
    end

end