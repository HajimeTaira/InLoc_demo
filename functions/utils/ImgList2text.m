function ImgList2text(ImgList, output_txtname)

fid = fopen(output_txtname, 'w');

for ii = 1:1:length(ImgList)
    this_qname = ImgList(ii).queryname;
    this_P = ImgList(ii).P{1};
    qtr = rot2qtr(this_P(1:3, 1:3));
    t = this_P(1:3, 4);
    %1. image name
    fprintf(fid, '%s', this_qname);
    %2. pose
    fprintf(fid, ' %.10g', qtr);
    fprintf(fid, ' %.10g', t);
    
    fprintf(fid, '\n');
end

fclose(fid);

end

