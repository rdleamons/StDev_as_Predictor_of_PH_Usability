using Ripserer
using PersistenceDiagrams
using Plots
using StatsPlots
using Distances
using Images
using FileIO
using DataFrames
using CSV
using Statistics
using StatsBase
using Distributions
using Pkg


function createPD(path, vector)
    for label in readdir(path)
        img = load("$path/$label")
        imgr = imresize(img, (50, 50))
        imgg = Gray.(imgr)
        ph = ripserer(Cubical(imgg))

        push!(vector, ph)
    end
end

function matrixToCsv(path, vec)
    df = DataFrame(pairwise(Wasserstein(), vec), :auto)
    CSV.write(path, df)
end

function createHeatmap(distMatrix, graphLabel)
    hm = heatmap(1:size(distMatrix, 1), 1:size(distMatrix, 2), distMatrix, 
        c=cgrad([:white, :blue, :purple,:red]),
        xlabel = graphLabel * " X", graphLabel * " Y",
        title = graphLabel * " Distance Matrx")
    
    plot(hm)
end

function getNZMean(vector)
    t = zero(eltype(vector))
    c = 0
    for x in vector
        x > 0 || continue
        t = t + x
        c = c + 1
    end
    return t/c
end

function getNZMinimum(vector)
    min = 100
    for x in vector
        x > 0 || continue
        if x < min
            min = x
        end
    end
    return min
end

function getFP(threshold, vector)
    count = 0
    for x in vector
        x < threshold || continue
        count += 1
    end
    return count
end

function getFN(threshold, vector)
    count = 0
    for x in vector
        x > threshold || continue
        count += 1
    end
    return count
end

function getMinError(posVec, negVec, P, N, maxDist)
    minError = 1
    threshold = 0
    for x in range(start = 0, step = 0.001, stop = maxDist)
        FP = getFP(x, negVec)
        FN = getFN(x, posVec)
        error = (FP + FN) / (P + N)
        if error < minError
            minError = error
            threshold = x
        end
    end
    return minError, threshold
end

function getFPDual(minThreshold, maxThreshold, vector)
    count = 0
    for x in vector
        if x < maxThreshold && x > minThreshold
            count += 1
        end
    end
    return count
end

# Here, FN = 0
function dualThresholdError(P, N, FP, FN)
    error = (FP + FN) / (P + N)
    return error
end