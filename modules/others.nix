{ pkgs, ... }:
{
programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
}
