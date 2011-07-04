
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "styleparser.h"

#define READ_BUFFER_LEN 1024
char *get_contents(FILE *f)
{
    char buffer[READ_BUFFER_LEN];
    size_t content_len = 1;
    char *content = malloc(sizeof(char) * READ_BUFFER_LEN);
    content[0] = '\0';
    
    while (fgets(buffer, READ_BUFFER_LEN, f))
    {
        content_len += strlen(buffer);
        content = realloc(content, content_len);
        strcat(content, buffer);
    }
    
    return content;
}

void print_styles(style_attribute *list)
{
    while (list != NULL)
    {
        printf("  %s = ", attr_name_from_type(list->type));
        if (list->type == attr_type_background_color
            || list->type == attr_type_foreground_color
            )
            printf("%i,%i,%i,%i\n",
                   list->value->argb_color->alpha,
                   list->value->argb_color->red,
                   list->value->argb_color->green,
                   list->value->argb_color->blue);
        else
            printf("%s\n", list->value->string);
        list = list->next;
    }
}

void parsing_error_callback(char *error_message)
{
    fprintf(stderr, "ERROR: %s\n", error_message);
}

int main(int argc, char *argv[])
{
    char *input = get_contents(stdin);
    style_collection *styles = parse_styles(input, &parsing_error_callback);
    
    printf("------\n");
    
    if (styles->editor_styles != NULL)
    {
        printf("Editor styles:\n");
        print_styles(styles->editor_styles);
        printf("\n");
    }
    
    int i;
    for (i = 0; i < NUM_LANG_TYPES; i++)
    {
        style_attribute *cur = styles->element_styles[i];
        
        if (cur == NULL)
            continue;
        printf("%s:\n", element_name_from_type(i));
        print_styles(cur);
    }
    
    return 0;
}