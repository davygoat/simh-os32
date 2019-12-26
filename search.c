#include <stdio.h>
#include <ctype.h>

int toupper(ch)
   int ch;
{
   if (islower(ch)) ch -= 'a' - 'A';
   return (ch);
}

char *stristr (haystack,needle)
   char *haystack;
   char *needle;
{
   char *hs, *p, *q;
   for (hs=haystack; *hs; hs++)
   {
      if (toupper(*hs) == toupper(*needle))
      {
         p = needle;
         q = hs;
         while ( *p > 0 &&
                 *q > 0 &&
                 toupper(*p) == toupper(*q) )
         {
            p++;
            q++;
         }
         if (*p == 0) return (hs);
      }
   }
   return (NULL);
}

int main (argc,argv)
   int argc;
   char **argv;
{
   char *fnam, *str, line[256];
   int lc, mc, i;

   if (argc < 3)
   {
      fprintf (stderr, "Usage: $ search FILENAME,STRING\n");
      exit (0);
   }

   fnam = argv[1];
   str = argv[2];

   lc = mc = 0;
   while ( fgets(line,sizeof(line),stdin) && !feof(stdin) )
   {
      lc++;
      if (stristr(line,str))
      {
         if (!mc++)
         {
            printf ("\n\n====== ");
            printf ("%s ", fnam);
            for (i=71-strlen(fnam); i>0; i--) putc ('=', stdout);
            printf ("\n\n");
         }
         printf ("%6d %s", lc, line);
      }
   }

   return (0);
}
