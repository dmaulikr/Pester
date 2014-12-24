package #
Date::Manip::TZ::amregi00;
# Copyright (c) 2008-2014 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Fri Nov 21 10:41:41 EST 2014
#    Data version: tzdata2014j
#    Code version: tzcode2014j

# This module contains data from the zoneinfo time zone database.  The original
# data was obtained from the URL:
#    ftp://ftp.iana.org/tz

use strict;
use warnings;
require 5.010000;

our (%Dates,%LastRule);
END {
   undef %Dates;
   undef %LastRule;
}

our ($VERSION);
$VERSION='6.48';
END { undef $VERSION; }

%Dates         = (
   1    =>
     [
        [ [1,1,2,0,0,0],[1,1,1,17,1,24],'-06:58:36',[-6,-58,-36],
          'LMT',0,[1905,9,1,6,58,35],[1905,8,31,23,59,59],
          '0001010200:00:00','0001010117:01:24','1905090106:58:35','1905083123:59:59' ],
     ],
   1905 =>
     [
        [ [1905,9,1,6,58,36],[1905,8,31,23,58,36],'-07:00:00',[-7,0,0],
          'MST',0,[1918,4,14,8,59,59],[1918,4,14,1,59,59],
          '1905090106:58:36','1905083123:58:36','1918041408:59:59','1918041401:59:59' ],
     ],
   1918 =>
     [
        [ [1918,4,14,9,0,0],[1918,4,14,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1918,10,27,7,59,59],[1918,10,27,1,59,59],
          '1918041409:00:00','1918041403:00:00','1918102707:59:59','1918102701:59:59' ],
        [ [1918,10,27,8,0,0],[1918,10,27,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1930,5,4,6,59,59],[1930,5,3,23,59,59],
          '1918102708:00:00','1918102701:00:00','1930050406:59:59','1930050323:59:59' ],
     ],
   1930 =>
     [
        [ [1930,5,4,7,0,0],[1930,5,4,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1930,10,5,5,59,59],[1930,10,4,23,59,59],
          '1930050407:00:00','1930050401:00:00','1930100505:59:59','1930100423:59:59' ],
        [ [1930,10,5,6,0,0],[1930,10,4,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1931,5,3,6,59,59],[1931,5,2,23,59,59],
          '1930100506:00:00','1930100423:00:00','1931050306:59:59','1931050223:59:59' ],
     ],
   1931 =>
     [
        [ [1931,5,3,7,0,0],[1931,5,3,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1931,10,4,5,59,59],[1931,10,3,23,59,59],
          '1931050307:00:00','1931050301:00:00','1931100405:59:59','1931100323:59:59' ],
        [ [1931,10,4,6,0,0],[1931,10,3,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1932,5,1,6,59,59],[1932,4,30,23,59,59],
          '1931100406:00:00','1931100323:00:00','1932050106:59:59','1932043023:59:59' ],
     ],
   1932 =>
     [
        [ [1932,5,1,7,0,0],[1932,5,1,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1932,10,2,5,59,59],[1932,10,1,23,59,59],
          '1932050107:00:00','1932050101:00:00','1932100205:59:59','1932100123:59:59' ],
        [ [1932,10,2,6,0,0],[1932,10,1,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1933,5,7,6,59,59],[1933,5,6,23,59,59],
          '1932100206:00:00','1932100123:00:00','1933050706:59:59','1933050623:59:59' ],
     ],
   1933 =>
     [
        [ [1933,5,7,7,0,0],[1933,5,7,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1933,10,1,5,59,59],[1933,9,30,23,59,59],
          '1933050707:00:00','1933050701:00:00','1933100105:59:59','1933093023:59:59' ],
        [ [1933,10,1,6,0,0],[1933,9,30,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1934,5,6,6,59,59],[1934,5,5,23,59,59],
          '1933100106:00:00','1933093023:00:00','1934050606:59:59','1934050523:59:59' ],
     ],
   1934 =>
     [
        [ [1934,5,6,7,0,0],[1934,5,6,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1934,10,7,5,59,59],[1934,10,6,23,59,59],
          '1934050607:00:00','1934050601:00:00','1934100705:59:59','1934100623:59:59' ],
        [ [1934,10,7,6,0,0],[1934,10,6,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1937,4,11,6,59,59],[1937,4,10,23,59,59],
          '1934100706:00:00','1934100623:00:00','1937041106:59:59','1937041023:59:59' ],
     ],
   1937 =>
     [
        [ [1937,4,11,7,0,0],[1937,4,11,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1937,10,10,5,59,59],[1937,10,9,23,59,59],
          '1937041107:00:00','1937041101:00:00','1937101005:59:59','1937100923:59:59' ],
        [ [1937,10,10,6,0,0],[1937,10,9,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1938,4,10,6,59,59],[1938,4,9,23,59,59],
          '1937101006:00:00','1937100923:00:00','1938041006:59:59','1938040923:59:59' ],
     ],
   1938 =>
     [
        [ [1938,4,10,7,0,0],[1938,4,10,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1938,10,2,5,59,59],[1938,10,1,23,59,59],
          '1938041007:00:00','1938041001:00:00','1938100205:59:59','1938100123:59:59' ],
        [ [1938,10,2,6,0,0],[1938,10,1,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1939,4,9,6,59,59],[1939,4,8,23,59,59],
          '1938100206:00:00','1938100123:00:00','1939040906:59:59','1939040823:59:59' ],
     ],
   1939 =>
     [
        [ [1939,4,9,7,0,0],[1939,4,9,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1939,10,8,5,59,59],[1939,10,7,23,59,59],
          '1939040907:00:00','1939040901:00:00','1939100805:59:59','1939100723:59:59' ],
        [ [1939,10,8,6,0,0],[1939,10,7,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1940,4,14,6,59,59],[1940,4,13,23,59,59],
          '1939100806:00:00','1939100723:00:00','1940041406:59:59','1940041323:59:59' ],
     ],
   1940 =>
     [
        [ [1940,4,14,7,0,0],[1940,4,14,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1940,10,13,5,59,59],[1940,10,12,23,59,59],
          '1940041407:00:00','1940041401:00:00','1940101305:59:59','1940101223:59:59' ],
        [ [1940,10,13,6,0,0],[1940,10,12,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1941,4,13,6,59,59],[1941,4,12,23,59,59],
          '1940101306:00:00','1940101223:00:00','1941041306:59:59','1941041223:59:59' ],
     ],
   1941 =>
     [
        [ [1941,4,13,7,0,0],[1941,4,13,1,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1941,10,12,5,59,59],[1941,10,11,23,59,59],
          '1941041307:00:00','1941041301:00:00','1941101205:59:59','1941101123:59:59' ],
        [ [1941,10,12,6,0,0],[1941,10,11,23,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1942,2,9,8,59,59],[1942,2,9,1,59,59],
          '1941101206:00:00','1941101123:00:00','1942020908:59:59','1942020901:59:59' ],
     ],
   1942 =>
     [
        [ [1942,2,9,9,0,0],[1942,2,9,3,0,0],'-06:00:00',[-6,0,0],
          'MWT',1,[1945,8,14,22,59,59],[1945,8,14,16,59,59],
          '1942020909:00:00','1942020903:00:00','1945081422:59:59','1945081416:59:59' ],
     ],
   1945 =>
     [
        [ [1945,8,14,23,0,0],[1945,8,14,17,0,0],'-06:00:00',[-6,0,0],
          'MPT',1,[1945,9,30,7,59,59],[1945,9,30,1,59,59],
          '1945081423:00:00','1945081417:00:00','1945093007:59:59','1945093001:59:59' ],
        [ [1945,9,30,8,0,0],[1945,9,30,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1946,4,14,8,59,59],[1946,4,14,1,59,59],
          '1945093008:00:00','1945093001:00:00','1946041408:59:59','1946041401:59:59' ],
     ],
   1946 =>
     [
        [ [1946,4,14,9,0,0],[1946,4,14,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1946,10,13,7,59,59],[1946,10,13,1,59,59],
          '1946041409:00:00','1946041403:00:00','1946101307:59:59','1946101301:59:59' ],
        [ [1946,10,13,8,0,0],[1946,10,13,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1947,4,27,8,59,59],[1947,4,27,1,59,59],
          '1946101308:00:00','1946101301:00:00','1947042708:59:59','1947042701:59:59' ],
     ],
   1947 =>
     [
        [ [1947,4,27,9,0,0],[1947,4,27,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1947,9,28,7,59,59],[1947,9,28,1,59,59],
          '1947042709:00:00','1947042703:00:00','1947092807:59:59','1947092801:59:59' ],
        [ [1947,9,28,8,0,0],[1947,9,28,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1948,4,25,8,59,59],[1948,4,25,1,59,59],
          '1947092808:00:00','1947092801:00:00','1948042508:59:59','1948042501:59:59' ],
     ],
   1948 =>
     [
        [ [1948,4,25,9,0,0],[1948,4,25,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1948,9,26,7,59,59],[1948,9,26,1,59,59],
          '1948042509:00:00','1948042503:00:00','1948092607:59:59','1948092601:59:59' ],
        [ [1948,9,26,8,0,0],[1948,9,26,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1949,4,24,8,59,59],[1949,4,24,1,59,59],
          '1948092608:00:00','1948092601:00:00','1949042408:59:59','1949042401:59:59' ],
     ],
   1949 =>
     [
        [ [1949,4,24,9,0,0],[1949,4,24,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1949,9,25,7,59,59],[1949,9,25,1,59,59],
          '1949042409:00:00','1949042403:00:00','1949092507:59:59','1949092501:59:59' ],
        [ [1949,9,25,8,0,0],[1949,9,25,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1950,4,30,8,59,59],[1950,4,30,1,59,59],
          '1949092508:00:00','1949092501:00:00','1950043008:59:59','1950043001:59:59' ],
     ],
   1950 =>
     [
        [ [1950,4,30,9,0,0],[1950,4,30,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1950,9,24,7,59,59],[1950,9,24,1,59,59],
          '1950043009:00:00','1950043003:00:00','1950092407:59:59','1950092401:59:59' ],
        [ [1950,9,24,8,0,0],[1950,9,24,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1951,4,29,8,59,59],[1951,4,29,1,59,59],
          '1950092408:00:00','1950092401:00:00','1951042908:59:59','1951042901:59:59' ],
     ],
   1951 =>
     [
        [ [1951,4,29,9,0,0],[1951,4,29,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1951,9,30,7,59,59],[1951,9,30,1,59,59],
          '1951042909:00:00','1951042903:00:00','1951093007:59:59','1951093001:59:59' ],
        [ [1951,9,30,8,0,0],[1951,9,30,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1952,4,27,8,59,59],[1952,4,27,1,59,59],
          '1951093008:00:00','1951093001:00:00','1952042708:59:59','1952042701:59:59' ],
     ],
   1952 =>
     [
        [ [1952,4,27,9,0,0],[1952,4,27,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1952,9,28,7,59,59],[1952,9,28,1,59,59],
          '1952042709:00:00','1952042703:00:00','1952092807:59:59','1952092801:59:59' ],
        [ [1952,9,28,8,0,0],[1952,9,28,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1953,4,26,8,59,59],[1953,4,26,1,59,59],
          '1952092808:00:00','1952092801:00:00','1953042608:59:59','1953042601:59:59' ],
     ],
   1953 =>
     [
        [ [1953,4,26,9,0,0],[1953,4,26,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1953,9,27,7,59,59],[1953,9,27,1,59,59],
          '1953042609:00:00','1953042603:00:00','1953092707:59:59','1953092701:59:59' ],
        [ [1953,9,27,8,0,0],[1953,9,27,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1954,4,25,8,59,59],[1954,4,25,1,59,59],
          '1953092708:00:00','1953092701:00:00','1954042508:59:59','1954042501:59:59' ],
     ],
   1954 =>
     [
        [ [1954,4,25,9,0,0],[1954,4,25,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1954,9,26,7,59,59],[1954,9,26,1,59,59],
          '1954042509:00:00','1954042503:00:00','1954092607:59:59','1954092601:59:59' ],
        [ [1954,9,26,8,0,0],[1954,9,26,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1955,4,24,8,59,59],[1955,4,24,1,59,59],
          '1954092608:00:00','1954092601:00:00','1955042408:59:59','1955042401:59:59' ],
     ],
   1955 =>
     [
        [ [1955,4,24,9,0,0],[1955,4,24,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1955,9,25,7,59,59],[1955,9,25,1,59,59],
          '1955042409:00:00','1955042403:00:00','1955092507:59:59','1955092501:59:59' ],
        [ [1955,9,25,8,0,0],[1955,9,25,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1956,4,29,8,59,59],[1956,4,29,1,59,59],
          '1955092508:00:00','1955092501:00:00','1956042908:59:59','1956042901:59:59' ],
     ],
   1956 =>
     [
        [ [1956,4,29,9,0,0],[1956,4,29,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1956,9,30,7,59,59],[1956,9,30,1,59,59],
          '1956042909:00:00','1956042903:00:00','1956093007:59:59','1956093001:59:59' ],
        [ [1956,9,30,8,0,0],[1956,9,30,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1957,4,28,8,59,59],[1957,4,28,1,59,59],
          '1956093008:00:00','1956093001:00:00','1957042808:59:59','1957042801:59:59' ],
     ],
   1957 =>
     [
        [ [1957,4,28,9,0,0],[1957,4,28,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1957,9,29,7,59,59],[1957,9,29,1,59,59],
          '1957042809:00:00','1957042803:00:00','1957092907:59:59','1957092901:59:59' ],
        [ [1957,9,29,8,0,0],[1957,9,29,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1959,4,26,8,59,59],[1959,4,26,1,59,59],
          '1957092908:00:00','1957092901:00:00','1959042608:59:59','1959042601:59:59' ],
     ],
   1959 =>
     [
        [ [1959,4,26,9,0,0],[1959,4,26,3,0,0],'-06:00:00',[-6,0,0],
          'MDT',1,[1959,10,25,7,59,59],[1959,10,25,1,59,59],
          '1959042609:00:00','1959042603:00:00','1959102507:59:59','1959102501:59:59' ],
        [ [1959,10,25,8,0,0],[1959,10,25,1,0,0],'-07:00:00',[-7,0,0],
          'MST',0,[1960,4,24,8,59,59],[1960,4,24,1,59,59],
          '1959102508:00:00','1959102501:00:00','1960042408:59:59','1960042401:59:59' ],
     ],
   1960 =>
     [
        [ [1960,4,24,9,0,0],[1960,4,24,3,0,0],'-06:00:00',[-6,0,0],
          'CST',0,[9999,12,31,0,0,0],[9999,12,30,18,0,0],
          '1960042409:00:00','1960042403:00:00','9999123100:00:00','9999123018:00:00' ],
     ],
);

%LastRule      = (
);

1;
