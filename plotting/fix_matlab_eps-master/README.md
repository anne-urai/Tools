# fix_matlab_eps
A Python script to fix artifacts in EPS files generated from Matlab contour plots

These artifacts are white lines that have been present since Matlab 2014b

## Example

Here is an example of what the EPS looks like before and after my script. The EPS was created by

```Matlab
z = peaks;
contourf(z);
print(gcf,'-depsc','-painters','out.eps');
```

![Before and After](http://i.imgur.com/8pp5JYt.png)

# Disclaimer

I do not know anything about EPS files. I just looked at the difference between EPS files from
Inkscape with and without the artifacts and tried to reproduce that using a Python script.
If you have a file for which it doesn't work, please share it with me so I can try to reproduce
things in a similar way.

This code was only tested with Inkscape 0.48.4 and Matlab 2015b on a small amount of countour plots.
