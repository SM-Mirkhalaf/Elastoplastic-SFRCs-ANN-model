#
# Postprocesses the *.mac file to match the timestamps of the input
# strainData_*.txt file.
#
# inPath:       File path for *.mac file.
# outPath:      File path for output file.
# t:            Vector of time stamps.
# precision:    Number of significant figures of indata.
#

function stressPostprocess(inPath,outPath,t)

    # Read stress data file
    preData = readdlm(inPath,skipstart=2)

    # Find indices matching timestamps available in strainData files.
    index = zeros(length(t),1)
    for i = 1:length(t)
        index[i] = findall(preData[:,1].==t[i])[1]
    end
    index = convert.(Int64,index)[:]

    # Extract matching stress data
    postData = preData[index,:]

    header = ["time" "s11" "s22" "s33" "s12" "s23" "s13"]
    open(outPath, "w") do io
        writedlm(io,header)
        writedlm(io,postData)
    end
end
