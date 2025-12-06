To patch any font: https://github.com/ryanoasis/nerd-fonts

docker run --rm -v ./in:/in:Z -v ./out:/out:Z nerdfonts/patcher -c 

Create the in folder, put fonts inside. Create out folder.
Run docker container. Find patched fonts in out folder.

Remember to use -c flag for complete glyphs set.

I patched MonoLisa and CartographCF this way, rest are from the official nerd fonts distribution.