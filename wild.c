/*
 * This program converts fixed-format DISPLAY FILES output into
 * whatever you ask. Its primary use will be in generating CSS scripts
 * that can delete or rename object files and other such clutter en
 * masse. OS/32 does not make that sort of thing terribly easy.
 */

#include <stdio.h>
#include <ctype.h>

#define strchr(s,c) index((s),(c))

int usage()
{
   printf ("\n\n");
   printf ("Usage: WILD \"command\",wildcard\n\n");
   printf ("   'command' is an OS/32 command or CSS ");
   printf ("to run on each file.\n");
   printf ("   'wildcard' is an OS/32 wildcard pattern.\n\n");
   printf ("Placeholders:\n\n");
   printf ("   $V  volume\n");
   printf ("   $N  file NAME\n");
   printf ("   $X  extension\n");
   printf ("   $A  account (/P, /G, or /S)\n");
   printf ("   $F  file name, extension and account\n");
   printf ("   $T  type\n");
   printf ("   $D  dbs\n");
   printf ("   $I  ibs\n");
   printf ("   $L  record LENGTH\n");
   printf ("   $R  records\n");
   printf ("   $C  created date (ctime)\n");
   printf ("   $W  written date (mtime)\n");
   printf ("   $K  keys (protection)\n");
   printf ("   $:  semicolon\n");
   printf ("   $$  dollar sign\n");
   printf ("\n");
   return (1);
}

int memcmp(p1,p2,len)
   char *p1, *p2;
   int len;
{
   while (--len > 0 && *p1 == *p2)
   {
      p1++;
      p2++;
   }
   return (*p1-*p2);
}

char *rtrim (str)
   char *str;
{
   char *p = str;
   while (*p) p++;
   while (p >= str && *p <= ' ') *p-- = 0;
   return (str);
}

int toupper(ch)
   int ch;
{
   if (islower(ch)) ch -= 'a' - 'A';
   return (ch);
}

int main (argc, argv)
   int argc;
   char **argv;
{
   char line[90], *p;
   char volbuf[80], *vol;
   char *cmd, *wild, *act;

   if (argc < 3) return usage();
   cmd = argv[1];
   wild = argv[2];

   act = strchr (wild, '/');
   if (act) act++;
   else act = "P";

   while ( fgets(line,sizeof(line),stdin) && !feof(stdin) )
   {
      int dolcnt = 0;

      char *nam = line+1;
      char *ext = line+10;
      char *typ = line+20;
      char *dbs = line+23;
      char *ibs = line+27;
      char *len = line+31;
      char *rex = line+37;
      char *cre = line+45;
      char *wri = line+60;
      char *key = line+75;

      if (!memcmp(line,"VOLUME=",7))
      {
         strcpy (vol=volbuf, rtrim(line+7));
         while (*vol > 0 && *vol <= ' ') vol++;
         continue;
      }
      if (!memcmp(line," FILENAME...",12)) continue;
      if (*line != ' ')
      {
         fprintf (stderr, "%s", line);
         exit (1);
      }

      nam[8] = ext[3] = typ[2] = dbs[3] = ibs[3] = 0;
      len[5] = rex[7] = cre[14] = wri[14] = key[4] = 0;
      rtrim (ext);
      rtrim (nam);
      while (*dbs != 0 && *dbs <= ' ') dbs++;
      while (*ibs != 0 && *ibs <= ' ') ibs++;
      while (*rex != 0 && *rex <= ' ') rex++;

      for (p=cmd; *p; p++)
      {
         if (*p == '$')
         {
            switch (toupper(p[1]))
            {
               case 'V':  printf("%s",vol); p++; break;;
               case 'N':  printf("%s",nam); p++; break;;
               case 'X':  printf("%s",ext); p++; break;;
               case 'A':  printf("%s",act); p++; break;;
               case 'T':  printf("%s",typ); p++; break;;
               case 'D':  printf("%s",dbs); p++; break;;
               case 'I':  printf("%s",ibs); p++; break;;
               case 'L':  printf("%s",len); p++; break;;
               case 'R':  printf("%s",rex); p++; break;;
               case 'C':  printf("%s",cre); p++; break;;
               case 'W':  printf("%s",wri); p++; break;;
               case 'K':  printf("%s",key); p++; break;;

               case 'F':
                  printf ("%s.%s/%s", nam, ext, act);
                  p++;
                  break;

               case ':':
                  putchar (';');
                  p++;
                  break;

               case '$':
                  putchar ('$');
                  p++;
                  break;

               default:
                  fprintf (stderr, "Invalid placeholder '%c'\n", *p);
                  exit (1);
            }
            dolcnt++;
         }
         else
            putchar (*p);
      }
      if (dolcnt == 0) printf (" %s.%s/%s", nam, ext, act);
      putchar ('\n');
   }

   printf ("$exit\n");

   return (0);
}
