bg = uint8(255.*rand(100, 100, 3));
imtool(bg);

fg(:, :, 1) = uint8(255 .*(cumsum(ones(100, 100)) ./ 100));%
fg(:, :, 2) = uint8(zeros(100));
fg(:, :, 3) = flipud(fg(:, :, 1));
imtool(fg);

res=immerge(bg, fg, .3);
imtool(res);