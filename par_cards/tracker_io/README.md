Use IO file to change the 

* noise level
* active layers
* detector efficiency

**Generate io files with different settings**

```bash
fname_io_example="io_MuSim-example.py"
noise_level=(0.1 1 10)  # noise level relative to the cosmic rate
active_layers=(4 5 6)   # number of layers to be used
det_eff=(0.90 0.95 1.00) # detector efficiency

for noise in "${noise_level[@]}"
do
    for layer in "${active_layers[@]}"
    do
        for eff in "${det_eff[@]}"
        do
            fname_io_new="io_MuSim-noise${noise}-layers${layer}-eff${eff}.py"
            cp $fname_io_example $fname_io_new
            sed -i "/^NOISE       =/s/=.*/= $noise/" $fname_io_new
            sed -i "/^LAYERS      =/s/=.*/= $layer/" $fname_io_new
            sed -i "/^EFFICIENCY  =/s/=.*/= $eff/" $fname_io_new
        done
    done
done
```